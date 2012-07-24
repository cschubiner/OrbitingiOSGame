//
//  HelloWorldLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.
//

#import "MainMenuLayer.h"
#import "GameplayLayer.h"

// HelloWorldLayer implementation
@implementation MainMenuLayer

// returns a singleton scene
+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MainMenuLayer *layer = [MainMenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


// on "init" you need to initialize your instance
- (id)init {
	if (self = [super init]) {
        layer = (CCLayer*)[CCBReader nodeGraphFromFile:@"MainMenuScrolling.ccb" owner:self];
        [self addChild:layer];
        [[CDAudioManager sharedManager] playBackgroundMusic:@"LLSDemo-Aegis-Guard.mp3" loop:YES];
        [[UIApplication sharedApplication]setStatusBarOrientation:[[UIApplication sharedApplication]statusBarOrientation]];

	}
	return self;
}

// this is called (magically?) by cocosbuilder when the start button is pressed
- (void)startGame: (id)sender {
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(-480,-320)];
    id ease = [CCEaseOut actionWithAction:action rate:2];
    [layer runAction: ease];

    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:FALSE];

    [[UIApplication sharedApplication]setStatusBarOrientation:[[UIApplication sharedApplication]statusBarOrientation]];

    CCLOG(@"gameplayLayer scene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)pressedBackButton: (id) sender
{
    [Flurry logEvent:@"Went back to menu from store"];
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(0,0)];
    id ease = [CCEaseInOut actionWithAction:action rate:2];
    [layer runAction: ease];
}

- (void)pressedStoreButton: (id) sender
{
    [Flurry logEvent:@"Opened Store"];
    id action = [CCMoveTo actionWithDuration:.8f position:ccp(-480,0)];
    id ease = [CCEaseSineInOut actionWithAction:action]; //does this "CCEaseSineInOut" look better than the above "CCEaseInOut"???
    [layer runAction: ease];
}


- (void)pressedSendFeedback: (id) sender
{
    [Flurry logEvent:@"Pressed Send Feedback"];
    [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [TestFlight openFeedbackView];
}

- (void)pressedTutorialButton: (id) sender
{
    [Flurry logEvent:@"Pressed Tutorial Button"];
    [((AppDelegate*)[[UIApplication sharedApplication]delegate])setIsInTutorialMode:TRUE];
    [[UIApplication sharedApplication]setStatusBarOrientation:[[UIApplication sharedApplication]statusBarOrientation]];
    CCLOG(@"gameplayLayer scene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)dealloc {
	[super dealloc];
}

@end