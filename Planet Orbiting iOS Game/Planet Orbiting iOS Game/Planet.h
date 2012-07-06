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

@interface Planet : CameraObject {
    float radius;
}

-(id)init;

@property (nonatomic) CGPoint forceExertingOnPlayer;
@property (nonatomic) float mass;

-(float)radius;

@end