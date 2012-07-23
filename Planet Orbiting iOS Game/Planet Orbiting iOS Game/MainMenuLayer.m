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
	}
	return self;
}

// this is called (magically??) by cocosbuilder when the start button is pressed
- (void)startGame: (id)sender {
    [Flurry logEvent:@"Pressed Start Game"];

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
    id ease = [CCEaseInOut actionWithAction:action rate:2];
    [layer runAction: ease];
}


- (void)pressedSendFeedback: (id) sender
{
    [Flurry logEvent:@"Pressed Send Feedback"];
    [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationPortrait];
    [TestFlight openFeedbackView];
}

- (void)dealloc {
	[super dealloc];
}

@end