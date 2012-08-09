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
    
    NSMutableArray *levels = [[NSMutableArray alloc] init];
    
    for (UpgradeItem *item in upgradeItems) {
        int level = item.level;
        NSNumber *number = [NSNumber numberWithInt:level];
        [levels addObject:number];
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:coins forKey:@"coin"];
    [defaults setInteger:numPlays forKey:@"plays"];
    [defaults setObject:highScores forKey:@"highscores"];
    [defaults setObject:levels forKey:@"levels"];
    
    [defaults synchronize];
}

+ (void)fetchData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int coins = [defaults integerForKey:@"coin"];
    int numPlays = [defaults integerForKey:@"plays"];
    NSMutableArray *highScores = [defaults objectForKey:@"highscores"];
    NSMutableArray *levels = [defaults objectForKey:@"levels"];

    [[UserWallet sharedInstance] setBalance:coins];
    [[PlayerStats sharedInstance] setPlays:numPlays];
    
    if (highScores) {
        [[PlayerStats sharedInstance] setScores:highScores];
    }
    
    
    NSMutableArray* items = [[NSMutableArray alloc] init];
    NSMutableArray* upgradeItems;
    
    
    
    if (!levels) {
        
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Star Magnet" description:@"The stars will cum on t" icon:@"magnethudicon.png" price:1000 hasLevels:true level:0]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Armor" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:4 hasLevels:true level:0]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Strong Rockets" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:2000 hasLevels:true level:0]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Immunity" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:2000 hasLevels:true level:0]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Immunity" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:2000 hasLevels:true level:0]];
        
    } else {
        
        //int index = 0;
        
        
        int index = 0;
        
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Star Magnet" description:@"The stars will cum on t" icon:@"magnethudicon.png" price:1000 hasLevels:true level:[[levels objectAtIndex:index++]intValue]]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Immunity" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:4 hasLevels:true level:[[levels objectAtIndex:index++]intValue]]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Stronger Rockets" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:2000 hasLevels:true level:[[levels objectAtIndex:index++]intValue]]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Immunity" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:2000 hasLevels:true level:[[levels objectAtIndex:index++]intValue]]];
        [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Immunity" description:@"The asteroids will quiver in fear before t" icon:@"asteroidhudicon.png" price:2000 hasLevels:true level:[[levels objectAtIndex:index++]intValue]]];
        
    }
    
    
    upgradeItems = [[NSMutableArray alloc] initWithArray:items];
    
    [[UpgradeManager sharedInstance] setUpgradeItems:upgradeItems];

}

@end
