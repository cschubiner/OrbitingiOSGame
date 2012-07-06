//
//  Point.h
//  Planet Orbiting iOS Game
//
//  Created by Lion User on 30/06/2012.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CameraObject.h"

@interface PredPoint : CameraObject {
    CGPoint swipeOrigin;
}

- (void)setSwipeOrigin:(CGPoint)point;
- (CGPoint)swipeOrigin;

@end