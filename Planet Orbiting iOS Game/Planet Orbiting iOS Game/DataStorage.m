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
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Lithium Ion Battery" description:@"Increase your battery's efficiency to allow you to fly deeper into space." price:15000 type:2 purchased:NO equipped:NO number:4]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Star Magnet" description:@"Start each game with the Star Magnet powerup." price:2000 type:5 purchased:NO equipped:NO number:5]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Asteroid Armor" description:@"Start each game with the Asteroid Armor powerup." price:4000 type:5 purchased:NO equipped:NO number:6]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Autopilot" description:@"Start each game with the Autopilot powerup." price:8000 type:5 purchased:NO equipped:NO number:7]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Random Powerup" description:@"Start each game with a random powerup." price:4000 type:5 purchased:NO equipped:NO number:8]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Head Start" description:@"Start each game with a huge speed boost!" price:20000 type:5 purchased:NO equipped:NO number:9]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Autopilot" description:@"Increase the duration of the Autopilot powerup." price:4000 type:3 purchased:NO equipped:NO number:10]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Pink Stars" description:@"Turn all stars pink. Are they worth more? No. Are they more fun? No. Are they super awesome? Absolutely." price:599 type:4 purchased:NO equipped:NO number:11]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"30,000 Stars" description:@"Get 30,000 stars." price:99 type:4 purchased:NO equipped:NO number:12]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"70,000 Stars" description:@"Get 70,000 stars." price:199 type:4 purchased:NO equipped:NO number:13]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"120,000 Stars" description:@"Get 120,000 stars." price:299 type:4 purchased:NO equipped:NO number:14]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"300,000 Stars" description:@"Get 300,000 stars." price:499 type:4 purchased:NO equipped:NO number:15]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"1,000,000 Stars" description:@"Get 1,000,000 stars." price:999 type:4 purchased:NO equipped:NO number:16]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Camo Spaceship" description:@"Stay hidden from your enemies in this camoflauged spaceship!" price:10000 type:1 purchased:NO equipped:NO number:17]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"American Spaceship" description:@"Represent America with this red white and blue spaceship!" price:5000 type:1 purchased:NO equipped:NO number:18]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Bacon Spaceship" description:@"Turn your spaceship gold." price:10000 type:1 purchased:NO equipped:NO number:19]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Happy Spaceship" description:@"Turn your spaceship orange." price:5000 type:1 purchased:NO equipped:NO number:20]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Trippy Spaceship" description:@"Turn your spaceship red." price:5000 type:1 purchased:NO equipped:NO number:21]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Shark Spaceship" description:@"Turn your spaceship purple." price:5000 type:1 purchased:NO equipped:NO number:22]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Golden Spaceship" description:@"Turn your spaceship golden." price:5000 type:1 purchased:NO equipped:NO number:23]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Green Trail" description:@"Turn your trail green." price:2000 type:0 purchased:NO equipped:NO number:24]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Blue Trail" description:@"Turn your trail blue" price:2000 type:0 purchased:NO equipped:NO number:25]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Golden Trail" description:@"Turn your trail gold." price:5000 type:0 purchased:NO equipped:NO number:26]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Orange Trail" description:@"Turn your trail orange." price:2000 type:0 purchased:NO equipped:NO number:27]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Red Trail" description:@"Turn your trail red." price:2000 type:0 purchased:NO equipped:NO number:28]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Purple Trail" description:@"Turn your trail purple." price:2000 type:0 purchased:NO equipped:NO number:29]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Pink Trail" description:@"Turn your trail pink." price:2000 type:0 purchased:NO equipped:NO number:30]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Black Trail" description:@"Turn your trail black." price:2000 type:0 purchased:NO equipped:NO number:31]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Brown Trail" description:@"Turn your trail brown." price:2000 type:0 purchased:NO equipped:NO number:32]];
    
    
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
    
    int totalObjectiveGroups = 12; //the last number + 1
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
    NSMutableArray* bools;// = [[NSMutableArray alloc] init];
    
    bools = [boolGroupsToUse objectAtIndex:0];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.05 starReward:200
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Collect 10 stars in one game" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Reach a score of 5,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Reach the second galaxy" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:1];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.1 starReward:300
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Pick up a powerup" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Reach a score of 10,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Swipe 25 times in one game" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:2];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.15 starReward:600
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the third galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Collect 100 stars in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"View your highscore on the Highscores page" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:3];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.2 starReward:700
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Destroy 5 asteroids with the Asteroid Armor powerup" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Purchase an item from the store" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Collect 150 stars in one game" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:4];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.25 starReward:900
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the third galaxy without dying" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Reach a score of 24,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Reach the fourth galaxy" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:5];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.3 starReward:1100
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the third galaxy without hitting any asteroids" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Crash into 7 asteroids in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Finish a game having collected between 150 & 160 stars" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:6];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.35 starReward:1200
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Start a game with a new Spaceship Trail (available in the shop)" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Reach a score of 40,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Swipe 50 times in one game" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:7];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.4 starReward:1300
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Collect 200 stars in one game" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Finish a game with a score between 41,000 & 43,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Destroy 15 asteroids with the Asteroid Armor powerup" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:8];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.45 starReward:1500
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Start a game with a new Spaceship (available in the shop)" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Reach a score of 55,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Finish a game having collected between 220 & 230 stars" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:9];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.5 starReward:1700
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the fifth galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Collect 300 stars in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Pick up an autopilot powerup (also available in the shop)" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:10];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.55 starReward:1900
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the fourth galaxy without dying" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Crash into 15 asteroids in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Reach a score of 70,000" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:11];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.6 starReward:2200
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the sixth galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Collect 400 stars in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Finish a game having collected between 300 & 310 stars" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    
    [[ObjectiveManager sharedInstance] setMaxObjectiveGroupNumber:totalObjectiveGroups - 1];
    objectives = groups;
    [[ObjectiveManager sharedInstance] setObjectiveGroups:objectives];
}

@end