//
//  Powerup.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/2/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "Powerup.h"
#import "cocos2d.h"

@implementation Powerup

@synthesize coinSprite, visualSprite, hudSprite, type, duration;

-(id) initWithType:(int)t {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        type = t;
        
        
        if (type == 1) { //asteroidImmunity
            
            duration = 700;
            coinSprite = [CCSprite spriteWithSpriteFrameName:@"asteroidbreakercoin.png"];
            visualSprite = [CCSprite spriteWithSpriteFrameName:@"asteroidglowupgrade.png"];
            hudSprite = [CCSprite spriteWithFile:@"asteroidhudicon.png"];
            
        } else if (type == 2) { //coinMagnet
            
            duration = 700;
            coinSprite = [CCSprite spriteWithSpriteFrameName:@"magnetcoin.png"];
            visualSprite = [CCSprite spriteWithSpriteFrameName:@"coinglowglowupgrade.png"];
            hudSprite = [CCSprite spriteWithFile:@"magnethudicon.png"];
            
        } else { //type needs to be a valid int from the list above
            id *hi = NULL;
            return *hi;
        }
        
    }
	return self;
}

@end
