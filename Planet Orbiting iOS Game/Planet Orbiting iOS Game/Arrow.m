//
//  Arrow.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 6/29/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "Arrow.h"

@implementation Arrow

- (id)init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if(self=[super init]) {
        // initialization code here
	}
	return self;
}

- (void)setSwipeOrigin:(CGPoint)point {
    swipeOrigin = point;
}

- (CGPoint)swipeOrigin {
    return swipeOrigin;
}

@end
