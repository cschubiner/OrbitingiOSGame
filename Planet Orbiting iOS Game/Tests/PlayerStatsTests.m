#import <XCTest/XCTest.h>
#import "PlayerStats.h"
#import "SimpleAudioEngine.h"
#import "DataStorage.h"
#import "UpgradeManager.h"
#import "UpgradeItem.h"
#import "UserWallet.h"
#import "ObjectiveManager.h"
@interface PlayerStatsTests : XCTestCase
@end
@implementation PlayerStatsTests
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
