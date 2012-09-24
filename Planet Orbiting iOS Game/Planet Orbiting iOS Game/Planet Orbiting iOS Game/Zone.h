//
//  Zone.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/27/12.
//  Copyright 2012 Clayton Schubiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CameraObject.h"

@interface Zone : CameraObject {
    bool hasPlayerHitThisZone;
}

- (id)init;

@property (nonatomic) bool hasPlayerHitThisZone;


@end