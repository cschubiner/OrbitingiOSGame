//
//  GameplayLayer.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.

#import "Tutorial.h"
#import "MainMenuLayer.h"

@implementation Tutorial {
}

// returns a singleton scene
+ (CCScene *) scene {
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Tutorial *layer = [Tutorial node];
    
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
        
        
        images = [[NSMutableArray alloc] init];
        [images addObject:[CCSprite spriteWithFile:@"screen1.png"]];
        [images addObject:[CCSprite spriteWithFile:@"screen2.png"]];
        [images addObject:[CCSprite spriteWithFile:@"screen3.png"]];
        
        for (CCSprite* image in images) {
            image.position =  ccp(240, 160);
            [image setOpacity:0];
            [self addChild:image];
        }
        currentImageIndex = 0;
        [(CCSprite*)[images objectAtIndex:currentImageIndex] setOpacity:255];
        
        
        
        continueLabel = [CCLabelTTF labelWithString:@"Read this or you won't know how to play t dumb bitch" fontName:@"Marker Felt" fontSize:22];
        continueLabel.position = ccp(240, 20);
        //[continueLabel setOpacity:0];
        [self addChild:continueLabel];
        
        
        
        opacTimer = 255;
        justTouchedScreen = false;
        canTouchScreen = false;
        opacChangingState = 0;
        readingTimer = 1;
        
        [self schedule:@selector(Update:) interval:0];
	}
	return self;
}



- (void) Update:(ccTime)dt {
    
    if (justTouchedScreen) {
        justTouchedScreen = false;
        canTouchScreen = false;
        opacChangingState = 1;
        readingTimer = 0;
    }
    
    if (opacChangingState == 1) {
        opacTimer-=5;
        opacTimer = clampf(opacTimer, 0, 255);
        if (opacTimer <= 0) {
            opacChangingState = 2;
            currentImageIndex++;
        }
    } else if (opacChangingState == 2) {
        opacTimer+=5;
        opacTimer = clampf(opacTimer, 0, 255);
        if (opacTimer >= 255) {
            opacChangingState = 0;
            readingTimer = 1;
        }
    }
    
    if (canTouchScreen)
        [continueLabel setString:@"Tap to continue..."];//[continueLabel setOpacity:255];
    else
        [continueLabel setString:@"Read this or you won't know how to play t dumb bitch"];//[continueLabel setOpacity:0];
    
    if (readingTimer > 0)
        readingTimer++;
    
    if (readingTimer >= 240)
        canTouchScreen = true;
    
    if (currentImageIndex < [images count])
        [(CCSprite*)[images objectAtIndex:currentImageIndex] setOpacity:opacTimer];
    else if (currentImageIndex == [images count]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionCrossFade transitionWithDuration:0.5 scene: [MainMenuLayer scene]]];
        currentImageIndex++;
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (canTouchScreen)
        justTouchedScreen = true;
}

- (void)dealloc {
    [super dealloc];
}
@end
