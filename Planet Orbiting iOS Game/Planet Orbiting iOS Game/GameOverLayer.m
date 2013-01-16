//
//  CCLayer+GameOverLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 1/15/13.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "GameOverLayer.h"
#import "UpgradeManager.h"
#import "UpgradeItem.h"
#import "UpgradeCell.h"
#import "UserWallet.h"
#import "CCDirector.h"
#import "MainMenuLayer.h"
#import "SimpleAudioEngine.h"
#import "DataStorage.h"

@implementation GameOverLayer {

}



// returns a singleton scene
+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameOverLayer *layer = [GameOverLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene.
	return scene;
}

// on "init" you need to initialize your instance
- (id)init {
	if (self = [super init]) {
        
        [((AppDelegate*)[[UIApplication sharedApplication]delegate]) setdidGetToMainMenu:YES];
        
        //CGSize size = [[CCDirector sharedDirector] winSize];
        self.isTouchEnabled = true;
        
	}
	return self;
}

@end