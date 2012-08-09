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
#import "UpgradeManager.h"
#import "UpgradeItem.h"

@implementation DataStorage

+ (void)storeData {
    int coins = [[UserWallet sharedInstance] getBalance];
    int numPlays = [[PlayerStats sharedInstance] getPlays];
    NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
    NSMutableArray *upgradeItems = [[UpgradeManager sharedInstance] upgradeItems];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:coins forKey:@"coin"];
    [defaults setInteger:numPlays forKey:@"plays"];
    [defaults setObject:highScores forKey:@"highscores"];
    [defaults setObject:upgradeItems forKey:@"upgrades"];
    
    [defaults synchronize];
}

+ (void)fetchData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int coins = [defaults integerForKey:@"coin"];
    int numPlays = [defaults integerForKey:@"plays"];
    NSMutableArray *highScores = [defaults objectForKey:@"highscores"];
    NSMutableArray *upgradeItems = [defaults objectForKey:@"upgrades"];

    [[UserWallet sharedInstance] setBalance:coins];
    [[PlayerStats sharedInstance] setPlays:numPlays];
    
    if (highScores) {
        [[PlayerStats sharedInstance] setScores:highScores];
    }
    
    if (!upgradeItems) {
        NSMutableArray* items = [[NSMutableArray alloc] init];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Star Magnet" description:@"The stars will cum on t" icon:@"magnethudicon.png" price:1000 hasLevels:true level:0]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Immunity" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:2000 hasLevels:true level:0]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Immunity" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:2000 hasLevels:true level:0]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Immunity" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:2000 hasLevels:true level:0]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Immunity" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:2000 hasLevels:true level:0]];
        
        upgradeItems = [[NSMutableArray alloc] initWithArray:items];
    }
    
    [[UpgradeManager sharedInstance] setUpgradeItems:upgradeItems];

}

@end
