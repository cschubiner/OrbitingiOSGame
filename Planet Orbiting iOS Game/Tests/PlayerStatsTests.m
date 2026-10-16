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
#import "Planet.h"
#import "Coin.h"
#import "UpgradeValues.h"
@interface GameplayLayer (LayoutTests)
- (void)loadEverything;
- (void)ApplyGravity:(float)dt;
- (void)CreatePowerup:(CGFloat)x yPos:(CGFloat)y scale:(float)scale type:(int)type;
- (void)UpdateCamera:(float)dt;
- (void)startGame;
- (void)Update:(float)dt;
@end
@interface PlayerStatsTests : XCTestCase
@end
@implementation PlayerStatsTests
- (void)testTutorialAppearsOnceAndReplayIsOneRunOnly {
    NSUserDefaults *d=NSUserDefaults.standardUserDefaults; NSString *domain=NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *backup=[d persistentDomainForName:domain]; int plays=[PlayerStats.sharedInstance getPlays];
    @try {
        [d removeObjectForKey:@"SSTutorialSeen"]; [d removeObjectForKey:@"SSReplayTutorial"];
        [PlayerStats.sharedInstance setPlays:0];
        XCTAssertTrue([SSTuning beginTutorial]);
        XCTAssertFalse([SSTuning beginTutorial]); // Even if the first run was quit before a score was saved.
        [SSTuning replayTutorial]; XCTAssertTrue([SSTuning beginTutorial]); XCTAssertFalse([SSTuning beginTutorial]);
        [d removeObjectForKey:@"SSTutorialSeen"]; [PlayerStats.sharedInstance setPlays:1];
        XCTAssertFalse([SSTuning beginTutorial]); // Existing players migrate without another introduction.
    } @finally { [d setPersistentDomain:backup forName:domain]; [PlayerStats.sharedInstance setPlays:plays]; }
}
- (void)testNormalAutopilotPickupExpiresInClassicAndProceduralWithAndWithoutUpgrade {
    NSUserDefaults *d=NSUserDefaults.standardUserDefaults; NSString *domain=NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *backup=[d persistentDomainForName:domain], *previous=SSMapSession.shared.currentMap;
    @try {
        [d removeObjectForKey:@"SSTuningValues"];
        for (NSNumber *procedural in @[@NO,@YES]) for (NSNumber *upgrade in @[@NO,@YES]) @autoreleasepool {
            [UpgradeManager.sharedInstance setUpgradeIndex:10 purchased:upgrade.boolValue equipped:upgrade.boolValue];
            [SSMapSession.shared selectMap:procedural.boolValue ? [SSMapSession generateMapWithSeed:12345678] : nil];
            GameplayLayer *game=[GameplayLayer node]; [game unscheduleAllSelectors]; [game loadEverything]; [game unscheduleAllSelectors];
            Player *pilot=[game valueForKey:@"player"];
            for (Powerup *p in [game valueForKey:@"powerups"]) p.sprite.visible=NO;
            [game CreatePowerup:pilot.sprite.position.x yPos:pilot.sprite.position.y scale:1 type:kautopilot];
            Powerup *pickup=[[game valueForKey:@"powerups"] lastObject];
            XCTAssertEqualWithAccuracy(pickup.duration,390+(upgrade.boolValue ? 50 : 0),.001);
            [game ApplyGravity:1.0f/60]; // Exercise collision delivery and its counter reset.
            XCTAssertEqual(pilot.currentPowerup,pickup);
            for (int tick=1;tick<(int)pickup.duration;tick++) [game ApplyGravity:1.0f/60];
            XCTAssertEqual(pilot.currentPowerup,pickup);
            [game ApplyGravity:1.0f/60]; XCTAssertNil(pilot.currentPowerup);
            [game cleanup];
        }
    } @finally { [d setPersistentDomain:backup forName:domain]; [DataStorage fetchData]; [SSMapSession.shared selectMap:previous]; }
}
- (void)testTuningClampsMalformedValuesAndFavoritesKeepTheirPhysics {
    NSUserDefaults *d=NSUserDefaults.standardUserDefaults; NSString *domain=NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *backup=[d persistentDomainForName:domain], *previous=SSMapSession.shared.currentMap;
    @try {
        [d setBool:YES forKey:@"SSLocalTestingUnlock"];
        NSDictionary *bounded=[SSTuning validated:@{@"gameSpeed":@100,@"gravity":@(-10),@"planetSize":@"bad",@"playerSpeed":@(NAN)}];
        XCTAssertEqualObjects(bounded[@"gameSpeed"],@1.5); XCTAssertEqualObjects(bounded[@"gravity"],@.4);
        XCTAssertEqualObjects(bounded[@"planetSize"],@1); XCTAssertEqualObjects(bounded[@"playerSpeed"],@1);
        NSMutableDictionary *custom=[SSTuning.defaults mutableCopy]; custom[@"gameSpeed"]=@1.5; custom[@"gravity"]=@1.3; custom[@"planetSpin"]=@2;
        [SSTuning save:custom]; NSDictionary *map=[SSMapSession generateMapWithSeed:456];
        [SSTuning save:SSTuning.defaults]; [SSMapSession.shared selectMap:map];
        GameplayLayer *game=[GameplayLayer node]; [game unscheduleAllSelectors];
        XCTAssertEqualObjects([game valueForKey:@"runTuning"],custom);
        XCTAssertEqualWithAccuracy([[game valueForKey:@"gameSpeed"] doubleValue],1.5,.001);
        XCTAssertEqualWithAccuracy([[game valueForKey:@"gravityScale"] doubleValue],1.3,.001); [game cleanup];
        [d setBool:NO forKey:@"SSLocalTestingUnlock"]; [d removeObjectForKey:@"StarStreamProgressV3"];
        XCTAssertFalse(SSTuning.unlocked); XCTAssertEqualObjects(SSTuning.current,SSTuning.defaults);
    } @finally { [d setPersistentDomain:backup forName:domain]; [DataStorage fetchData]; [SSMapSession.shared selectMap:previous]; }
}
- (void)testTuningSlidersPersistTheirValuesAndResetDefaults {
    NSUserDefaults *d=NSUserDefaults.standardUserDefaults; NSString *domain=NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *backup=[d persistentDomainForName:domain];
    @try {
        [d setBool:YES forKey:@"SSLocalTestingUnlock"];
        UITableViewController *tuner=[[NSClassFromString(@"SSTuningController") alloc] initWithStyle:UITableViewStyleInsetGrouped];
        [tuner loadViewIfNeeded];
        UITableViewCell *cell=[tuner.tableView.dataSource tableView:tuner.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        UISlider *slider=nil; for (UIView *v in cell.contentView.subviews) if ([v isKindOfClass:UISlider.class]) slider=(UISlider *)v;
        XCTAssertNotNil(slider); slider.value=1.25;
        [slider sendActionsForControlEvents:UIControlEventValueChanged];
        XCTAssertEqualWithAccuracy([[tuner valueForKey:@"values"][@"gameSpeed"] doubleValue],1.25,.001);
        UILabel *label=[cell.contentView viewWithTag:100]; XCTAssertTrue([label.text containsString:@"1.25"]);
        UIBarButtonItem *done=tuner.navigationItem.rightBarButtonItem;
        [UIApplication.sharedApplication sendAction:done.action to:done.target from:done forEvent:nil];
        XCTAssertEqualWithAccuracy([SSTuning.current[@"gameSpeed"] doubleValue],1.25,.001);
        UIBarButtonItem *reset=tuner.navigationItem.leftBarButtonItem;
        [UIApplication.sharedApplication sendAction:reset.action to:reset.target from:reset forEvent:nil];
        XCTAssertEqualObjects([tuner valueForKey:@"values"],SSTuning.defaults);
    } @finally { [d setPersistentDomain:backup forName:domain]; }
}
- (void)testGameAndPlayerSpeedControlsChangeTheActualSimulation {
    NSUserDefaults *d=NSUserDefaults.standardUserDefaults; NSString *domain=NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *backup=[d persistentDomainForName:domain], *previous=SSMapSession.shared.currentMap;
    @try {
        [d setBool:YES forKey:@"SSLocalTestingUnlock"];
        NSMutableDictionary *custom=[SSTuning.defaults mutableCopy]; custom[@"gameSpeed"]=@1.5; custom[@"playerSpeed"]=@1.5;
        [SSTuning save:custom]; [SSMapSession.shared selectClassic];
        GameplayLayer *game=[GameplayLayer node]; [game unscheduleAllSelectors]; [game loadEverything]; [game unscheduleAllSelectors];
        Player *pilot=[game valueForKey:@"player"]; pilot.currentPowerup=nil; pilot.velocity=ccp(1,0); pilot.acceleration=CGPointZero;
        [game setValue:@1 forKey:@"timeDilationCoefficient"]; CGPoint before=pilot.sprite.position;
        [game UpdateCamera:1.0f/60];
        XCTAssertEqualWithAccuracy(pilot.sprite.position.x-before.x,1.5,.001);
        [game setValue:@NO forKey:@"paused"]; [game setValue:@NO forKey:@"isInTutorialMode"];
        double beforeTime=[[game valueForKey:@"totalGameTime"] doubleValue];
        for (int frame=0;frame<60;frame++) [game Update:1.0f/60];
        XCTAssertEqualWithAccuracy([[game valueForKey:@"totalGameTime"] doubleValue]-beforeTime,1.5,.001);
        // Drawing between steps must leave the simulated camera and ship where physics put them.
        CCLayer *camera=[game valueForKey:@"cameraLayer"];
        CGPoint shipBefore=pilot.sprite.position, cameraBefore=camera.position; float zoomBefore=camera.scale;
        [game visit];
        XCTAssertTrue(CGPointEqualToPoint(pilot.sprite.position,shipBefore));
        XCTAssertTrue(CGPointEqualToPoint(camera.position,cameraBefore));
        XCTAssertEqual(camera.scale,zoomBefore);
        [game cleanup];
    } @finally { [d setPersistentDomain:backup forName:domain]; [DataStorage fetchData]; [SSMapSession.shared selectMap:previous]; }
}
- (void)testGeneratedStarsClearEveryPlanetAndEachOtherAtDefaultAndExtremeSettings {
    NSUserDefaults *d=NSUserDefaults.standardUserDefaults; NSString *domain=NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *backup=[d persistentDomainForName:domain];
    @try {
        [d setBool:YES forKey:@"SSLocalTestingUnlock"];
        for (int preset=0;preset<3;preset++) {
            NSMutableDictionary *values=[SSTuning.defaults mutableCopy];
            if (preset) for (NSDictionary *c in SSTuning.controls) values[c[@"key"]]=c[preset==1 ? @"min" : @"max"];
            [SSTuning save:values];
            for (uint32_t seed=1;seed<=100;seed++) @autoreleasepool {
                NSDictionary *map=[SSMapSession generateMapWithSeed:seed];
                for (NSArray *galaxy in map[@"galaxies"]) for (NSArray *section in galaxy) {
                    NSMutableArray *stars=[NSMutableArray new],*planets=[NSMutableArray new];
                    for (NSDictionary *o in section) { if ([o[@"type"] intValue]==kcoin) [stars addObject:o]; if ([o[@"type"] intValue]==kplanet) [planets addObject:o]; }
                    for (NSUInteger i=0;i<stars.count;i++) {
                        NSDictionary *star=stars[i]; double x=[star[@"x"] doubleValue],y=[star[@"y"] doubleValue];
                        for (NSDictionary *planet in planets) {
                            double distance=hypot(x-[planet[@"x"] doubleValue],y-[planet[@"y"] doubleValue])*.498;
                            XCTAssertGreaterThanOrEqual(distance,54*[planet[@"scale"] doubleValue]+14.5+13.99);
                        }
                        for (NSUInteger j=0;j<i;j++) XCTAssertGreaterThanOrEqual(hypot(x-[stars[j][@"x"] doubleValue],y-[stars[j][@"y"] doubleValue])*.498,31.99);
                    }
                }
            }
        }
    } @finally { [d setPersistentDomain:backup forName:domain]; }
}
- (void)testLiveStarsClearPlanetArtAcrossSectionSeams {
    NSDictionary *previous=SSMapSession.shared.currentMap;
    @try {
        for (uint32_t seed=1;seed<=20;seed++) @autoreleasepool {
            [SSMapSession.shared selectMap:[SSMapSession generateMapWithSeed:seed]];
            GameplayLayer *game=[GameplayLayer node]; [game unscheduleAllSelectors]; [game loadEverything]; [game unscheduleAllSelectors];
            for (Coin *coin in [game valueForKey:@"coins"]) for (Planet *planet in [game valueForKey:@"planets"]) {
                double body=fmax(planet.sprite.contentSize.width,planet.sprite.contentSize.height)*planet.sprite.scale/2;
                XCTAssertGreaterThanOrEqual(ccpDistance(coin.sprite.position,planet.sprite.position),body+14.5+11);
            }
            [game cleanup];
        }
    } @finally { [SSMapSession.shared selectMap:previous]; }
}
- (void)testMenuPanelsFitInsideSafeEdgesWhileTheCanvasFillsTheWindow {
    CGRect safe=SSSafeViewport();
    CGPoint origin=SSMenuOrigin(); CGFloat scale=SSMenuScale();
    XCTAssertGreaterThanOrEqual(origin.x,CGRectGetMinX(safe)-.001);
    XCTAssertGreaterThanOrEqual(origin.y,CGRectGetMinY(safe)-.001);
    XCTAssertLessThanOrEqual(origin.x+568*scale,CGRectGetMaxX(safe)+.001);
    XCTAssertLessThanOrEqual(origin.y+320*scale,CGRectGetMaxY(safe)+.001);
}
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
- (void)testDisplayLinkNoiseKeepsOneStepPerSixtyHertzFrame {
    // Display-link timestamps carry microsecond noise and slight refresh drift. The original
    // zero-phase accumulator flipped between 0 and 2 steps on such input (visible stutter).
    for (NSNumber *hz in @[@60,@59.94,@60.03]) {
        double fixedRemainder=SSPhysicsPhase, legacyRemainder=0, previous=0;
        NSUInteger irregular=0, legacyIrregular=0, ticks=0;
        uint32_t noise=12345;
        for (int frame=0;frame<=3600;frame++) {
            noise=noise*1664525u+1013904223u;
            double now=frame/hz.doubleValue+((noise>>8)/(double)(1u<<24)-.5)*.0006; // ±0.3 ms
            if (frame==1800) continue; // One dropped frame: the next interval spans two refreshes.
            if (frame>0) {
                double dt=now-previous;
                NSUInteger steps=SSPhysicsSteps(SSSnapFrameTime(dt),&fixedRemainder);
                NSUInteger expected=frame==1801 ? 2 : 1;
                if (steps!=expected) irregular++;
                if (SSPhysicsSteps(dt,&legacyRemainder)!=expected) legacyIrregular++;
                ticks+=steps;
            }
            previous=now;
        }
        XCTAssertEqual(irregular,0u,@"%@ Hz",hz);
        XCTAssertEqual(ticks,3600u,@"%@ Hz",hz);
        XCTAssertGreaterThan(legacyIrregular,0u,@"%@ Hz: the input should reproduce the old stutter",hz);
    }
    XCTAssertEqualWithAccuracy(SSSnapFrameTime(1/60.0+.0004),1/60.0,1e-12);
    XCTAssertEqualWithAccuracy(SSSnapFrameTime(.05),.05,1e-12); // Genuine hitches are not hidden.
}
- (void)testInterpolatedFramesAdvanceEvenlyAtEveryGameSpeed {
    // Step counts per frame vary away from 1x; the drawn state, between the last two steps,
    // must still advance by exactly the game speed every 60-Hz frame.
    for (NSNumber *speed in @[@.5,@.75,@1.25,@1.5]) {
        double remainder=SSPhysicsPhase, lastShown=NAN; NSUInteger total=0;
        for (int frame=0;frame<600;frame++) {
            total+=SSPhysicsSteps(SSSnapFrameTime(1/60.0)*speed.doubleValue,&remainder);
            if (total==0) continue;
            double shown=(double)total-1+SSInterpolationAlpha(remainder);
            if (!isnan(lastShown)) XCTAssertEqualWithAccuracy(shown-lastShown,speed.doubleValue,1e-6,@"%@x frame %d",speed,frame);
            lastShown=shown;
        }
    }
    XCTAssertEqualWithAccuracy(SSLerpAngle(170,-170,.5),180,1e-4); // Through 180, not through 0.
    XCTAssertEqualWithAccuracy(SSLerpAngle(-170,170,.25),-175,1e-4);
    XCTAssertEqualWithAccuracy(SSLerpAngle(10,30,.5),20,1e-4);
}
- (void)testProceduralMapsAreStableVariedFairAndRampUp {
    double early=0, late=0; NSUInteger earlySections=0, lateSections=0;
    NSMutableSet *planetScales=[NSMutableSet set], *planetCounts=[NSMutableSet set];
    double shortest=INFINITY, longest=0, sharpest=0;
    for (uint32_t seed=1;seed<=60;seed++) @autoreleasepool {
        NSDictionary *map=[SSMapSession generateMapWithSeed:seed];
        XCTAssertEqualObjects(map,[SSMapSession generateMapWithSeed:seed]);
        XCTAssertEqualObjects(map[@"version"],@3);
        XCTAssertEqual([map[@"galaxies"] count],10u);
        NSUInteger galaxyIndex=0;
        for (NSArray *galaxy in map[@"galaxies"]) {
            for (NSArray *section in galaxy) {
                NSArray *objects=[SSMapSession objectsForSegment:section];
                NSMutableArray<LevelObjectReturner *> *planets=[NSMutableArray new];
                NSUInteger rocks=0;
                for (LevelObjectReturner *object in objects) { if (object.type==kplanet) [planets addObject:object]; if (object.type==kasteroid) rocks++; }
                XCTAssertEqual(objects.lastObject, planets.lastObject); // The endpoint marker stays last.
                XCTAssertGreaterThanOrEqual(planets.count,5u); XCTAssertLessThanOrEqual(planets.count,7u);
                [planetCounts addObject:@(planets.count)];
                XCTAssertEqual(planets.firstObject.scale,1); XCTAssertEqual(planets.lastObject.scale,1); // Seams match.
                double lastHeading=0;
                for (NSUInteger i=1;i<planets.count;i++) {
                    CGPoint a=planets[i-1].pos,b=planets[i].pos;
                    double distance=hypot(b.x-a.x,b.y-a.y), heading=atan2(b.y-a.y,b.x-a.x)*180/M_PI;
                    shortest=fmin(shortest,distance); longest=fmax(longest,distance);
                    XCTAssertGreaterThanOrEqual(distance,(54*(planets[i-1].scale+planets[i].scale)+57.02)/.498+63.99);
                    XCTAssertLessThanOrEqual(distance,1000);
                    if (i==1 || i==planets.count-1) XCTAssertLessThanOrEqual(fabs(heading),25.01); // Gentle section seams.
                    if (i>1) { double turn=fabs(remainder(heading-lastHeading,360)); sharpest=fmax(sharpest,turn); XCTAssertLessThanOrEqual(turn,100.01); }
                    lastHeading=heading;
                    [planetScales addObject:@(planets[i].scale)];
                }
                for (LevelObjectReturner *rock in objects) if (rock.type==kasteroid) {
                    double radius=16*rock.scale/.498;
                    for (NSUInteger i=0;i<planets.count;i++) {
                        CGPoint p=planets[i].pos;
                        XCTAssertGreaterThanOrEqual(hypot(rock.pos.x-p.x,rock.pos.y-p.y),72*planets[i].scale/.498*1.3+radius+29.9); // Clear of every orbit.
                        if (i==0) continue;
                        CGPoint a=planets[i-1].pos; double dx=p.x-a.x,dy=p.y-a.y;
                        double t=fmax(0,fmin(1,((rock.pos.x-a.x)*dx+(rock.pos.y-a.y)*dy)/(dx*dx+dy*dy)));
                        XCTAssertGreaterThanOrEqual(hypot(rock.pos.x-a.x-t*dx,rock.pos.y-a.y-t*dy),100+radius-.01); // Flight corridor.
                    }
                }
                if (galaxyIndex<2) { early+=rocks; earlySections++; }
                if (galaxyIndex>=8) { late+=rocks; lateSections++; }
            }
            galaxyIndex++;
        }
    }
    XCTAssertGreaterThan(planetScales.count,10u); // Planet sizes vary.
    XCTAssertEqual(planetCounts.count,3u);         // Section lengths vary.
    XCTAssertLessThan(shortest,420); XCTAssertGreaterThan(longest,700); // Spacing varies, with long jumps.
    XCTAssertGreaterThan(sharpest,60);             // Sharp turns exist at default settings.
    XCTAssertGreaterThan(late/lateSections,1.8*early/earlySections); // Hazards ramp up across galaxies.
    XCTAssertGreaterThan(late/lateSections,18);    // Late galaxies approach the handmade maps' rock density.
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
- (void)testClosingTuningKeepsFavoritesAndRebuildsOnlyChangedRoutes {
    NSUserDefaults *d=NSUserDefaults.standardUserDefaults; NSString *domain=NSBundle.mainBundle.bundleIdentifier;
    NSDictionary *backup=[d persistentDomainForName:domain];
    SSMapSession *session=SSMapSession.shared; NSDictionary *previous=session.currentMap;
    NSURL *url=[[NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject URLByAppendingPathComponent:@"StarStreamFavoriteMaps.json"];
    NSData *favoritesBackup=[NSData dataWithContentsOfURL:url];
    void (^closeTuningWith)(NSString *, double)=^(NSString *key, double value) {
        UITableViewController *tuner=[[NSClassFromString(@"SSTuningController") alloc] initWithStyle:UITableViewStyleInsetGrouped];
        [tuner loadViewIfNeeded];
        [tuner valueForKey:@"values"][key]=@(value);
        UIBarButtonItem *done=tuner.navigationItem.rightBarButtonItem;
        [UIApplication.sharedApplication sendAction:done.action to:done.target from:done forEvent:nil];
    };
    @try {
        [d setBool:YES forKey:@"SSLocalTestingUnlock"];
        [SSTuning save:SSTuning.defaults];
        NSDictionary *favorite=[SSMapSession generateMapWithSeed:424242];
        [session selectMap:favorite];
        XCTAssertTrue([session saveCurrentMapWithScore:1]);
        closeTuningWith(@"starDensity",1.5);
        XCTAssertEqualObjects(session.currentMap,favorite); // Favorites keep their layout and tuning.

        [session selectMap:[SSMapSession generateMapWithSeed:777]];
        NSDictionary *unsaved=session.currentMap;
        closeTuningWith(@"starDensity",1.5); // Done without changes.
        XCTAssertEqualObjects(session.currentMap,unsaved);
        closeTuningWith(@"starDensity",.8);
        XCTAssertNotEqualObjects(session.currentMap,unsaved);
        XCTAssertEqualObjects(session.currentMap[@"seed"],unsaved[@"seed"]);
        XCTAssertEqualWithAccuracy([session.currentMap[@"tuning"][@"starDensity"] doubleValue],.8,.001);
    } @finally {
        if (favoritesBackup) [favoritesBackup writeToURL:url atomically:YES];
        else [NSFileManager.defaultManager removeItemAtURL:url error:nil];
        [session selectMap:previous];
        [d setPersistentDomain:backup forName:domain];
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
- (void)testRapidPickupChimesReuseVoicesAtTheOriginalPitchRange {
    SimpleAudioEngine *engine = SimpleAudioEngine.sharedEngine;
    float oldEffects = engine.effectsVolume; engine.effectsVolume = 1;
    [engine preloadEffect:@"buttonpress.mp3"];
    NSMutableSet *ids = [NSMutableSet set]; ALuint last = 0;
    for (int i = 0; i < 40; i++) { // More pickups than voices: the oldest voice is reused.
        if (last) [engine stopEffect:last];
        last = [engine playEffect:@"buttonpress.mp3" pitch:1.1 + i * .05 pan:0 gain:1];
        XCTAssertNotEqual(last, 0u);
        [ids addObject:@(last)];
    }
    XCTAssertEqual(ids.count, 40u);
    XCTAssertNotEqual([engine playEffect:@"buttonpress.mp3" pitch:3 pan:0 gain:1], 0u);
    engine.effectsVolume = oldEffects;
}
- (void)testPowerupKeepsItsGlowSpriteAfterTheAutoreleasePoolDrains {
    // An unretained glowSprite was freed in optimized builds and crashed when a powerup spawned.
    [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"generalSpritesheet.plist"];
    for (NSNumber *type in @[@(kasteroidImmunity), @(kcoinMagnet), @(kautopilot), @(kheadStart)]) {
        Powerup *powerup; __weak CCSprite *glow;
        @autoreleasepool {
            powerup = [[Powerup alloc] initWithType:type.intValue];
            glow = powerup.glowSprite;
        }
        XCTAssertNotNil(glow, @"type %@", type);
        XCTAssertEqual(glow, powerup.glowSprite);
    }
}
@end
