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
    int numberOfImmunity;
}

@property (nonatomic) int numberOfMagnet;
@property (nonatomic) int numberOfImmunity;

+ (id)sharedInstance;

- (void)addMagnet;
- (void)addImmunity;
- (void)subtractMagnet;
- (void)subtractImmunity;
- (int)numMagnet;
- (int)numImmunity;

@end