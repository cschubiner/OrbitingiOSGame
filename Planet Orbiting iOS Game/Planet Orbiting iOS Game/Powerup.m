//
//  Powerup.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/2/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "Powerup.h"

@implementation Powerup

@synthesize  glowSprite, type, duration, title;

-(id) initWithType:(int)t {
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        type = t;
       // bool shouldBeRand = false;
        
        if (type == krandomPowerup) {
          //  shouldBeRand = true;
            type = [self RandomBetween:1 maxvalue:3];
        }
        
        if (type == kasteroidImmunity) { //asteroidImmunity
            
            duration = [[UpgradeValues sharedInstance] asteroidImmunityDuration];
            title = @"Asteroid Armor";
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"magnetcoin.png"];//@"asteroidbreakericon.png"]; //never used?
            glowSprite = [CCSprite spriteWithSpriteFrameName:@"playerarmor.png"];
            
        } else if (type == kcoinMagnet) { //coinMagnet
            
            duration = [[UpgradeValues sharedInstance] coinMagnetDuration];
            title = @"Star Magnet";
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"magnetcoin.png"];
            glowSprite = [CCSprite spriteWithSpriteFrameName:@"playermagnet.png"];
            
        } else if (type == kautopilot) { //autopilot powerup
            
            duration = [[UpgradeValues sharedInstance] autopilotDuration]; //JJ's headstart lasts 5 seconds
            title = @"Autopilot";
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"magnetcoin.png"];
            glowSprite = [CCSprite spriteWithSpriteFrameName:@"playerheadstart.png"];
            
        } else if (type == kheadStart) { //wrapage powerup
            
            duration = 350; //JJ's headstart lasts 5 seconds
            title = @"Head Start";
            self.sprite = [CCSprite spriteWithSpriteFrameName:@"magnetcoin.png"];
            glowSprite = [CCSprite spriteWithSpriteFrameName:@"playerheadstart.png"];
            
        } //else { //type needs to be a valid int from the list above
     //   }
        
        //if (shouldBeRand)
        //    self.sprite = [CCSprite spriteWithFile:@"upgradecoin.png"];
        
    }
	return self;
}

- (int)RandomBetween:(int)minvalue maxvalue:(int)maxvalue  {
    int randomNumber = minvalue+  arc4random() % (1+maxvalue-minvalue);
    return randomNumber;
}

@end
