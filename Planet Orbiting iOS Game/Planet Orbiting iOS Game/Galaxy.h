//
//  Galaxy.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 8/2/12.
//  Copyright 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Galaxy : CCNode {
    
}
@property (nonatomic) int number;
@property (nonatomic,retain) NSArray* segments;
-(id)initWithSegments:(NSArray*)levelSegments;
@end