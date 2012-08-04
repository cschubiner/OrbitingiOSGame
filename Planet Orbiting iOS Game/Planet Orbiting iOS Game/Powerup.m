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

@synthesize coinSprite, visualSprite, hudSprite, asteroidImmunityCoinSprite, asteroidImmunityVisualSprite, asteroidImmunityHudSprite, type, duration, coinMagetCoinSprite, coinMagnetHudSprite, coinMagnetVisualSprite;

-(id) init {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        
        asteroidImmunityCoinSprite = [CCSprite spriteWithFile:@"asteroidbreakercoin.png"];
        asteroidImmunityVisualSprite = [CCSprite spriteWithFile:@"asteroidglowupgrade.png"];
        asteroidImmunityHudSprite = [CCSprite spriteWithFile:@"asteroidhudicon.png"];
        
        coinMagetCoinSprite = [CCSprite spriteWithFile:@"magnetcoin.png"];
        coinMagnetVisualSprite = [CCSprite spriteWithFile:@"coinglowglowupgrade.png"];
        coinMagnetHudSprite = [CCSprite spriteWithFile:@"magnethudicon.png"];
	
    }
	return self;
}

@end
