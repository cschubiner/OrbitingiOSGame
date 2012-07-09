//
//  Planet.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CameraObject.h"

@interface Asteroid : CameraObject {
    float radius;
}

-(id)init;

-(float)radius;


@property (nonatomic) CGPoint p1;
@property (nonatomic) CGPoint p2;
@property (nonatomic) int updatesSinceVelChange;
@property (nonatomic) float velMult;

@end