//
//  Powerup.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/2/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "CameraObject.h"

@interface Powerup : CameraObject

-(id)init;

@property (nonatomic, assign) CCSprite* coinSprite;
@property (nonatomic, assign) CCSprite* visualSprite;
@property (nonatomic, assign) CCSprite* hudSprite;
@property (nonatomic, assign) int type; //0=none, 1=asteroidImmunity, 2=asteroid immunity
@property (nonatomic, assign) float duration;

@property (nonatomic, assign) CCSprite* asteroidImmunityCoinSprite;
@property (nonatomic, assign) CCSprite* asteroidImmunityVisualSprite;
@property (nonatomic, assign) CCSprite* asteroidImmunityHudSprite;

@property (nonatomic, assign) CCSprite* coinMagetCoinSprite;
@property (nonatomic, assign) CCSprite* coinMagnetVisualSprite;
@property (nonatomic, assign) CCSprite* coinMagnetHudSprite;

@end
