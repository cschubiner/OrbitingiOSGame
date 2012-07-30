//
//  MainMenuLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameplayLayer.h"
#import "StoreItem.h"
#import "StoreManager.h"
#import "UserWallet.h"
#import "PowerupManager.h"
#import "DataStorage.h"
#import "PlayerStats.h"

const float musicVolumeMainMenu = 1;
const float effectsVolumeMainMenu = 1;

// HelloWorldLayer implementation
@implementation MainMenuLayer {
    StoreManager *storeManager;
    BOOL muted;

}

// returns a singleton scene
+ (CCScene *)scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (void)updateLabels {
    int coins = [[UserWallet sharedInstance] getBalance];
    NSString *coinsBalance = [NSString stringWithFormat:@"Balance: %i coins", coins];
    NSLog(@"%@", coinsBalance);
    [coinBalanceLabel setString:coinsBalance];
    
    int magnets = [[PowerupManager sharedInstance] numMagnet];
    NSString *magnetsBought = [NSString stringWithFormat:@"%i", magnets];
    NSLog(@"%@", magnetsBought);
    [numMagnetsLabel setString:magnetsBought];
    
    int immunities = [[PowerupManager sharedInstance] numImmunity];
    NSString *immunitiesBought = [NSString stringWithFormat:@"%i", immunities];
    NSLog(@"%@", immunitiesBought);
    [numImmunitiesLabel setString:immunitiesBought];
}

// on "init" you need to initialize your instance
- (id)init {
	if (self = [super init]) {
        [self updateLabels];
        
        layer = (CCLayer*)[CCBReader nodeGraphFromFile:@"MainMenuScrolling.ccb" owner:self];
        
        NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
        
        int highScore1Int;
        int highScore2Int;
        int highScore3Int;
        int highScore4Int;
        
        if (highScores && [highScores count] > 0) {
            highScore1Int = [[highScores objectAtIndex:0] intValue];
        }
        if (highScores && [highScores count] > 1) {
            highScore2Int = [[highScores objectAtIndex:1] intValue];
        }
        if (highScores && [highScores count] > 2) {
            highScore3Int = [[highScores objectAtIndex:2] intValue];
        }
        if (highScores && [highScores count] > 3) {
            highScore4Int = [[highScores objectAtIndex:3] intValue];
        }
        
        if (highScore1Int != 0) {
            [highScore1Label setString:[NSString stringWithFormat:@"%i", highScore1Int]];
        }
        if (highScore2Int != 0) {
            [highScore2Label setString:[NSString stringWithFormat:@"%i", highScore2Int]];
        }
        if (highScore3Int != 0) {
            [highScore3Label setString:[NSString stringWithFormat:@"%i", highScore3Int]];
        }
        if (highScore4Int != 0) {
            [highScore4Label setString:[NSString stringWithFormat:@"%i", highScore4Int]];
        }
        
        [layer setPosition:ccp(-480, 0)];
        [self addChild:layer];
        
        [[CDAudioManager sharedManager] playBackgroundMusic:@"menumusic_new.mp3" loop:YES];
        [[UIApplication sharedApplication]setStatusBarOrientation:[[UIApplication sharedApplication]statusBarOrientation]];
        
        storeManager = [[StoreManager alloc] init];
        
        StoreItem *magnet = [[StoreItem alloc] init];
        magnet.itemID = 0;
        magnet.title = @"Magnet";
        magnet.price = 20;
        magnet.description = @"Pull coins toward you as you fly.";
        
        StoreItem *immunity = [[StoreItem alloc] init];
        immunity.itemID = 1;
        immunity.title = @"Immunity";
        immunity.price = 50;
        immunity.description = @"Become temporarily invincible to asteroids.";
        
        [storeManager.storeItems addObject:magnet];
        [storeManager.storeItems addObject:immunity];
	}
	return self;
}

- (void)magnetButtonPressed {
    int currCoins = [[UserWallet sharedInstance] getBalance];
    CCLOG(@"magnetButtonPressed");
    [storeManager purchaseItemWithID:0];
    int newCoins = [[UserWallet sharedInstance] getBalance];
    if (currCoins - newCoins == [[storeManager.storeItems objectAtIndex:0] price]) {
        [[PowerupManager sharedInstance] addMagnet];
    }
    [self updateLabels];
}

- (void)immunityButtonPressed {
    int currCoins = [[UserWallet sharedInstance] getBalance];
    CCLOG(@"immunityButtonPressed");
    [storeManager purchaseItemWithID:1];
    int newCoins = [[UserWallet sharedInstance] getBalance];
    if (currCoins - newCoins == [[storeManager.storeItems objectAtIndex:1] price]) {
        [[PowerupManager sharedInstance] addImmunity];
    }
    [self updateLabels];
}

// this is called (magically?) by cocosbuilder when the start button is pressed
- (void)startGame:(id)sender {
    [[PlayerStats sharedInstance] addPlay];
    CCLOG(@"number of plays ever: %i", [[PlayerStats sharedInstance] getPlays]);

    if ([[PlayerStats sharedInstance] getPlays] == 1) {
        [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:TRUE];
    }
    else [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:FALSE];

    [[UIApplication sharedApplication]setStatusBarOrientation:[[UIApplication sharedApplication]statusBarOrientation]];
    CCLOG(@"GameplayLayerScene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)pressedBackButton:(id)sender {
    [Flurry logEvent:@"Went back to menu from store"];
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(-480,0)];
    id ease = [CCEaseInOut actionWithAction:action rate:2];
    [layer runAction: ease];
}

- (void)pressedStoreButton:(id)sender {
    [self updateLabels];
    [Flurry logEvent:@"Opened Store"];
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(-960,0)];
    id ease = [CCEaseSineInOut actionWithAction:action]; //does this "CCEaseSineInOut" look better than the above "CCEaseInOut"???
    [layer runAction: ease];
}

- (void)pressedScoresButton:(id)sender {
    [self updateLabels];
    [Flurry logEvent:@"Opened High Scores"];
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(0,0)];
    id ease = [CCEaseSineInOut actionWithAction:action];
    [layer runAction: ease];
}

- (void)pressedSendFeedback: (id) sender {
    [Flurry logEvent:@"Pressed Send Feedback"];
    [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [TestFlight openFeedbackView];
}

- (void)pressedTutorialButton: (id) sender {
    [Flurry logEvent:@"Pressed Tutorial Button"];
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:TRUE];
    [[UIApplication sharedApplication]setStatusBarOrientation:[[UIApplication sharedApplication]statusBarOrientation]];
    CCLOG(@"gameplayLayer scene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)toggleMute {
    muted = !muted;
    if (!muted) {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:musicVolumeMainMenu];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:effectsVolumeMainMenu];
    } else {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
    }
}

- (void)dealloc {
	[super dealloc];
}

@end