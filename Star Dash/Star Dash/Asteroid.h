//
//  Planet.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright 2012 Clayton Schubiner. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CameraObject.h"

@interface Asteroid : CameraObject {
}

-(id)init;



@property (nonatomic) CGPoint p1;
@property (nonatomic) CGPoint p2;

@end