
//
//  MainMenuLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameplayLayer.h"
#import "Tutorial.h"
#import "UserWallet.h"
#import "PowerupManager.h"
#import "DataStorage.h"
#import "PlayerStats.h"
#import "UpgradeManager.h"
#import "GKAchievementHandler.h"
#import "HighScoresLayer.h"
#import "StoreLayer.h"

#define tutorialLayerTag    1001
#define levelLayerTag       1002
#define upgradeAlertTag     1003

const float musicVolumeMainMenu = 1;
const float effectsVolumeMainMenu = 1;

// HelloWorldLayer implementation
@implementation MainMenuLayer {
    
    BOOL muted;
    CGPoint swipeBeginPoint;
    CGPoint swipeEndPoint;
    
    CCLayer* missionPopup;
    CCLayer* missionCompletionScreen;
    CCLayer* mPopup;
    int starIntForAnimation;
    bool shouldPlayCoinSound;
    float coinPitch;
    int coinPitchCounter;
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

//- (CCLayer*)createCellWithTitle:(NSString*)title spriteName:(NSString*)spriteName readableCost:(NSString*)readableCost {

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        swipeBeginPoint = location;
        
        if (swipeBeginPoint.x >= 359 && swipeBeginPoint.x <= 440 && swipeBeginPoint.y >= 214 && swipeBeginPoint.y <= 287) {
            [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
            [missionPopup removeFromParentAndCleanup:true];
            [self enableButtons];
        }
    }
}

-(void)enableButtons {
    [highScoreButton setIsEnabled:true];
    [objectivesButton setIsEnabled:true];
    [playButton setIsEnabled:true];
    [upgradesButton setIsEnabled:true];
    [tutorialButton setIsEnabled:true];
    [soundButton setIsEnabled:true];
}

-(void)disableButtons {
    [highScoreButton setIsEnabled:false];
    [objectivesButton setIsEnabled:false];
    [playButton setIsEnabled:false];
    [upgradesButton setIsEnabled:false];
    [tutorialButton setIsEnabled:false];
    [soundButton setIsEnabled:false];
}

-(void)pressedObjectiveButton:(id)sender {
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    [Flurry logEvent:@"Pressed objective button"];
    missionPopup = [[ObjectiveManager sharedInstance] createMissionPopupWithX:true withDark:true];
    [self addChild:missionPopup];
    [self disableButtons];
}

-(void)completeObjectiveFromGroupNumber:(int)a_groupNumber itemNumber:(int)a_itemNumber {
    bool didComplete = [[ObjectiveManager sharedInstance] completeObjectiveFromGroupNumber:a_groupNumber itemNumber:a_itemNumber view:self];
    if ([[ObjectiveManager sharedInstance] checkIsDoneWithAllMissionsOnThisGroupNumber] && didComplete) {
        [self finishedAllMissions];
    }
}

// on "init" you need to initialize your instance
- (id)init {
	if (self = [super init]) {
        self.isTouchEnabled = true;
        
        layer = (CCLayer*)[CCBReader nodeGraphFromFile:@"MainMenuCCBFile.ccb" owner:self];
        
        muted = ![[PlayerStats sharedInstance] isMuted];
        [self toggleMute];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"purchase.wav"];
        
        
        NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
        
        int highScore1Int;
        int highScore2Int;
        int highScore3Int;
        int highScore4Int;
        int highScore5Int;
        int highScore6Int;
        int highScore7Int;
        int highScore8Int;
        int highScore9Int;
        
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
        if (highScores && [highScores count] > 4) {
            highScore5Int = [[highScores objectAtIndex:4] intValue];
        }
        if (highScores && [highScores count] > 5) {
            highScore6Int = [[highScores objectAtIndex:5] intValue];
        }
        if (highScores && [highScores count] > 6) {
            highScore7Int = [[highScores objectAtIndex:6] intValue];
        }
        if (highScores && [highScores count] > 7) {
            highScore8Int = [[highScores objectAtIndex:7] intValue];
        }
        if (highScores && [highScores count] > 8) {
            highScore9Int = [[highScores objectAtIndex:8] intValue];
        }
        
        if (highScore1Int != 0) {
            NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore1Int];
            [highScore1Label setString:scoreInt];
            [name1Label setString:[[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        }
        if (highScore2Int != 0) {
            NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore2Int];
            [highScore2Label setString:scoreInt];
            [name2Label setString:[[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        }
        if (highScore3Int != 0) {
            NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore3Int];
            [highScore3Label setString:scoreInt];
            [name3Label setString:[[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        }
        if (highScore4Int != 0) {
            NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore4Int];
            [highScore4Label setString:scoreInt];
            [name4Label setString:[[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        }
        if (highScore5Int != 0) {
            NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore5Int];
            [highScore5Label setString:scoreInt];
            [name5Label setString:[[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        }
        if (highScore6Int != 0) {
            NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore6Int];
            [highScore6Label setString:scoreInt];
            [name6Label setString:[[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        }
        if (highScore7Int != 0) {
            NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore7Int];
            [highScore7Label setString:scoreInt];
            [name7Label setString:[[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        }
        if (highScore8Int != 0) {
            NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore8Int];
            [highScore8Label setString:scoreInt];
            [name8Label setString:[[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        }
        if (highScore9Int != 0) {
            NSString *scoreInt = [NSString stringWithFormat:@"%d", highScore9Int];
            [highScore9Label setString:scoreInt];
            [name9Label setString:[[[PlayerStats sharedInstance] getKeyValuePairs] valueForKey:scoreInt]];
        }
        
        [proScoreLabel setString:[NSString stringWithFormat:@"%.0f",[self getProValue]]];
        [funScoreLabel setString:[NSString stringWithFormat:@"%.0f",[self getFunValue]]];
        
        if ([((AppDelegate*)[[UIApplication sharedApplication]delegate]) getCameFromUpgrades])
            [layer setPosition:ccp(-480*2, -320)];
        else
            [layer setPosition:ccp(-480, -320)];
        [self addChild:layer];
        
        if (!([((AppDelegate*)[[UIApplication sharedApplication]delegate]) getCameFromUpgrades] || [((AppDelegate*)[[UIApplication sharedApplication]delegate]) getCameFromCredits]))
            [[CDAudioManager sharedManager] playBackgroundMusic:@"menumusic_new.mp3" loop:YES];
        
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setCameFromUpgrades:false];
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setCameFromCredits:false];
	}
	return self;
}

// this is called (magically?) by cocosbuilder when the start button is pressed
- (void)startGame:(id)sender {
    [[PlayerStats sharedInstance] addPlay];
    CCLOG(@"number of plays ever: %i", [[PlayerStats sharedInstance] getPlays]);
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setChosenLevelNumber:0];
    
    /*if ([[PlayerStats sharedInstance] getPlays] == 1) {
     [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[Tutorial scene]]];
     return;
     }*/
    
    CCLOG(@"GameplayLayerScene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)pressedBackButton:(id)sender {
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(-480,-320)];
    id ease = [CCEaseInOut actionWithAction:action rate:2];
    [layer runAction: ease];
}

- (void) finishedAllMissions {
    
    
    //[self completeObjectiveFromGroupNumber:0 itemNumber:0];
    //[self completeObjectiveFromGroupNumber:0 itemNumber:1];
    //[self completeObjectiveFromGroupNumber:0 itemNumber:2];
    
    
    
    
    missionCompletionScreen = [[CCLayer alloc] init];
    
    
    CCSprite* dark = [CCSprite spriteWithFile:@"OneByOne.png"];
    [missionCompletionScreen addChild:dark];
    [dark setZOrder:-11];
    dark.position = ccp(240, 160);
    dark.color = ccBLACK;
    dark.opacity = 240;
    dark.scaleX = 480;
    dark.scaleY = 320;
    
    CCSprite* ray0 = [CCSprite spriteWithFile:@"sunray.png"];
    [missionCompletionScreen addChild:ray0];
    ray0.position = ccp(240, 160-19);
    [ray0 setVisible:false];
    
    CCSprite* ray1 = [CCSprite spriteWithFile:@"sunray.png"];
    [missionCompletionScreen addChild:ray1];
    ray1.position = ccp(240, 160-19);
    [ray1 setVisible:false];
    
    mPopup = [[CCLayer alloc] init];
    
    CCSprite* bg = [CCSprite spriteWithFile: @"popup.png"];
    [mPopup addChild:bg];
    bg.position = ccp(240, 160);
    
    CCLabelTTF* missionLabel = [CCLabelTTF labelWithString:@"CURRENT MISSIONS" fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
    [mPopup addChild:missionLabel];
    missionLabel.position = ccp(240, 246);
    
    NSMutableArray* objectivesAtThisLevel = [[ObjectiveManager sharedInstance] getObjectivesFromGroupNumber:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
    
    ObjectiveGroup* currentGroup = [[[ObjectiveManager sharedInstance] objectiveGroups] objectAtIndex:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
    
    
    //CCSprite* ind0 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:0]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
    //CCSprite* ind1 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:1]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
    //CCSprite* ind2 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:2]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
    CCSprite* ind0 = [CCSprite spriteWithFile:@"yousuck.png"];
    CCSprite* ind1 = [CCSprite spriteWithFile:@"yousuck.png"];
    CCSprite* ind2 = [CCSprite spriteWithFile:@"yousuck.png"];
    [mPopup addChild:ind0];
    [mPopup addChild:ind1];
    [mPopup addChild:ind2];
    ind0.position = ccp(108, 211);
    ind1.position = ccp(108, 161);
    ind2.position = ccp(108, 112);
    
    CCLabelTTF* label0 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:0]) text] dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    CCLabelTTF* label1 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:1]) text] dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    CCLabelTTF* label2 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:2]) text] dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    [mPopup addChild:label0];
    [mPopup addChild:label1];
    [mPopup addChild:label2];
    label0.position = ccp(label0.boundingBox.size.width/2 + 134, 211);
    label1.position = ccp(label1.boundingBox.size.width/2 + 134, 161);
    label2.position = ccp(label2.boundingBox.size.width/2 + 134, 112);
    
    
    
    NSString* footerString = [NSString stringWithFormat:@"COMPLETE TO EARN %@", [self commaInt:currentGroup.starReward]];
    
    CCLabelTTF* footer = [CCLabelTTF labelWithString:footerString fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    [mPopup addChild:footer];
    footer.position = ccp(240, 74);
    
    CCSprite* starSprite0 = [CCSprite spriteWithFile:@"staricon.png"];
    [mPopup addChild:starSprite0];
    starSprite0.scale = .42;
    starSprite0.position = ccpAdd(footer.position, ccp(footer.boundingBox.size.width/2 + 12, 2));
    
    
    [missionCompletionScreen addChild:mPopup];
    mPopup.position = ccp(-480, -19);
    
    CCParticleSystemQuad* checkExplosion = [CCParticleSystemQuad particleWithFile:@"checkmarkExplosionParticle.plist"];
    [missionCompletionScreen addChild:checkExplosion];
    [checkExplosion stopSystem];
    
    CCParticleSystemQuad* starExplosion = [CCParticleSystemQuad particleWithFile:@"starStashParticle.plist"];
    [missionCompletionScreen addChild:starExplosion];
    [starExplosion stopSystem];
    
    shouldPlayCoinSound = true;
    coinPitch = .8;
    coinPitchCounter = 0;
    
    CCLayer* starsLayer = [[CCLayer alloc] init];
    [missionCompletionScreen addChild:starsLayer];
    starsLayer.position = ccp(240, 320 + 30);
    [starsLayer setAnchorPoint:ccp(0, 0)];
    
    starIntForAnimation = [[UserWallet sharedInstance] getBalance];
    CCLabelTTF* starCountLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%@", [self commaInt:starIntForAnimation]] fontName:@"HelveticaNeue-CondensedBold" fontSize:48];
    starCountLabel.color = ccYELLOW;
    [starsLayer addChild:starCountLabel];
    starCountLabel.position = ccp(0, 0);//ccp(240, 320 + starCountLabel.boundingBox.size.height);
    
    CCSprite* starSprite = [CCSprite spriteWithFile:@"staricon.png"];
    [starsLayer addChild:starSprite];
    starSprite.position = ccp(starCountLabel.boundingBox.size.width/2 + 20, 4);
    
    
    int finalScore = [[UserWallet sharedInstance] getBalance] + [[ObjectiveManager sharedInstance] getStarRewardFromGroupNumber:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
    
    int rateOfScoreIncrease = (finalScore-[[UserWallet sharedInstance] getBalance]) / 100;
    
    id changeChecks = [CCSequence actions:
                       
                       [CCCallBlock actionWithBlock:(^{
    })],
                       
                       [CCDelayTime actionWithDuration:.2],
                       
                       [CCCallBlock actionWithBlock:(^{
        [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
        [checkExplosion setPosition:ccpSub(ind0.position, ccp(0, ind0.boundingBox.size.height/2))];
        [checkExplosion resetSystem];
        [ind0 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"missioncomplete.png"]];
    })],
                       
                       [CCDelayTime actionWithDuration:1],
                       
                       [CCCallBlock actionWithBlock:(^{
        [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
        [checkExplosion setPosition:ccpSub(ind1.position, ccp(0, ind1.boundingBox.size.height/2))];
        [checkExplosion resetSystem];
        [ind1 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"missioncomplete.png"]];
    })],
                       
                       [CCDelayTime actionWithDuration:1],
                       
                       [CCCallBlock actionWithBlock:(^{
        [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
        [checkExplosion setPosition:ccpSub(ind2.position, ccp(0, ind2.boundingBox.size.height/2))];
        [checkExplosion resetSystem];
        [ind2 setTexture:[[CCTextureCache sharedTextureCache] addImage:@"missioncomplete.png"]];
    })],
                       
                       [CCDelayTime actionWithDuration:.4],
                       
                       [CCCallBlock actionWithBlock:(^{
        [starsLayer runAction:[CCEaseBounceInOut actionWithAction:[CCMoveTo actionWithDuration:.7 position:ccp(240, 284)]]];
    })],
                       
                       [CCDelayTime actionWithDuration:.7],
                       
                       [CCCallBlock actionWithBlock:(^{
        /*while (starInt < [[UserWallet sharedInstance] getBalance] + [[ObjectiveManager sharedInstance] getStarRewardFromGroupNumber:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]]) {
         [starCountLabel setString:[NSString stringWithFormat:@"%@", [self commaInt:starInt]]];
         }*/
        
        
        
        id increaseNumber = [CCCallBlock actionWithBlock:(^{
            if (shouldPlayCoinSound)
                [self playSound:@"buttonpress.mp3" shouldLoop:false pitch:coinPitch];
            [self addToStarInt: [self RandomBetween:rateOfScoreIncrease-1 maxvalue:rateOfScoreIncrease+1]];
            [starCountLabel setString:[NSString stringWithFormat:@"%@",[self commaInt:starIntForAnimation]]];
        })];
        id setNumber = [CCCallBlock actionWithBlock:(^{
            [starCountLabel setString:[NSString stringWithFormat:@"%@", [self commaInt:finalScore]]];
        })];
        id displayParticles = [CCCallBlock actionWithBlock:(^{
            [starExplosion setPosition:starsLayer.position];
            [starExplosion resetSystem];
            [[UserWallet sharedInstance] setBalance:finalScore];
            
            [starsLayer runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                                         [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.4 scale:1.3]],
                                                                         [CCEaseSineInOut actionWithAction:[CCScaleTo actionWithDuration:.4 scale:1]],
                                                                         nil]
                                       ]];
            })];
        
        
        
        
        
        
        [starCountLabel runAction:[CCSequence actions:[CCRepeat actionWithAction:[CCSequence actions:increaseNumber,
                                                                                  [CCDelayTime actionWithDuration:.0166667],
                                                                                  nil] times:(finalScore-[[UserWallet sharedInstance] getBalance])/rateOfScoreIncrease],setNumber,displayParticles,
                                   
                                   [CCDelayTime actionWithDuration:.3],
                                   
                                   
                                   
                                   [CCCallBlock actionWithBlock:(^{
            [mPopup runAction:[CCEaseSineIn actionWithAction:[CCMoveTo actionWithDuration:.7 position:ccp(480, -19)]]];
            [[ObjectiveManager sharedInstance] setCurrentObjectiveGroupNumber: [[ObjectiveManager sharedInstance] currentObjectiveGroupNumber] + 1];
        })],
                                   
                                   [CCDelayTime actionWithDuration:.5],
                                   
                                   [CCCallBlock actionWithBlock:(^{
            [self createNewPopup];
            [missionCompletionScreen addChild:mPopup];
            [mPopup runAction:[CCEaseElasticInOut actionWithAction:[CCMoveTo actionWithDuration:1.1 position:ccp(0, -19)]]];
        })],
                                   
                                   [CCDelayTime actionWithDuration:.35],
                                   
                                   [CCCallBlock actionWithBlock:(^{
            
            [self playSound:@"popupSwoosh.mp3" shouldLoop:false pitch:1];
        })],
                                   
                                   [CCDelayTime actionWithDuration:1-.35],
                                   
                                   [CCCallBlock actionWithBlock:(^{
            [ray0 setRotation:.5];
            [ray0 setZOrder:-1];
            [ray0 setScale:4];
            [ray0 setOpacity:150];
            [ray0 setVisible:true];
            [ray0 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:.01666667 angle:.5]]];
            
            [ray1 setZOrder:-1];
            [ray1 setScale:4];
            [ray1 setOpacity:150];
            [ray1 setVisible:true];
            [ray1 runAction:[CCRepeatForever actionWithAction:[CCRotateBy actionWithDuration:.01666667 angle:-.5]]];
            
        })],
                                   
                                   
                                   [CCDelayTime actionWithDuration:.5],
                                   
                                   
                                   
                                   [CCCallBlock actionWithBlock:(^{
            CCMenuItem *quit = [CCMenuItemImage
                                itemWithNormalImage:@"cancel.png" selectedImage:@"cancelpressed.png"
                                target:self selector:@selector(pushedContinueButton)];
            quit.position = ccp(336, -quit.boundingBox.size.height);
            [quit runAction:[CCEaseBounceInOut actionWithAction:[CCMoveTo actionWithDuration:.7 position:ccp(336, 20)]]];
            
            
            CCMenu* menu = [CCMenu menuWithItems:quit, nil];
            menu.position = ccp(0, 0);
            [missionCompletionScreen addChild:menu];
        })],
                                   
                                   
                                   nil]];
        
        
        
    })],
                       
                       
                       
                       nil];
    
    //id stuffAfterExplosion = [CCSequence actions:
    
    
    
    
    [mPopup runAction: [CCSequence actions:
                        [CCEaseElasticInOut actionWithAction:[CCMoveTo actionWithDuration:1.1 position:ccp(0, -19)]],
                        
                        changeChecks,
                        nil]];
    
    [mPopup runAction: [CCSequence actions:
                        
                        [CCDelayTime actionWithDuration:.35],
                        
                        [CCCallBlock actionWithBlock:(^{
        
        [self playSound:@"popupSwoosh.mp3" shouldLoop:false pitch:1];
    })],
                        
                        [CCDelayTime actionWithDuration:.6-.35],
                        
                        [CCCallBlock actionWithBlock:(^{
        
        //[self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    })],
                        nil]];
    
    
    
    /*
     id moveLoadingLabelToStartPosition = [CCCallBlock actionWithBlock:(^{
     [loadingHelperTextLabel setPosition:startPosition];
     })];
     
     id repeatScrollingLeftAction = [CCCallBlock actionWithBlock:(^{
     [loadingHelperTextLabel runAction: [CCRepeatForever actionWithAction:[CCSequence actions:
     [CCMoveTo actionWithDuration:loadingHelperLabelMoveTime*loadingHelperTextLabel.boundingBox.size.width/529.313538 position:ccp(-loadingHelperTextLabel.boundingBox.size.width-20,loadingHelperTextLabel.position.y)],
     moveLoadingLabelToStartPosition,
     nil]]];
     })];
     */
    
    
    [self addChild:missionCompletionScreen];
    self.isTouchEnabled = false;
    [self disableButtons];
}

- (void)pressedStoreButton:(id)sender {
    
    
    [Flurry logEvent:@"Opened Store" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[UserWallet sharedInstance] getBalance]],@"Coin Balance" ,nil]];
    
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    [[CCDirector sharedDirector] replaceScene:[StoreLayer scene]];
    
    
    //id action = [CCMoveTo actionWithDuration:.8f position:ccp(-960,-320)];
    //id ease = [CCEaseSineInOut actionWithAction:action]; //does this "CCEaseSineInOut" look better than the above "CCEaseInOut"???
    //[layer runAction: ease];
}

-(void)createNewPopup {
    mPopup = [[ObjectiveManager sharedInstance] createMissionPopupWithX:false withDark:false];
    
    mPopup.position = ccp(-480, -19);
}

- (void) addToStarInt:(int)whatToAdd {
    starIntForAnimation += whatToAdd;
    coinPitchCounter++;
    if (coinPitchCounter >= 11) {
        coinPitchCounter = 0;
        coinPitch += .12;
        shouldPlayCoinSound = true;
    } else {
        shouldPlayCoinSound = false;
    }
}

- (void) pushedContinueButton {
    [missionCompletionScreen removeFromParentAndCleanup:true];
    self.isTouchEnabled = true;
    [self enableButtons];
}

- (void)pressedLeaderboardsButton:(id)sender {
    [Flurry logEvent:@"Opened gamecenter leaderboards"];
    /*  GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
     leaderboardViewController.leaderboardDelegate = self;
     
     AppDelegate *app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
     
     [[app navController] presentModalViewController:leaderboardViewController animated:YES];
     */
    // [[DDGameKitHelper sharedGameKitHelper]showLeaderboardwithCategory:@"highscore_leaderboard" timeScope:GKLeaderboardTimeScopeAllTime];
    [[DDGameKitHelper sharedGameKitHelper]showLeaderboard];
    
}

- (int)getHighestScore {
    NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
    int highestScore = 0;
    for (int i = 0 ; i < highScores.count ; i++) {
        NSNumber * highscoreObject = [highScores objectAtIndex:i];
        int score = [highscoreObject intValue];
        if (score>highestScore)
            highestScore=score;
    }
    return highestScore;
}

-(float) getProValue {
    float x = ((float)[self getHighestScore])/1000;
    float value = (-50*cosf(x/35)+50)*100/95;
    if (isnan(value))
        return 0;
    else return value;
}

-(float)getFunValue {
    float funValue = [self getProValue];
    NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
    float numScores = 0;
    for (int i = 0 ; i < highScores.count ; i++) {
        NSNumber * highscoreObject = [highScores objectAtIndex:i];
        if (highscoreObject&&highscoreObject.intValue >0)
            numScores++;
    }
    float numPlays = [[PlayerStats sharedInstance]getPlays];
    funValue+= 2.8*numScores + .5*numPlays;
    if (isnan(funValue))
        return 0;
    else return funValue;
}

- (void)pressedScoresButton:(id)sender {
    /*
     NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
     NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc]init];
     NSMutableDictionary * keyValuePairs = [[PlayerStats sharedInstance] getKeyValuePairs];
     for (int i = 0 ; i < highScores.count ; i++) {
     NSNumber * highscoreObject = [highScores objectAtIndex:i];
     NSString *scoreInt = [NSString stringWithFormat:@"%d", [highscoreObject intValue]];
     NSString *scoreName = [keyValuePairs valueForKey:scoreInt ];
     if (!scoreName) scoreName = @"null";
     [parameterDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:highscoreObject,scoreName, nil]];
     }
     //  NSDictionary *parameterDict2 = [NSDictionary dictionaryWithObjectsAndKeys:highScores.description,@"Scores", nil];
     
     [Flurry logEvent:@"Opened High Scores" withParameters:parameterDict];
     id action = [CCMoveTo actionWithDuration:.8f position:ccp(0,-320)];
     id ease = [CCEaseSineInOut actionWithAction:action];
     [layer runAction: ease];*/
    
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    [[CCDirector sharedDirector] replaceScene:[HighScoresLayer scene]];
}
- (void)pressedLevelsButton: (id) sender {
    [Flurry logEvent:@"Pressed Levels Button"];
    CCLOG(@"levels layer launched");
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(0,0)];
    id ease = [CCEaseSineInOut actionWithAction:action];
    [layer runAction: ease];
    
}

-(void)moveLevelsLayerRight {
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(layer.position.x-480,0)];
    id ease = [CCEaseSineInOut actionWithAction:action];
    [layer runAction: ease];
}

-(void)moveLevelsLayerLeft {
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(layer.position.x+480,0)];
    id ease = [CCEaseSineInOut actionWithAction:action];
    [layer runAction: ease];
}

- (void)startLevelNumber:(int)levelNum {
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setChosenLevelNumber:levelNum];
    NSLog(@"started level %d",levelNum);
    [Flurry logEvent:[NSString stringWithFormat:@"Started Level %d",levelNum]];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

-(void)startLevel1{
    [self startLevelNumber:1];
}
-(void)startLevel2{
    [self startLevelNumber:2];
}

- (void)pressedSendFeedback: (id) sender {
    [TestFlight passCheckpoint:@"pressed survey button on main menu"];
    [Flurry logEvent:@"Pressed Survey Button on main menu"];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Entering survey"
                          message: @"Thanks for taking the time to answer our survey! Any input is helpful. \n-Clay, Alex, Jeff, and Michael.\n\nIf you want to take the survey on your computer, type in this URL: tinyurl.com/stardashsurvey"
                          delegate: self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Continue",nil];
    [alert show];
    
}

- (void)pressedTutorialButton: (id) sender {
    [TestFlight passCheckpoint:@"Opened tutorial"];
    [Flurry logEvent:@"Pressed Tutorial Button"];
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:TRUE];
    CCLOG(@"tutorial scene launched, game starting");
    
    [[PlayerStats sharedInstance] addPlay];
    
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[Tutorial scene]]];
    
    //tutorialLayer = (CCLayer*)[CCBReader nodeGraphFromFile:@"TutorialLayer.ccb" owner:self];
    //[tutorialLayer setTag:tutorialLayerTag];
    //[self addChild:tutorialLayer];
    
    // [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)pressedRocketTrailsButton: (id) sender {
    [Flurry logEvent:@"Pressed Rocket Trails Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:0];
    [self pressedAnUpgradeButton];
}

//- (void)pressedRocketShipsButton: (id) sender {
//    [Flurry logEvent:@"Pressed Rocketships Button"];
//    [[UpgradeManager sharedInstance] setButtonPushed:1];
//    [self pressedAnUpgradeButton];
//}

- (void)pressedCreditsButton {
    [self finishedAllMissions];
    //[self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    //[[CCDirector sharedDirector] replaceScene:[CreditsLayer scene]];
}

- (void)pressedRocketShipsButton: (id) sender {
    [Flurry logEvent:@"Pressed Rocketships Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:1];
    [self pressedAnUpgradeButton];
}

- (void)pressedUpgradesButton: (id) sender {
    [Flurry logEvent:@"Pressed Upgrades Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:2];
    [self pressedAnUpgradeButton];
}

- (void)pressedPowerupsButton: (id) sender {
    [Flurry logEvent:@"Pressed Powerups Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:3];
    [self pressedAnUpgradeButton];
}

- (void)pressedStarsButton: (id) sender {
    [Flurry logEvent:@"Pressed Stars Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:4];
    [self pressedAnUpgradeButton];
}

- (void)pressedPerksButton: (id) sender {
    [Flurry logEvent:@"Pressed Perks Button"];
    [[UpgradeManager sharedInstance] setButtonPushed:5];
    [self pressedAnUpgradeButton];
}

- (void)pressedAnUpgradeButton {
    
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    [[CCDirector sharedDirector] replaceScene:[UpgradesLayer scene]];//[CCTransitionCrossFade transitionWithDuration:0.5 scene:[UpgradesLayer scene]]];
}

- (void)removeTutorialLayer {
    [self removeChildByTag:tutorialLayerTag cleanup:NO];
}

- (void)toggleMute {
    muted = !muted;
    if (!muted) {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:musicVolumeMainMenu];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:effectsVolumeMainMenu];
        [soundButton setNormalImage:[CCSprite spriteWithFile:@"sound.png"]];
        [soundButton setSelectedImage:[CCSprite spriteWithFile:@"soundpressed.png"]];
        [soundButton setDisabledImage:[CCSprite spriteWithFile:@"sound.png"]];
    } else {
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0];
        [[SimpleAudioEngine sharedEngine] setEffectsVolume:0];
        [soundButton setNormalImage:[CCSprite spriteWithFile:@"soundmuted.png"]];
        [soundButton setSelectedImage:[CCSprite spriteWithFile:@"soundmutedpressed.png"]];
        [soundButton setDisabledImage:[CCSprite spriteWithFile:@"soundmuted.png"]];
    }
    [[PlayerStats sharedInstance] setIsMuted:muted];
}

- (NSString*)commaInt:(int)num {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}

- (ALuint)playSound:(NSString*)soundFile shouldLoop:(bool)shouldLoop pitch:(float)pitch{
    //[Kamcord playSound:soundFile loop:shouldLoop];
    if (shouldLoop)
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:soundFile loop:YES];
    else
        return [[SimpleAudioEngine sharedEngine]playEffect:soundFile pitch:pitch pan:0 gain:1];
    return 0;
}



- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue  {
    int randomNumber = minvalue+  arc4random() % (1+maxvalue-minvalue);
    return randomNumber;
}

/*
 #pragma mark GameKit delegate
 
 -(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
 {
 AppDelegate *app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
 [[app navController] dismissModalViewControllerAnimated:YES];
 }
 
 -(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
 {
 AppDelegate *app = (AppDelegate*) [[UIApplication sharedApplication] delegate];
 [[app navController] dismissModalViewControllerAnimated:YES];
 }*/

@end
