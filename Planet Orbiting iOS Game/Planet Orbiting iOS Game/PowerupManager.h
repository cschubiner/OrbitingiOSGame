//
//  PowerupManager.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PowerupManager : NSObject {
    int numMagnet;
    int numBeast;
}

@property (nonatomic) int numMagnet;
@property (nonatomic) int numBeast;

+ (id)sharedInstance;

- (void)addMagnet;
- (void)addBeast;

@end