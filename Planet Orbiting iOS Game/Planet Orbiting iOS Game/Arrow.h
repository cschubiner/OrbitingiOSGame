//
//  Arrow.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 6/29/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CameraObject.h"

@interface Arrow : CameraObject {
    CGPoint swipeOrigin;
}

- (void)setSwipeOrigin:(CGPoint)point;
- (CGPoint)swipeOrigin;

@end
