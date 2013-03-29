
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
#import "MissionsCompleteLayer.h"
#import "UpgradeValues.h"
#import "UpgradeManager.h"
#import "UpgradeItem.h"

#define tutorialLayerTag    1001
#define levelLayerTag       1002
#define upgradeAlertTag     1003

const float musicVolumeMainMenu = 1;
const float effectsVolumeMainMenu = 1;

@implementation MainMenuLayer {
    BOOL muted;
    CGPoint swipeBeginPoint;
    CGPoint swipeEndPoint;
    CCLabelBMFont* beginLabel;
    bool missionPopupIsUp;
    
    CCLayer* missionPopup;
    
    CGPoint position;
    CGPoint velocity;
    CGPoint acceleration;
    CGPoint difVector;
    CCSprite* dark;
    bool isDoingEndAnimation;
    bool startAnimation;
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

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1)
        [self openVideo];
    else {
        [self tappedToStart];
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        
        CGPoint location = [touch locationInView:[touch view]];
        location = [[CCDirector sharedDirector] convertToGL:location];
        swipeBeginPoint = location;
        
        float numToAdd = (IS_IPHONE_5 ? 44 : 0);
        if (swipeBeginPoint.x >= 359 + numToAdd && swipeBeginPoint.x <= 440 + numToAdd && swipeBeginPoint.y >= 214 && swipeBeginPoint.y <= 287 && missionPopupIsUp) {
            missionPopupIsUp = false;
            [self playSound:@"doorClose2.mp3" shouldLoop:false pitch:1];
            [missionPopup removeFromParentAndCleanup:true];
            [self enableButtons];
            return;
        }
        
        if (swipeBeginPoint.y >= 40 && objectivesButton.isEnabled && beginLabel.visible) {
            
            if ([[iRate sharedInstance]eventCount] >= 12 && [[PlayerStats sharedInstance] hasWatchedVideo] == 0) {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Star Stream Tutorial"
                                                                  message:@"We see you're getting into Star Stream. Would you like to watch the trailer to see how a pro plays? It'll improve your performance a lot!"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Play Game"
                                                        otherButtonTitles:@"Watch Video",nil];
                [message show];
                return;
            }
            
            [self tappedToStart];
        }
        
        
    }
    
//[[self.myPlayer view]removeFromSuperview];
}

-(void)enableButtons {
    [highScoreButton setIsEnabled:true];
    [objectivesButton setIsEnabled:true];
    [creditsButton setIsEnabled:true];
    [upgradesButton setIsEnabled:true];
    [soundButton setIsEnabled:true];
}

-(void)disableButtons {
    [highScoreButton setIsEnabled:false];
    [objectivesButton setIsEnabled:false];
    [creditsButton setIsEnabled:false];
    [upgradesButton setIsEnabled:false];
    [soundButton setIsEnabled:false];
}



- (void)willEnterFullscreen:(NSNotification*)notification {
    NSLog(@"willEnterFullscreen");
}

- (void)enteredFullscreen:(NSNotification*)notification {
    NSLog(@"enteredFullscreen");
}

- (void)willExitFullscreen:(NSNotification*)notification {
    NSLog(@"willExitFullscreen");
    //SET PLAYER_HAS_ALREADY_WATCHED_THE_VIDEO TO TRUE
    [self.myPlayer.view removeFromSuperview];
    self.myPlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];


}

- (void)exitedFullscreen:(NSNotification*)notification {
    NSLog(@"exitedFullscreen");
    [self.myPlayer.view removeFromSuperview];
    self.myPlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playbackFinished:(NSNotification*)notification {
  /*  NSNumber* reason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    switch ([reason intValue]) {
        case MPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackFinished. Reason: Playback Ended");
            break;
        case MPMovieFinishReasonPlaybackError:
            NSLog(@"playbackFinished. Reason: Playback Error");
            break;
        case MPMovieFinishReasonUserExited:
            NSLog(@"playbackFinished. Reason: User Exited");
            break;
        default:
            break;
    }*/
    [self.myPlayer setFullscreen:NO animated:YES];
}

-(void)openVideo{
    NSURL *url = [NSURL URLWithString:@"http://www.weebly.com/uploads/1/6/2/0/16201940/tutorial_video.m4v"];//@"http://www.youtube.com/watch?v=-qHD9SO9F_0"];
    
    [[PlayerStats sharedInstance] setHasWatchedVideo:1];
    
    MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:url];
    player.movieSourceType = MPMovieSourceTypeUnknown;
    
    [player prepareToPlay];
    [player.view setFrame:CGRectMake(0, 0, 200, 300)];
    
    player.shouldAutoplay=YES;
    
    
    player.controlStyle = MPMovieControlStyleEmbedded;
    
    [player setFullscreen:YES animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullscreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:self.myPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullscreen:) name:MPMoviePlayerWillExitFullscreenNotification object:self.myPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enteredFullscreen:) name:MPMoviePlayerDidEnterFullscreenNotification object:self.myPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(exitedFullscreen:) name:MPMoviePlayerDidExitFullscreenNotification object:self.myPlayer];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.myPlayer];
    
    
    addedMoviePlayerObserver= YES;
    //   player.view.hidden = YES;
    
    
    self.myPlayer = player;
    //   [player setFullscreen:YES];
    [[[CCDirector sharedDirector] view] addSubview:self.myPlayer.view];
    
    
    if(player){
        [self.myPlayer play];
        player.view.hidden = NO;
    }
    
    int count = 0;
    while (player.fullscreen == NO){
        [    player setFullscreen:YES];
        count++;
        if (count > 1000)
            break;
    }
    
}

-(void)pressedObjectiveButton:(id)sender {
    missionPopupIsUp = true;
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    [Flurry logEvent:@"Pressed objective button"];
    missionPopup = [[ObjectiveManager sharedInstance] createMissionPopupWithX:true withDark:true];
    [missionPopup setZOrder:INT_MAX];
    [self addChild:missionPopup];
    [self disableButtons];
}

- (void) initUpgradeStuff {
    
}

// on "init" you need to initialize your instance
- (id)init {
	if (self = [super init]) {
        addedMoviePlayerObserver = false;
        self.myPlayer = NULL;
        

        size = [[CCDirector sharedDirector] winSize];
        self.isTouchEnabled = true;
        
        layer = (CCLayer*)[CCBReader nodeGraphFromFile:@"MainMenuCCBFile.ccb" owner:self];
        if (IS_IPHONE_5)
        layer.position = ccpAdd(layer.position, ccp(HALF_IPHONE_5_ADDITIONAL_WIDTH,0));
        muted = ![[PlayerStats sharedInstance] isMuted];
        [self toggleMute];
        
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"purchase.wav"];
        
//        beginLabel = [CCLabelTTF labelWithString:@"TAP ANYWHERE TO BEGIN!" fontName:@"HelveticaNeue-CondensedBold" fontSize:22];
        beginLabel = [CCLabelBMFont labelWithString:@"TAP ANYWHERE TO BEGIN!" fntFile:@"score_label_font.fnt"];
        [beginLabel setScale:.68];
        [self addChild: beginLabel];
        [beginLabel setZOrder:INT_MAX-1];
        
        if (IS_IPHONE_5)
        [beginLabel setPosition:ccp(240+HALF_IPHONE_5_ADDITIONAL_WIDTH, 60)];
        else
        [beginLabel setPosition:ccp(240, 60)];
        [beginLabel setVisible:false];
        
        @try {
            if ([[DDGameKitHelper sharedGameKitHelper]isLocalPlayerAuthenticated]==false) {
                [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setdidGetToMainMenu:false];

                [[DDGameKitHelper sharedGameKitHelper]authenticateLocalPlayer];
   
            }
            else [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setdidGetToMainMenu:true];


        }
        @catch (NSException *exception) {
        }
        
        [[UpgradeValues sharedInstance] setHasGreenShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:17] equipped]];
        [[UpgradeValues sharedInstance] setHasBlueShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:18] equipped]];
        [[UpgradeValues sharedInstance] setHasGoldShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:19] equipped]];
        [[UpgradeValues sharedInstance] setHasOrangeShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:20] equipped]];
        [[UpgradeValues sharedInstance] setHasRedShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:21] equipped]];
        [[UpgradeValues sharedInstance] setHasPurpleShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:22] equipped]];
        [[UpgradeValues sharedInstance] setHasPinkShip:[[[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:23] equipped]];
        
        
        CCSprite* newSprite;
        if ([[UpgradeValues sharedInstance] hasGreenShip]) {
            newSprite = [CCSprite spriteWithFile:@"playercamo.png"];
        } else if ([[UpgradeValues sharedInstance] hasBlueShip]) {
            newSprite = [CCSprite spriteWithFile:@"playeramerica.png"];
        } else if ([[UpgradeValues sharedInstance] hasGoldShip]) {
            newSprite = [CCSprite spriteWithFile:@"playerbacon.png"];
        } else if ([[UpgradeValues sharedInstance] hasOrangeShip]) {
            newSprite = [CCSprite spriteWithFile:@"playerhappy.png"];
        } else if ([[UpgradeValues sharedInstance] hasRedShip]) {
            newSprite = [CCSprite spriteWithFile:@"playertrippy.png"];
        } else if ([[UpgradeValues sharedInstance] hasPurpleShip]) {
            newSprite = [CCSprite spriteWithFile:@"playershark.png"];
        } else if ([[UpgradeValues sharedInstance] hasPinkShip]) {
            newSprite = [CCSprite spriteWithFile:@"playermenu.png"];
            newSprite.color = ccYELLOW;
        } else {
            newSprite = [CCSprite spriteWithFile:@"playermenu.png"];
        }
        
        
        
        
        [playerAndParticleNode addChild:newSprite];
        newSprite.position = ccp(52.5, 0);
        newSprite.scale = .736;
        
        
        [proScoreLabel setString:[NSString stringWithFormat:@"%.0f",[self getProValue]]];
        [funScoreLabel setString:[NSString stringWithFormat:@"%.0f",[self getFunValue]]];
        
        //[layer setPosition:ccp(-480, -320)];
        [self addChild:layer];
        
        
        if ([((AppDelegate*)[[UIApplication sharedApplication]delegate]) getShouldPlayMenuMusic])
        {
            [[CDAudioManager sharedManager] playBackgroundMusic:@"menumusic_new.mp3" loop:YES];
        }
        
        position = ccp(-230, 485);
        [playerAndParticleNode setPosition:position];
        isDoingEndAnimation = false;
        
        dark = [CCSprite spriteWithFile:@"black.png"];
        [dark setAnchorPoint:ccp(0, 0)];
        dark.position = ccp(-200, 0);
        dark.scale = 2;
        [self addChild:dark];
        [dark setZOrder:INT_MAX];
        dark.opacity = 0;
        
        float startAnimationTime = 1.8;
        missionPopupIsUp = false;
        
        
        if ([((AppDelegate*)[[UIApplication sharedApplication]delegate]) getShouldPlayMenuMusic]) {
            startAnimation = false;
            [self disableButtons];
            [playerAndParticleNode runAction:[CCSequence actions:
                                              [CCEaseSineInOut actionWithAction: [CCMoveTo actionWithDuration:startAnimationTime position:ccp(200, 480)]],
                                              [CCCallBlock actionWithBlock:(^{
                position = ccp(200, 480);
                velocity = CGPointZero;
                startAnimation = true;
                [self enableButtons];
                [beginLabel setVisible:true];
                [beginLabel setOpacity:0];
                [beginLabel runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                                         [CCFadeTo actionWithDuration:.45 opacity:255],
                                                                         [CCDelayTime actionWithDuration:.3],
                                                                         [CCFadeTo actionWithDuration:.3 opacity:0],
                                                                         nil]]];
            })],
                                              nil]];
            
            [topBarNode runAction:[CCEaseSineInOut actionWithAction: [CCMoveTo actionWithDuration:startAnimationTime position:ccp(0, 0)]]];
            [bottomBarNode runAction:[CCEaseSineInOut actionWithAction: [CCMoveTo actionWithDuration:startAnimationTime position:ccp(0, 320)]]];
        } else {
            position = ccp(200, 480);
            velocity = CGPointZero;
            startAnimation = true;
            [self enableButtons];
            [beginLabel setVisible:true];
            [beginLabel setOpacity:0];
            [beginLabel runAction:[CCRepeatForever actionWithAction:[CCSequence actions:
                                                                     [CCFadeTo actionWithDuration:.45 opacity:255],
                                                                     [CCDelayTime actionWithDuration:.3],
                                                                     [CCFadeTo actionWithDuration:.3 opacity:0],
                                                                     nil]]];
            
            [topBarNode setPosition:ccp(0, 0)];
            [bottomBarNode setPosition:ccp(0, 320)];
        }
        
        [self schedule:@selector(Update:) interval:0];
        
	}
	return self;
}

- (void) tappedToStart {
    isDoingEndAnimation = true;
    [self disableButtons];
    
    [topBarNode runAction:[CCEaseSineInOut actionWithAction: [CCMoveTo actionWithDuration:1.5 position:ccp(0, 100)]]];
    [bottomBarNode runAction:[CCEaseSineInOut actionWithAction: [CCMoveTo actionWithDuration:1.5 position:ccp(0, 270)]]];
    [beginLabel runAction:[CCSequence actions:
                           [CCFadeTo actionWithDuration:.3 opacity:0],
                           [CCCallBlock actionWithBlock:(^{
        
        [beginLabel setOpacity:0];
        [beginLabel setVisible:false];
    })],
                           nil]];
    
    [dark runAction:[CCSequence actions:
                     [CCDelayTime actionWithDuration:.5],
                     [CCFadeTo actionWithDuration:2 opacity:255],
                     [CCCallBlock actionWithBlock:(^{
        
        [self startGame:self];
    })],
                     
                     nil]];
    
    
    [playerAndParticleNode runAction:[CCEaseSineInOut actionWithAction: [CCScaleTo actionWithDuration:3 scale:playerAndParticleNode.scale*.2]]];
    
    acceleration = ccp(.12, acceleration.y);
}

- (void) Update:(ccTime)dt {
    if (dt > .1)
		dt = .1;
    difVector = ccpSub(ccp(200, 480), position);
    float multer = .0022;
    float variance = .021;
    float xVarMult = .4;
    
    
    float xAccel = acceleration.x;
    
    if (!isDoingEndAnimation)
        xAccel = [self randomValueBetween:ccpMult(difVector, multer).x-variance*xVarMult andValue:ccpMult(difVector, multer).x+variance*xVarMult];
    float yAccel = [self randomValueBetween:ccpMult(difVector, multer).y-variance andValue:ccpMult(difVector, multer).y+variance];
    
    acceleration = ccp(xAccel, yAccel);
    
    
    velocity = ccpAdd(velocity, ccpMult(acceleration, 60*dt));
    position = ccpAdd(position, velocity);
    if (startAnimation)
        playerAndParticleNode.position = position;
    
    
}

// this is called (magically?) by cocosbuilder when the start button is pressed
- (void)startGame:(id)sender {
    [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setShouldPlayMenuMusic:true];
    
    [[PlayerStats sharedInstance] addPlay];
    //CCLOG(@"number of plays ever: %i", [[PlayerStats sharedInstance] getPlays]);
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setChosenLevelNumber:0];
    
    /*if ([[PlayerStats sharedInstance] getPlays] == 1) {
     [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[Tutorial scene]]];
     return;
     }*/
    
    //CCLOG(@"GameplayLayerScene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)pressedStoreButton:(id)sender {
    
    
    [Flurry logEvent:@"Opened Store" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[UserWallet sharedInstance] getBalance]],@"Coin Balance" ,nil]];
    
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    [[CCDirector sharedDirector] replaceScene:[StoreLayer scene]];
    
    
    //id action = [CCMoveTo actionWithDuration:.8f position:ccp(-960,-320)];
    //id ease = [CCEaseSineInOut actionWithAction:action]; //does this "CCEaseSineInOut" look better than the above "CCEaseInOut"???
    //[layer runAction: ease];
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
    //CCLOG(@"levels layer launched");
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(0,0)];
    id ease = [CCEaseSineInOut actionWithAction:action];
    [layer runAction: ease];
    
}

- (void)pressedSendFeedback: (id) sender {
    //[TestFlight passCheckpoint:@"pressed survey button on main menu"];
    [Flurry logEvent:@"Pressed Survey Button on main menu"];
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle: @"Entering survey"
                          message: @"Thanks for taking the time to answer our survey! Any input is helpful. \n-Clay, Alex, Jeff, and Michael.\n\nIf you want to take the survey on your computer, type in this URL: tinyurl.com/stardashsurvey"
                          delegate: self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"Continue",nil];
    [alert show];
    
}

- (void)pressedCreditsButton {
    [self playSound:@"doorClose1.mp3" shouldLoop:false pitch:1];
    [[CCDirector sharedDirector] replaceScene:[CreditsLayer scene]];
    //[[CCDirector sharedDirector] pushScene:[MissionsCompleteLayer scene]];
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



- (float) randomValueBetween:(float)low andValue:(float)high {
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
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
