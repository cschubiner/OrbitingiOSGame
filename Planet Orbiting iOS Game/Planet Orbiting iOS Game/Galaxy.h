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
@property (nonatomic,retain) CCSprite *backgroundSprite;
@property (nonatomic) int number;
@property (nonatomic) int optimalPlanetsInThisGalaxy;
@property (nonatomic) int numberOfDifferentPlanetsDrawn;
@property (nonatomic) float percentTimeToAddUponGalaxyCompletion;
@property (nonatomic,retain) NSArray* segments;
@property (nonatomic, retain) NSString* name;
@property (nonatomic,retain) CCSpriteBatchNode* spriteSheet;
-(id)initWithSegments:(NSArray*)levelSegments;
@end