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
#import "PlayerStats.h"

@implementation DataStorage

+ (void)storeData {
    int coins = [[UserWallet sharedInstance] getBalance];
    int numMagnet = [[PowerupManager sharedInstance] numMagnet];
    int numImmunity = [[PowerupManager sharedInstance] numImmunity];
    int numPlays = [[PlayerStats sharedInstance] getPlays];
    NSArray *highScores = [[PlayerStats sharedInstance] getScores];
    NSData *data = [NSData dataWithBytes:&highScores length:sizeof(highScores)];
    
    // Store the data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:coins forKey:@"coin"];
    [defaults setInteger:numMagnet forKey:@"magnet"];
    [defaults setInteger:numImmunity forKey:@"immunity"];
    [defaults setInteger:numPlays forKey:@"plays"];
    [defaults setObject:data forKey:@"highscores"];

    
    [defaults synchronize];
}

+ (void)fetchData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int coins = [defaults integerForKey:@"coin"];
    int numMagnet = [defaults integerForKey:@"magnet"];
    int numImmunity = [defaults integerForKey:@"immunity"];
    int numPlays = [defaults integerForKey:@"plays"];
    
    NSData *arrayData = [defaults objectForKey:@"highscores"];
    if (arrayData != nil)
    {
        NSArray *oldSavedArray = [NSKeyedUnarchiver unarchiveObjectWithData:arrayData];
        //if (oldSavedArray != nil)
            //objectArray = [[NSMutableArray alloc] initWithArray:oldSavedArray];
        //else
            //objectArray = [[NSMutableArray alloc] init];
    }

    
    [[UserWallet sharedInstance] setBalance:coins];
    [[PowerupManager sharedInstance] setNumberOfMagnet:numMagnet];
    [[PowerupManager sharedInstance] setNumberOfImmunity:numImmunity];
    [[PlayerStats sharedInstance] setPlays:numPlays];
}

@end