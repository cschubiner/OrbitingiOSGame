//
//  PlayerStats.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerStats : NSObject {
    int totalPlays;
    // in the future, add other useful metrics here
}

@property (nonatomic) int totalPlays;

+ (id)sharedInstance;

@end