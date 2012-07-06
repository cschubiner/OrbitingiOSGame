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


// This method is set as an attribute to the CCMenuItemImage in
// CocosBuilder, and automatically set up to be called when the
// button is pressed.
- (void)pressedButton:(id)sender
{    
    // Stop all running actions for the icon sprite

}

// on "init" you need to initialize your instance
- (id)init {
	if (self = [super init]) {
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        
        CCMenuItemFont *startButton = [CCMenuItemFont itemFromString:@"Stadrt" target:self selector:@selector(startGame:)];
        
        CCMenu *menu = [CCMenu menuWithItems:startButton, nil];
        [menuLayer addChild:menu];
        
	}
	return self;
}

- (void)startGame: (id)sender {
    NSLog(@"gameplayLayer scene launched, game starting");
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

- (void)dealloc {
	[super dealloc];
}
@end
