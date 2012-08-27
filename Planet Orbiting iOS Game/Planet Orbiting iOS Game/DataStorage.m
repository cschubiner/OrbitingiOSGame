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
    NSMutableDictionary *nameScorePairs = [[PlayerStats sharedInstance] getKeyValuePairs];
    NSString *recentName = [[PlayerStats sharedInstance] recentName];
    
    NSMutableArray *groups = [[ObjectiveManager sharedInstance] objectiveGroups];
    NSMutableArray *completions = [[NSMutableArray alloc] init];
    
    for (ObjectiveGroup *group in groups) {
        NSMutableArray *itemsToAdd = [[NSMutableArray alloc] init];
        for (ObjectiveItem *item in group.objectiveItems) {
            NSNumber *completed = [NSNumber numberWithBool:item.completed];
            [itemsToAdd addObject:completed];
        }
        [completions addObject:itemsToAdd];
    }
    NSNumber *currentObjectiveGroupNumber = [NSNumber numberWithInt:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
    
    NSMutableArray *upgrades = [[UpgradeManager sharedInstance] upgradeItems];
    NSMutableArray *upgradeCodes = [[NSMutableArray alloc] init];
    for (UpgradeItem *item in upgrades) {
        BOOL A = item.purchased;
        BOOL B = item.equipped;
        if (A && B) {
            [upgradeCodes addObject:[NSNumber numberWithInt:0]];
        } else if (A && !B) {
            [upgradeCodes addObject:[NSNumber numberWithInt:1]];
        } else if (!A && B) {
            [upgradeCodes addObject:[NSNumber numberWithInt:2]];
        } else {
            [upgradeCodes addObject:[NSNumber numberWithInt:3]];
        }
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setInteger:coins forKey:@"coin"];
    [defaults setInteger:numPlays forKey:@"plays"];
    [defaults setObject:highScores forKey:@"highscores"];
    [defaults setObject:completions forKey:@"objectives"];
    [defaults setObject:currentObjectiveGroupNumber forKey:@"currentObjectiveGroupNumber"];
    [defaults setObject:nameScorePairs forKey:@"nameScorePairs"];
    [defaults setObject:recentName forKey:@"recentName"];
    [defaults setObject:upgradeCodes forKey:@"upgradeCodes"];
    
    [defaults synchronize];
}

+ (void)fetchData {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    int coins = [defaults integerForKey:@"coin"];
    int numPlays = [defaults integerForKey:@"plays"];
    NSMutableArray *highScores = [defaults objectForKey:@"highscores"];
    NSMutableArray *objectives = [defaults objectForKey:@"objectives"];
    NSNumber *currentObjectiveGroupNumber = [defaults objectForKey:@"currentObjectiveGroupNumber"];
    NSMutableDictionary *nameScorePairs = [defaults objectForKey:@"nameScorePairs"];
    NSString *recentName = [defaults objectForKey:@"recentName"];
    NSMutableArray *upgradeCodes = [defaults objectForKey:@"upgradeCodes"];

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
        
    // 0 = SPACESHIP TRAILS
    // 1 = ROCKETSHIPS
    // 2 = UPGRADES
    // 3 = POWERUPS
    // 4 = STARS
    // 5 = PERKS
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Star Magnet" description:@"Increase the duration and effective range of the Star Magnet powerup." price:1000 type:3 purchased:NO equipped:NO number:0]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Armor" description:@"Increase the duration of the Asteroid Armor powerup." price:2000 type:3 purchased:NO equipped:NO number:1]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Nitrous Rocket" description:@"Increase the strength of your rocket to fly faster through space." price:5000 type:2 purchased:NO equipped:NO number:2]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Double Stars" description:@"A great long-term investment! Each star you collect is worth two." price:199 type:4 purchased:NO equipped:NO number:3]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Lithium Ion Battery" description:@"Increase your battery's efficiency to allow you to fly deeper into space." price:11000 type:2 purchased:NO equipped:NO number:4]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Star Magnet" description:@"Start each game with the Star Magnet powerup." price:2000 type:5 purchased:NO equipped:NO number:5]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Asteroid Armor" description:@"Start each game with the Asteroid Armor powerup." price:4000 type:5 purchased:NO equipped:NO number:6]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Autopilot" description:@"Start each game with the Autopilot powerup." price:8000 type:5 purchased:NO equipped:NO number:7]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Random Powerup" description:@"Start each game with a random powerup." price:4000 type:5 purchased:NO equipped:NO number:8]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Head Start" description:@"Start each game with a huge speed boost!" price:20000 type:5 purchased:NO equipped:NO number:9]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Autopilot" description:@"Increase the duration of the Autopilot powerup." price:4000 type:3 purchased:NO equipped:NO number:10]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Pink Stars" description:@"Turn all stars pink. Are they worth more? No. Are they more fun? No. Are they super homo? Absolutely." price:599 type:4 purchased:NO equipped:NO number:11]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"30,000 Stars" description:@"Get 30,000 stars." price:99 type:4 purchased:NO equipped:NO number:12]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"70,000 Stars" description:@"Get 70,000 stars." price:199 type:4 purchased:NO equipped:NO number:13]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"120,000 Stars" description:@"Get 120,000 stars." price:299 type:4 purchased:NO equipped:NO number:14]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"300,000 Stars" description:@"Get 300,000 stars." price:499 type:4 purchased:NO equipped:NO number:15]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"1,000,000 Stars" description:@"Get 1,000,000 stars." price:999 type:4 purchased:NO equipped:NO number:16]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Green Spaceship" description:@"Turn your spaceship green." price:5000 type:1 purchased:NO equipped:NO number:17]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Blue Spaceship" description:@"Turn your spaceship blue" price:5000 type:1 purchased:NO equipped:NO number:18]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Golden Spaceship" description:@"Turn your spaceship gold." price:10000 type:1 purchased:NO equipped:NO number:19]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Orange Spaceship" description:@"Turn your spaceship orange." price:5000 type:1 purchased:NO equipped:NO number:20]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Red Spaceship" description:@"Turn your spaceship red." price:5000 type:1 purchased:NO equipped:NO number:21]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Purple Spaceship" description:@"Turn your spaceship purple." price:5000 type:1 purchased:NO equipped:NO number:22]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Pink Spaceship" description:@"Turn your spaceship pink." price:5000 type:1 purchased:NO equipped:NO number:23]];
    
    
    if (upgradeCodes) {
        for (int i = 0; i < [upgradeCodes count]; i++) {
            NSNumber *number = [upgradeCodes objectAtIndex:i];
            UpgradeItem *item = [[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:i];
            if ([number intValue] == 0) {
                item.purchased = YES;
                item.equipped = YES;
            } else if ([number intValue] == 1) {
                item.purchased = YES;
                item.equipped = NO;
            } else if ([number intValue] == 2) {
                item.purchased = NO;
                item.equipped = YES;
            } else {
                item.purchased = NO;
                item.equipped = NO;
            }
        }
    }
        
    int currGroup = [currentObjectiveGroupNumber intValue];
    if (!currGroup) {
        currGroup = 0;
    }
    [[ObjectiveManager sharedInstance] setCurrentObjectiveGroupNumber:currGroup];
 
    NSMutableArray *boolGroupsToUse = [[NSMutableArray alloc] init];
    
    int totalObjectiveGroups = 2;
    if (!objectives) {
        for (int i = 0; i < totalObjectiveGroups; i++) {
            NSMutableArray *boolsToUse = [[NSMutableArray alloc] init];
            for (int j = 0; j < 3; j++) {
                [boolsToUse addObject:[NSNumber numberWithBool:false]];
            }
            [boolGroupsToUse addObject:boolsToUse];
        }
    } else {
        for (int i = 0; i < totalObjectiveGroups; i++) {
            NSMutableArray *boolsToUse = [objectives objectAtIndex:i];
            for (int j = 0; j < 3; j++) {
                [boolsToUse addObject:[boolsToUse objectAtIndex:j]];
            }
            [boolGroupsToUse addObject:boolsToUse];
        }
    }
    
    NSMutableArray* groups = [[NSMutableArray alloc] init];
    NSMutableArray* bools = [[NSMutableArray alloc] init];
    
    int counter = -1;
    bools = [boolGroupsToUse objectAtIndex:++counter];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.1 starReward:5000
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the second galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Purchase an upgrade" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Get 10 stars in one run" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:++counter];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.1 starReward:500
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the third galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Get 15 stars in one run" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Get 20 stars in one run" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    objectives = groups;
    [[ObjectiveManager sharedInstance] setObjectiveGroups:objectives];
}

@end