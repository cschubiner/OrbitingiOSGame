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
    kasteroid
};

@interface LevelObjectReturner : NSObject {
}

@property (nonatomic) CGPoint pos;
@property (nonatomic) float scale;
@property (nonatomic) enum LevelObjectTypes type;

-(id) initWithType:(enum LevelObjectTypes) typeInputted position:(CGPoint)posI scale:(float)scaleI;

@end
