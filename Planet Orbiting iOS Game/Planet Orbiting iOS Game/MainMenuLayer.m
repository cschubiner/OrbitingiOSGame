//
//  HelloWorldLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Stanford University 2012. All rights reserved.
//


// Import the interfaces
#import "MainMenuLayer.h"
#import "GameplayLayer.h"

// HelloWorldLayer implementation
@implementation MainMenuLayer

+(CCScene *) scene
{
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
- (void) pressedButton:(id)sender
{    
    // Stop all runnint actions for the icon sprite

}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        // ask director the the window size
		CGSize size = [[CCDirector sharedDirector] winSize];
        CCLayer *menuLayer = [[CCLayer alloc] init];
        [self addChild:menuLayer];
        
		// create and initialize a Label
        CCLabelTTF *label = [CCLabelTTF labelWithString:@"Project Warlock" fontName:@"Marker Felt" fontSize:32];
		// position the label on the center of the screen
		label.position =  ccp( size.width /2 , 3*size.height/4 );
		// add the label as a child to this Layer
	//	[self addChild: label];
        
        CCMenuItemFont *startButton = [CCMenuItemFont itemFromString:@"Start" target:self selector:@selector(startGame:)];
        
        CCMenu *menu = [CCMenu menuWithItems:startButton, nil];
      //  [menuLayer addChild:menu];
        
	}
	return self;
}

- (void) startGame: (id) sender
{
    
    [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene:[GameplayLayer scene]]];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
