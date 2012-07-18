//
//  HelloWorldLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Stanford University 2012. All rights reserved.
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
        //we may have custom menu logic here, but for now everything is just made with cocosbuilder 1.x (not 2.x!!)
     //   CCLayer* mainMenuCocosBuilderLayer = ((CCLayer*)[CCBReader nodeGraphFromFile:@"example.ccb"]);
       // [mainMenuCocosBuilderLayer setPosition:ccp(100,100)];
      //  [self addChild:mainMenuCocosBuilderLayer];
        [[CDAudioManager sharedManager] playBackgroundMusic:@"LLSDemo-Aegis-Guard.mp3" loop:YES];
	}
	return self;
}

//this is called (magically??) by cocosbuilder when the start button is pressed
- (void)startGame: (id)sender {
    CCLOG(@"gameplayLayer scene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)dealloc {
	[super dealloc];
}
@end