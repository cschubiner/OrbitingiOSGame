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
#import "ObjectiveManager.h"

@implementation DataStorage

+ (void)storeData {
    int coins = [[UserWallet sharedInstance] getBalance];
    int numPlays = [[PlayerStats sharedInstance] getPlays];
    NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
    NSMutableArray *upgradeItems = [[UpgradeManager sharedInstance] upgradeItems];
    NSMutableDictionary *nameScorePairs = [[PlayerStats sharedInstance] getKeyValuePairs];
    NSString *recentName = [[PlayerStats sharedInstance] recentName];
    
    NSMutableArray *levels = [[NSMutableArray alloc] init];
    
    for (UpgradeItem *item in upgradeItems) {
        int level = item.level;
        NSNumber *number = [NSNumber numberWithInt:level];
        [levels addObject:number];
    }
    
    
    
    NSMutableArray* groups = [[ObjectiveManager sharedInstance] objectiveGroups];
    NSMutableArray* completions = [[NSMutableArray alloc] init];
    
    for (ObjectiveGroup* group in groups) {
        NSMutableArray* itemsToAdd = [[NSMutableArray alloc] init];
        [completions addObject:itemsToAdd];
        for (ObjectiveItem* item in group.objectiveItems) {
            NSNumber* completed = [NSNumber numberWithBool:item.completed];
            [itemsToAdd addObject:completed];
        }
        [completions addObject:itemsToAdd];
    }
    NSNumber* currentObjectiveGroupNumber = [NSNumber numberWithInt:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:coins forKey:@"coin"];
    [defaults setInteger:numPlays forKey:@"plays"];
    [defaults setObject:highScores forKey:@"highscores"];
    [defaults setObject:levels forKey:@"levels"];
    [defaults setObject:completions forKey:@"objectives"];
    [defaults setObject:currentObjectiveGroupNumber forKey:@"currentObjectiveGroupNumber"];
    [defaults setObject:nameScorePairs forKey:@"nameScorePairs"];
    [defaults setObject:recentName forKey:@"recentName"];
    
    [defaults synchronize];
}

+ (void)fetchData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int coins = [defaults integerForKey:@"coin"];
    int numPlays = [defaults integerForKey:@"plays"];
    NSMutableArray *highScores = [defaults objectForKey:@"highscores"];
    NSMutableArray *levels = [defaults objectForKey:@"levels"];
    NSMutableArray *objectives = [defaults objectForKey:@"objectives"];
    NSNumber *currentObjectiveGroupNumber = [defaults objectForKey:@"currentObjectiveGroupNumber"];
    NSMutableDictionary *nameScorePairs = [defaults objectForKey:@"nameScorePairs"];
    NSString *recentName = [defaults objectForKey:@"recentName"];

    [[UserWallet sharedInstance] setBalance:coins];
    [[PlayerStats sharedInstance] setPlays:numPlays];
    
    if (highScores) {
        [[PlayerStats sharedInstance] setScores:highScores];
    }
    
    if (nameScorePairs) {
        [[PlayerStats sharedInstance] setKeyValuePairs:nameScorePairs];
    }
    
    if (recentName) {
        [[PlayerStats sharedInstance] setRecentName:recentName];
    } else {
        [[PlayerStats sharedInstance] setRecentName:@"PLAYER"];
    }
    
    NSMutableArray* items = [[NSMutableArray alloc] init];
    NSMutableArray* upgradeItems;
    
    NSMutableArray *levelsToUse = [[NSMutableArray alloc] init];
    
    if (!levels) {
        for (int i = 0; i < 6; i++) {
            [levelsToUse addObject:[NSNumber numberWithInt:0]];
        }
    } else {
        for (int i = 0; i < 6; i++) {
            [levelsToUse addObject:[levels objectAtIndex:i]];
        }
    }
    
    
    int index = 0;
    
    [items addObject:[[UpgradeItem alloc] initWithTitle:@"Star Magnet" description:@"Increase the duration and effective range of the Star Magnet powerup!" icon:@"magneticon.png" prices:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:400], [NSNumber numberWithInt:600], [NSNumber numberWithInt:1000], [NSNumber numberWithInt:2000], [NSNumber numberWithInt:5000], nil] level:[[levelsToUse objectAtIndex:index++] intValue]]];
    
    [items addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Armor" description:@"Increase the duration of the Asteroid Armor powerup!" icon:@"asteroidbreakericon.png" prices:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:300], [NSNumber numberWithInt:500], [NSNumber numberWithInt:700], [NSNumber numberWithInt:1000], [NSNumber numberWithInt:2000], nil] level:[[levelsToUse objectAtIndex:index++] intValue]]];
    
    [items addObject:[[UpgradeItem alloc] initWithTitle:@"Nitrous Rocket" description:@"Increase the strength of your rocket to fly faster through space!" icon:@"speedupgradeicon.png" prices:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:400], [NSNumber numberWithInt:1000], [NSNumber numberWithInt:2000], [NSNumber numberWithInt:3000], [NSNumber numberWithInt:5000], nil] level:[[levelsToUse objectAtIndex:index++] intValue]]];
    
    [items addObject:[[UpgradeItem alloc] initWithTitle:@"Double Stars" description:@"A great long-term investment - each star you collect is worth two!" icon:@"doublecoinicon.png" prices:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:5000], nil] level:[[levelsToUse objectAtIndex:index++] intValue]]];
    
    [items addObject:[[UpgradeItem alloc] initWithTitle:@"Lithium Ion Battery" description:@"Increase your battery's efficiency to allow you to fly deeper into space!" icon:@"batteryupgradeicon.png" prices:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:1000], [NSNumber numberWithInt:2000], [NSNumber numberWithInt:3000], [NSNumber numberWithInt:5000], [NSNumber numberWithInt:10000], nil] level:[[levelsToUse objectAtIndex:index++] intValue]]];
    
    [items addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Powerup" description:@"Start each game with a random powerup!" icon:@"randompowerupicon.png" prices:[[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:3000], nil] level:[[levelsToUse objectAtIndex:index++] intValue]]];
    
    
    
    upgradeItems = [[NSMutableArray alloc] initWithArray:items];
    
    [[UpgradeManager sharedInstance] setUpgradeItems:upgradeItems];
    
    
    
    
    
    
    
    
    
    
    int currGroup = [currentObjectiveGroupNumber intValue];
    if (!currGroup) {
        currGroup = 0;
    }
    [[ObjectiveManager sharedInstance] setCurrentObjectiveGroupNumber:currGroup];
    
    
    if (!objectives) {
        NSMutableArray* groups = [[NSMutableArray alloc] init];
        
        [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.1 starReward:500
                                                              item0:[[ObjectiveItem alloc] initWithText:@"Reach the second galaxy"]
                                                              item1:[[ObjectiveItem alloc] initWithText:@"Purchase an upgrade"]
                                                              item2:[[ObjectiveItem alloc] initWithText:@"Get 10 stars in one run"]]];
        
        [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.2 starReward:700
                                                              item0:[[ObjectiveItem alloc] initWithText:@"Reach the third galaxy"]
                                                              item1:[[ObjectiveItem alloc] initWithText:@"Get 15 stars in one run"]
                                                              item2:[[ObjectiveItem alloc] initWithText:@"Get 20 stars in one run"]]];
        objectives = groups;
    }
    [[ObjectiveManager sharedInstance] setObjectiveGroups:objectives];
    
    
    
    
    
    
}

@end
