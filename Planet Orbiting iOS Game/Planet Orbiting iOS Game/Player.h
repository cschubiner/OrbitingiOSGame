//
//  Player.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Clayton Schubiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CameraObject.h"
#import "Powerup.h"

@interface Player : CameraObject {

}

- (id)init;

@property (nonatomic) CGPoint thrustBeginPoint;
@property (nonatomic) CGPoint thrustEndPoint;
@property (nonatomic) float mass;
@property (nonatomic) float rotationAtLastThrust;
@property (nonatomic) CGPoint positionAtLastThrust;
@property (nonatomic) bool isInZone;
@property (nonatomic) int coins;
@property (nonatomic, retain) Powerup* currentPowerup;
@property (nonatomic, retain) CCAction* moveAction;


@end
