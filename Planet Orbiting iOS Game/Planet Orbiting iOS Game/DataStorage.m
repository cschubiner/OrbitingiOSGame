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
        BOOL A = item.exclusive;
        BOOL B = item.purchased;
        BOOL C = item.equipped;
        if (A && B && C) {
            [upgradeCodes addObject:[NSNumber numberWithInt:0]];
        } else if (A && B && !C) {
            [upgradeCodes addObject:[NSNumber numberWithInt:1]];
        } else if (A && !B && C) {
            [upgradeCodes addObject:[NSNumber numberWithInt:2]];
        } else if (A && !B && !C) {
            [upgradeCodes addObject:[NSNumber numberWithInt:3]];
        } else if (!A && B && C) {
            [upgradeCodes addObject:[NSNumber numberWithInt:4]];
        } else if (!A && B && !C) {
            [upgradeCodes addObject:[NSNumber numberWithInt:5]];
        } else if (!A && !B && C) {
            [upgradeCodes addObject:[NSNumber numberWithInt:6]];
        } else {
            [upgradeCodes addObject:[NSNumber numberWithInt:7]];
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
    
    NSMutableArray* upgrades = [[NSMutableArray alloc] init];
    
    if (!upgradeCodes) {
        [upgrades addObject:[[UpgradeItem alloc] initWithTitle:@"Star Magnet" description:@"Increase the duration and effective range of the Star Magnet powerup." price:10 type:0 exclusive:NO purchased:NO equipped:NO]];
        [upgrades addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Armor" description:@"Increase the duration of the Asteroid Armor powerup." price:2000 type:0 exclusive:NO purchased:NO equipped:NO]];
        [upgrades addObject:[[UpgradeItem alloc] initWithTitle:@"Nitrous Rocket" description:@"Increase the strength of your rocket to fly faster through space." price:4000 type:0 exclusive:NO purchased:NO equipped:NO]];
        [upgrades addObject:[[UpgradeItem alloc] initWithTitle:@"Double Stars" description:@"A great long-term investment - each star you collect is worth two." price:8000 type:0 exclusive:NO purchased:NO equipped:NO]];
        [upgrades addObject:[[UpgradeItem alloc] initWithTitle:@"Lithium Ion Battery" description:@"Increase your battery's efficiency to allow you to fly deeper into space." price:16000 type:0 exclusive:NO purchased:NO equipped:NO]];
        [upgrades addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Powerup" description:@"Start each game with a random powerup." price:32000 type:0 exclusive:NO purchased:NO equipped:NO]];
        [[UpgradeManager sharedInstance] setUpgradeItems:upgrades];
    } else {
        for (int i = 0; i < [[[UpgradeManager sharedInstance] upgradeItems] count]; i++) {
            NSNumber *number = [upgradeCodes objectAtIndex:i];
            UpgradeItem *item = [[[UpgradeManager sharedInstance] upgradeItems] objectAtIndex:i];
            if ([number intValue] == 0) {
                item.exclusive = YES;
                item.purchased = YES;
                item.equipped = YES;
            } else if ([number intValue] == 1) {
                item.exclusive = YES;
                item.purchased = YES;
                item.equipped = NO;
            } else if ([number intValue] == 2) {
                item.exclusive = YES;
                item.purchased = NO;
                item.equipped = YES;
            } else if ([number intValue] == 3) {
                item.exclusive = YES;
                item.purchased = NO;
                item.equipped = NO;
            } else if ([number intValue] == 4) {
                item.exclusive = NO;
                item.purchased = YES;
                item.equipped = YES;
            } else if ([number intValue] == 5) {
                item.exclusive = NO;
                item.purchased = YES;
                item.equipped = NO;
            } else if ([number intValue] == 6) {
                item.exclusive = NO;
                item.purchased = NO;
                item.equipped = YES;
            } else {
                item.exclusive = NO;
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
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.1 starReward:500
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