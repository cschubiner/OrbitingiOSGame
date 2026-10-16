//
//  Powerup.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/2/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "CameraObject.h"
#import "UpgradeValues.h"


@interface Powerup : CameraObject

-(id)initWithType:(int)t;

enum PowerupTypes {
    krandomPowerup,
    kasteroidImmunity,
    kcoinMagnet,
    kautopilot,
    kheadStart
};

// Strong: under ARC "assign" is unretained, and optimized builds freed the autoreleased
// sprite inside -initWithType:, crashing when a powerup spawned (classic galaxy 2,
// procedural maps immediately).
@property (nonatomic, strong) CCSprite* glowSprite;
@property (nonatomic, assign) int type; //0=random, 1=asteroidImmunity, 2=asteroid immunity
@property (nonatomic, copy) NSString* title;
@property (nonatomic, assign) float duration;

@end
