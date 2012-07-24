//
//  PowerupManager.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PowerupManager : NSObject {
    int numberOfMagnet;
    int numberOfBeast;
}

@property (nonatomic) int numberOfMagnet;
@property (nonatomic) int numberOfBeast;

+ (id)sharedInstance;

- (void)addMagnet;
- (void)addBeast;
- (int)numMagnet;
- (int)numBeast;

@end