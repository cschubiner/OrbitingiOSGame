//
//  Player.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CameraObject.h"
#import "CCLayerStreak.h"

@interface Player : CameraObject {
    
}

-(id)init;

@property (nonatomic) CGPoint thrustBeginPoint;
@property (nonatomic) CGPoint thrustEndPoint;
@property (nonatomic) bool thrustJustOccurred;
@property (nonatomic) float mass;
@property (nonatomic) bool isInZone;

@end
