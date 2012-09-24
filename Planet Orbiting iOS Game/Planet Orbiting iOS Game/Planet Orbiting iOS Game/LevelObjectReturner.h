//
//  LevelObjectReturner.h
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

enum LevelObjectTypes {
    kplanet,
    kcoin,
    kasteroid,
    kpowerup
};

@interface LevelObjectReturner : NSObject {
}

@property (nonatomic) CGPoint pos;
@property (nonatomic) float scale;
@property (nonatomic) enum LevelObjectTypes type;
@property (nonatomic) bool canBeFlipped;

-(id) initWithType:(enum LevelObjectTypes) typeInputted position:(CGPoint)posI scale:(float)scaleI;
-(id) initWithType:(enum LevelObjectTypes) typeInputted position:(CGPoint)posI scale:(float)scaleI canBeFlipped:(bool)shouldFlip;

@end
