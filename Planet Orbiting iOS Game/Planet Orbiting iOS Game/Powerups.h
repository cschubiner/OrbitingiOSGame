//
//  Powerups.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/2/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Powerups : NSObject{
    int balance;
}

@property (nonatomic) bool hasAsteroidImmunity;
+ (id)sharedInstance;

@end
