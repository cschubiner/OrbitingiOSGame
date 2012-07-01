//
//  PredPoint.m
//  Planet Orbiting iOS Game
//
//  Created by Lion User on 30/06/2012.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import "PredPoint.h"


@implementation PredPoint

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
