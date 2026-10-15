#import <XCTest/XCTest.h>
#import "PlayerStats.h"
#import "SimpleAudioEngine.h"
#import "DataStorage.h"
#import "UpgradeManager.h"
#import "UpgradeItem.h"
#import "UserWallet.h"
#import "ObjectiveManager.h"
#import "../Planet Orbiting iOS Game/StarStreamLayout.h"
#import "AppDelegate.h"
#import "../Planet Orbiting iOS Game/SSMapSession.h"
#import "LevelObjectReturner.h"
#import "GameplayLayer.h"
#import "CameraObject.h"
#import "Powerup.h"
#import "Player.h"
@interface GameplayLayer (LayoutTests)
- (void)loadEverything;
- (void)UpdateCamera:(float)dt;
- (void)startGame;
- (void)Update:(float)dt;
@end
@interface PlayerStatsTests : XCTestCase
@end
@implementation PlayerStatsTests
- (void)testProceduralRoutesFlyAcrossSeveralGalaxiesWithoutCrashing {
    NSDictionary *previous=SSMapSession.shared.currentMap;
    NSUserDefaults *defaults=NSUserDefaults.standardUserDefaults;
    NSString *domain=NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *backup=[defaults persistentDomainForName:domain];
    @try {
        for (NSNumber *seed in @[@1,@12345678,@1067749826]) @autoreleasepool {
            [SSMapSession.shared selectMap:[SSMapSession generateMapWithSeed:seed.unsignedIntValue]];
            GameplayLayer *game=[GameplayLayer node];
            [game onEnter];
            [game unscheduleAllSelectors];
            [game loadEverything];
            [game unscheduleAllSelectors];
            [game setValue:@NO forKey:@"isInTutorialMode"];
            [game startGame];
            [game unscheduleAllSelectors];
            Player *pilot=[game valueForKey:@"player"];
            Powerup *autopilot=[[Powerup alloc] initWithType:kautopilot];
            autopilot.duration=1e9;
            CCNode *camera=[game valueForKey:@"cameraLayer"];
            [camera addChild:autopilot.glowSprite];
            pilot.currentPowerup=autopilot;
            for (int tick=0;tick<3600;tick++) {
                [CCDirector.sharedDirector.scheduler update:1.0f/60];
                [game Update:1.0f/60];
            }
            XCTAssertGreaterThan([[game valueForKey:@"planetsHitFlurry"] intValue],20);
            XCTAssertTrue(isfinite(pilot.sprite.position.x));
            XCTAssertTrue(isfinite(pilot.sprite.position.y));
            XCTAssertFalse([[game valueForKey:@"isGameOver"] boolValue]);
            [game onExit]; [game cleanup];
        }
    } @finally {
        if (backup) [defaults setPersistentDomain:backup forName:domain];
        [DataStorage fetchData];
        [SSMapSession.shared selectMap:previous];
    }
}
- (void)testReplayReconstructsTheSameLiveMapAndCameraWorkStaysBounded {
    NSDictionary *previous=SSMapSession.shared.currentMap;
    NSDictionary *map=[SSMapSession generateMapWithSeed:12345678];
    NSMutableArray *snapshots=[NSMutableArray new];
    @try {
        for (int replay=0;replay<2;replay++) @autoreleasepool {
            // Round-trip the saved geometry through the actual on-disk JSON format.
            NSData *data=[NSJSONSerialization dataWithJSONObject:map options:0 error:nil];
            [SSMapSession.shared selectMap:[NSJSONSerialization JSONObjectWithData:data options:0 error:nil]];
            GameplayLayer *game=[GameplayLayer node];
            [game unscheduleAllSelectors];
            [game loadEverything];
            [game unscheduleAllSelectors];
            NSMutableArray *snapshot=[NSMutableArray new];
            for (NSString *key in @[@"planets",@"asteroids",@"coins",@"powerups"]) {
                NSMutableArray *positions=[NSMutableArray new];
                for (CameraObject *object in [game valueForKey:key]) [positions addObject:@[@(object.sprite.position.x),@(object.sprite.position.y),@(object.sprite.scale)]];
                [snapshot addObject:positions];
            }
            [snapshots addObject:snapshot];
            for (int frame=0;frame<3600;frame++) [game UpdateCamera:1.0f/60];
            CCNode *camera=[game valueForKey:@"cameraLayer"], *hud=[game valueForKey:@"hudLayer"];
            XCTAssertEqual(camera.numberOfRunningActions,0u); // No follow action allocation on every camera update.
            XCTAssertLessThan(hud.children.count,10u); // No preallocated pickup sprite per star.
            [camera cleanup];
            [hud cleanup];
            [game cleanup];
        }
        XCTAssertEqualObjects(snapshots[0],snapshots[1]);
    } @finally { [SSMapSession.shared selectMap:previous]; }
}
- (void)testPhysicsHasTheSameSixtyTicksAtEveryPresentationRate {
    for (NSNumber *rate in @[@30,@60,@120]) {
        double remainder=0; NSUInteger ticks=0;
        for (int i=0;i<rate.intValue*10;i++) ticks+=SSPhysicsSteps(1.0/rate.doubleValue,&remainder);
        XCTAssertEqual(ticks,600u);
        XCTAssertEqualWithAccuracy(remainder,0,1e-7);
    }
    double remainder=0;
    XCTAssertEqual(SSPhysicsSteps(20,&remainder),6u); // Bounded catch-up after a stall.
}
- (void)testProceduralMapsAreStableAndKeepAuthoredFlightProportions {
    for (uint32_t seed=1;seed<=100;seed++) @autoreleasepool {
        NSDictionary *map=[SSMapSession generateMapWithSeed:seed];
        XCTAssertEqualObjects(map,[SSMapSession generateMapWithSeed:seed]);
        XCTAssertEqual([map[@"galaxies"] count],10u);
        for (NSArray *galaxy in map[@"galaxies"]) for (NSArray *section in galaxy) {
            NSArray *objects=[SSMapSession objectsForSegment:section];
            NSMutableArray<LevelObjectReturner *> *planets=[NSMutableArray new];
            for (LevelObjectReturner *object in objects) if (object.type==kplanet) [planets addObject:object];
            XCTAssertEqual(planets.count,5u);
            for (NSUInteger i=1;i<planets.count;i++) {
                CGPoint a=planets[i-1].pos,b=planets[i].pos;
                double distance=hypot(b.x-a.x,b.y-a.y);
                XCTAssertGreaterThanOrEqual(distance,439.99);
                XCTAssertLessThanOrEqual(distance,540.01);
                XCTAssertEqual(planets[i].scale,1); // Matches the original maps' median size.
                for (LevelObjectReturner *object in objects) if (object.type==kasteroid) {
                    double dx=b.x-a.x,dy=b.y-a.y;
                    double t=fmax(0,fmin(1,((object.pos.x-a.x)*dx+(object.pos.y-a.y)*dy)/(distance*distance)));
                    double clearance=hypot(object.pos.x-a.x-t*dx,object.pos.y-a.y-t*dy);
                    XCTAssertGreaterThan(clearance,140); // Clear launch/flight corridor on both sides.
                }
            }
        }
    }
    XCTAssertNotEqualObjects([SSMapSession generateMapWithSeed:1],[SSMapSession generateMapWithSeed:2]);
}
- (void)testFavoritePersistsExactGeometryAndDoesNotDuplicateOnSave {
    SSMapSession *session=SSMapSession.shared;
    NSDictionary *previous=session.currentMap;
    NSURL *url=[[NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"StarStreamFavoriteMaps.json"];
    NSData *backup=[NSData dataWithContentsOfURL:url];
    @try {
        NSDictionary *map=[SSMapSession generateMapWithSeed:12345678];
        [session selectMap:map];
        XCTAssertTrue([session saveCurrentMapWithScore:100]);
        NSUInteger count=session.favorites.count;
        XCTAssertTrue([session saveCurrentMapWithScore:200]);
        XCTAssertEqual(session.favorites.count,count);
        NSDictionary *restored=session.favorites.firstObject;
        XCTAssertEqualObjects(restored[@"galaxies"],map[@"galaxies"]);
        XCTAssertEqualObjects(restored[@"bestScore"],@200);
        [session selectClassic];
        XCTAssertFalse(session.procedural);
        [session selectMap:restored];
        XCTAssertTrue(session.isCurrentMapFavorite);
        XCTAssertEqualObjects(session.currentMap[@"galaxies"],map[@"galaxies"]);
    } @finally {
        if (backup) [backup writeToURL:url atomically:YES];
        else [NSFileManager.defaultManager removeItemAtURL:url error:nil];
        [session selectMap:previous];
    }
}
- (void)testGameCanvasCoversTheEntireDeviceWindow {
    AppDelegate *app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    UIView *host = app.window.rootViewController.view;
    [host layoutIfNeeded];
    UIView *canvas = app.navController.view;
    CGRect coverage = [canvas convertRect:canvas.bounds toView:host];
    XCTAssertEqualWithAccuracy(CGRectGetMinX(coverage), 0, .5);
    XCTAssertEqualWithAccuracy(CGRectGetMinY(coverage), 0, .5);
    XCTAssertEqualWithAccuracy(coverage.size.width, host.bounds.size.width, .5);
    XCTAssertEqualWithAccuracy(coverage.size.height, host.bounds.size.height, .5);
    XCTAssertEqualWithAccuracy(canvas.transform.a, canvas.transform.d, .0001);
    XCTAssertEqualWithAccuracy(app.director.view.bounds.size.width, canvas.bounds.size.width, .5);
    XCTAssertEqualWithAccuracy(app.director.view.bounds.size.height, canvas.bounds.size.height, .5);
}
- (void)testSupportedAspectRatiosExpandTheWorldWithoutCropping {
    NSArray<NSValue *> *screens = @[
        [NSValue valueWithCGSize:CGSizeMake(667,375)], // SE
        [NSValue valueWithCGSize:CGSizeMake(956,440)], // large iPhone
        [NSValue valueWithCGSize:CGSizeMake(1133,744)], // iPad mini
        [NSValue valueWithCGSize:CGSizeMake(1376,1032)], // 13-inch iPad
        [NSValue valueWithCGSize:CGSizeMake(852,393)]
    ];
    for (NSValue *value in screens) {
        CGSize screen = value.CGSizeValue, world = SSViewportSize(screen);
        XCTAssertGreaterThanOrEqual(world.width, 568-.001);
        XCTAssertGreaterThanOrEqual(world.height, 320-.001);
        XCTAssertEqualWithAccuracy(world.width*SSViewportScale(screen), screen.width, .001);
        XCTAssertEqualWithAccuracy(world.height*SSViewportScale(screen), screen.height, .001);
    }
}
- (void)testRestoredScoresCanAcceptANewGame {
    PlayerStats *stats = [PlayerStats new];
    // NSUserDefaults returns immutable property-list collections after a relaunch.
    NSArray *restoredScores = @[@100, @50, @0];
    NSDictionary *restoredNames = @{@"100": @"OLD PLAYER"};
    [stats setScores:(NSMutableArray *)restoredScores];
    [stats setKeyValuePairs:(NSMutableDictionary *)restoredNames];
    XCTAssertNoThrow([stats addScore:200 withName:@"NEW PLAYER"]);
    XCTAssertEqualObjects(stats.getScores.firstObject, @200);
    XCTAssertEqualObjects(stats.getKeyValuePairs[@"200"], @"NEW PLAYER");
    XCTAssertEqualObjects(restoredScores, (@[@100,@50,@0]));
    XCTAssertNil(restoredNames[@"200"]);
}
- (void)testEmptyRestoredLeaderboardAcceptsFirstScore {
    PlayerStats *stats = [PlayerStats new];
    [stats setScores:(NSMutableArray *)@[]];
    XCTAssertTrue([stats isHighScore:1]);
    XCTAssertNoThrow([stats addScore:1 withName:@""]);
    XCTAssertEqualObjects(stats.getKeyValuePairs[@"1"], @"PLAYER");
}
- (void)testLeaderboardKeepsTwentyHighestScores {
    PlayerStats *stats = [PlayerStats new];
    for (int score=1;score<=30;score++) [stats addScore:score withName:@"PILOT"];
    XCTAssertEqual(stats.getScores.count, 20u);
    XCTAssertEqualObjects(stats.getScores.firstObject,@30);
    XCTAssertEqualObjects(stats.getScores.lastObject,@11);
}
- (void)testSavedGameCanBeLoadedTwiceWithoutMutatingStoredCollections {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSString *domain = NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *backup = [defaults persistentDomainForName:domain];
    @try {
        [defaults removeObjectForKey:@"StarStreamProgressV3"];
        NSMutableArray *missions = [NSMutableArray new];
        for (int i=0;i<16;i++) [missions addObject:@[@YES,@NO,@NO]];
        [defaults setObject:missions forKey:@"objectives"];
        [defaults setInteger:70000 forKey:@"coin"];
        [defaults setObject:@[@3,@3,@3,@0] forKey:@"upgradeCodes"];
        XCTAssertNoThrow([DataStorage fetchData]);
        XCTAssertNoThrow([DataStorage fetchData]);
        XCTAssertEqual([UserWallet.sharedInstance getBalance],70000);
        XCTAssertEqual([UpgradeManager.sharedInstance upgradeItems].count,33u);
        UpgradeItem *doubleStars = [UpgradeManager.sharedInstance upgradeItems][3];
        XCTAssertTrue(doubleStars.purchased);
        XCTAssertTrue(doubleStars.equipped);
        XCTAssertEqualObjects([defaults objectForKey:@"objectives"],missions);
    } @finally {
        if (backup) [defaults setPersistentDomain:backup forName:domain];
        else [defaults removePersistentDomainForName:domain];
        [DataStorage fetchData];
    }
}
- (void)testBundledAudioStartsAndCanPauseResumeAndMute {
    SimpleAudioEngine *engine = SimpleAudioEngine.sharedEngine;
    float oldMusic = engine.backgroundMusicVolume, oldEffects = engine.effectsVolume;
    engine.backgroundMusicVolume = 1; engine.effectsVolume = 1;
    [engine playBackgroundMusic:@"menumusic_new.mp3" loop:YES];
    XCTAssertTrue(engine.isBackgroundMusicPlaying);
    [engine pauseBackgroundMusic];
    XCTAssertFalse(engine.isBackgroundMusicPlaying);
    [engine resumeBackgroundMusic];
    XCTAssertTrue(engine.isBackgroundMusicPlaying);
    ALuint effect = [engine playEffect:@"purchase.wav" pitch:1 pan:0 gain:1];
    XCTAssertNotEqual(effect,0u);
    [engine stopEffect:effect];
    engine.effectsVolume = 0;
    XCTAssertEqual([engine playEffect:@"purchase.wav"],0u);
    engine.backgroundMusicVolume = oldMusic; engine.effectsVolume = oldEffects;
}
@end
