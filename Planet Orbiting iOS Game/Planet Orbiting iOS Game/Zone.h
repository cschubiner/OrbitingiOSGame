//
//  Zone.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/27/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CameraObject.h"

@interface Zone : CameraObject {
    float radius;
    bool hasPlayerHitThisZone;
}

-(id)init;
@property (nonatomic) bool hasPlayerHitThisZone;

-(float)radius;

@end