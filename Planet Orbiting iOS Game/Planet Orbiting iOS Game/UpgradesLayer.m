//
//  GameplayLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.

#import "UpgradesLayer.h"
//#import "UpgradeManager.m"

@implementation UpgradesLayer {
}

// returns a singleton scene
+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	UpgradesLayer *layer = [UpgradesLayer node];
    
	// add layer as a child to scene
	[scene addChild: layer];
    
	// return the scene.
	return scene;
}

/* On "init," initialize the instance */
- (id)init {
	// always call "super" init.
	// Apple recommends to re-assign "self" with the "super" return value
	if ((self = [super init])) {
        self.isTouchEnabled= TRUE;
        
        //continueLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d", [[UpgradeManager sharedInstance] buttonPushed]] fontName:@"Marker Felt" fontSize:22];
        
        CCSprite* topBar = [CCSprite spriteWithFile:@"banner.png"];
        [self addChild:topBar];
        [topBar setPosition: ccp(160, 480 - topBar.boundingBox.size.width/2)];
        
        [self schedule:@selector(Update:) interval:0];
	}
	return self;
}



- (void) Update:(ccTime)dt {
    
    
}


@end
