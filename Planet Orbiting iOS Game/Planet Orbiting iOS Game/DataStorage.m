//
//  DataStorage.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/24/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "DataStorage.h"
#import "UserWallet.h"
#import "PowerupManager.h"

@implementation DataStorage

+ (void)storeData {
    int coins = [[UserWallet sharedInstance] getBalance];
    int numMagnet = [[PowerupManager sharedInstance] numMagnet];
    int numImmunity = [[PowerupManager sharedInstance] numImmunity];
    
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:coins forKey:@"coin"];
    [defaults setInteger:numMagnet forKey:@"magnet"];
    [defaults setInteger:numImmunity forKey:@"immunity"];
    
    [defaults synchronize];
}

+ (void)fetchData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int coins = [defaults integerForKey:@"coin"];
    int numMagnet = [defaults integerForKey:@"magnet"];
    int numImmunity = [defaults integerForKey:@"immunity"];
    
    [[UserWallet sharedInstance] setBalance:coins];
    
    [[PowerupManager sharedInstance] setNumberOfMagnet:numMagnet];
    
    [[PowerupManager sharedInstance] setNumberOfImmunity:numImmunity];
}

@end