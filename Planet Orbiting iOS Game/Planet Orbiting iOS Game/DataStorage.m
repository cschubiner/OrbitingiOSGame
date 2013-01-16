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
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Star Magnet" description:@"Increase the duration and effective range of the Star Magnet powerup." price:5000 type:3 purchased:NO equipped:NO number:0]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Asteroid Armor" description:@"Increase the duration of the Asteroid Armor powerup." price:8000 type:3 purchased:NO equipped:NO number:1]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Nitrous Rocket" description:@"Increase the strength of your rocket to fly faster through space." price:40000 type:2 purchased:NO equipped:NO number:2]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Double Stars" description:@"A great long-term investment! Each star you collect is worth two." price:199 type:4 purchased:NO equipped:NO number:3]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Lithium Ion Battery" description:@"Increase your battery's efficiency to allow you to fly deeper into space." price:50000 type:2 purchased:NO equipped:NO number:4]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Star Magnet" description:@"Start each game with the Star Magnet powerup." price:5000 type:5 purchased:NO equipped:NO number:5]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Asteroid Armor" description:@"Start each game with the Asteroid Armor powerup." price:8000 type:5 purchased:NO equipped:NO number:6]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Autopilot" description:@"Start each game with the Autopilot powerup." price:20000 type:5 purchased:NO equipped:NO number:7]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starting Random Powerup" description:@"Start each game with a random powerup." price:10000 type:5 purchased:NO equipped:NO number:8]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Head Start" description:@"Start each game with a huge speed boost!" price:100000 type:5 purchased:NO equipped:NO number:9]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Autopilot" description:@"Increase the duration of the Autopilot powerup." price:6000 type:3 purchased:NO equipped:NO number:10]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Pink Stars" description:@"Turn all stars pink. Are they worth more? No. Are they more fun? Meh. Are they super awesome? Absolutely." price:599 type:4 purchased:NO equipped:NO number:11]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Starter Pack (30,000 Stars)" description:@"Get a quick fix of stars to make ends meet. Get that final bit of cash to grab your next awesome upgrade!" price:99 type:4 purchased:NO equipped:NO number:12]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Bag O' Stars (70,000 Stars)" description:@"Deck out your ride with some sweet new trails or grab some quick perks for pursuing those high scores!" price:199 type:4 purchased:NO equipped:NO number:13]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Galaxy Pack (120,000 Stars)" description:@"Some pretty serious cash will be at your disposal. Upgrade your ship and purchase that Lithium Ion battery to max out your score!" price:299 type:4 purchased:NO equipped:NO number:14]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Warp-Speed Pack (300,000 Stars)" description:@"Make sure you're covered in flour, 'cause you'll be rolling in dough." price:499 type:4 purchased:NO equipped:NO number:15]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"StarMaster Pack (1,000,000 Stars)" description:@"You'll have enough cash to pursue your wildest dreams. You are the StarMaster." price:999 type:4 purchased:NO equipped:NO number:16]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Camo Spaceship" description:@"Stay hidden from your enemies in this camoflauged spaceship!" price:10000 type:1 purchased:NO equipped:NO number:17]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"American Spaceship" description:@"Represent America with this red, white, and blue spaceship!" price:200000 type:1 purchased:NO equipped:NO number:18]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Bacon Spaceship" description:@"Release your inner man with this meaty spaceship." price:500000 type:1 purchased:NO equipped:NO number:19]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Happy Spaceship" description:@"This spaceship is guaranteed to turn that frown upside-down!" price:100000 type:1 purchased:NO equipped:NO number:20]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Trippy Spaceship" description:@"Take a trip in a time machine back to the 70s with this psychedelic spaceship." price:30000 type:1 purchased:NO equipped:NO number:21]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Shark Spaceship" description:@"Become the king of the ocean with this shark-like spacehip!" price:1000000 type:1 purchased:NO equipped:NO number:22]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Golden Spaceship" description:@"The legendary golden spaceship. Do you have what it takes to pilot this heavenly space machine?" price:5000000 type:1 purchased:NO equipped:NO number:23]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Green Trail" description:@"Turn your trail green." price:2000 type:0 purchased:NO equipped:NO number:24]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Blue Trail" description:@"Turn your trail blue." price:2000 type:0 purchased:NO equipped:NO number:25]];
    
    [[[UpgradeManager sharedInstance] upgradeItems] addObject:[[UpgradeItem alloc] initWithTitle:@"Golden Trail" description:@"Turn your trail gold." price:1000000 type:0 purchased:NO equipped:NO number:26]];
    
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
    
    int totalObjectiveGroups = 16; //the last number + 1
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
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.05 starReward:400
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Collect 10 stars in one game" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Reach a score of 8,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Reach the second galaxy" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:1];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.1 starReward:600
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Pick up a powerup" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Reach a score of 15,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Swipe 25 times in one game" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:2];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.15 starReward:800
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the third galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Collect 100 stars in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"View your highscore on the Highscores page" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:3];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.2 starReward:1000
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Destroy 5 asteroids with the Asteroid Armor powerup" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Purchase an item from the store" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Collect 150 stars in one game" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:4];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.22 starReward:1200
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the third galaxy without dying" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Reach a score of 30,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Reach the fourth galaxy" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:5];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.24 starReward:1400
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the third galaxy without hitting any asteroids" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Crash into 7 asteroids in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Finish a game having collected between 150 & 160 stars" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:6];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.26 starReward:1600
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Start a game with a new Spaceship Trail (available in the shop)" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Reach a score of 50,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Swipe 50 times in one game" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:7];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.28 starReward:1800
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Collect 200 stars in one game" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Finish a game with a score between 41,000 & 43,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Destroy 15 asteroids with the Asteroid Armor powerup" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:8];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.30 starReward:2000
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Start a game with a new Spaceship (available in the shop)" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Reach a score of 65,000" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Finish a game having collected between 220 & 230 stars" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:9];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.32 starReward:2200
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the fifth galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Collect 300 stars in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Pick up an autopilot powerup (also available in the shop)" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:10];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.34 starReward:2400
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the fourth galaxy without dying" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Crash into 15 asteroids in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Reach a score of 80,000" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:11];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.36 starReward:2600
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the sixth galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Collect 400 stars in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Finish a game having collected between 300 & 310 stars" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:12];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.38 starReward:2800
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the seventh galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Collect 500 stars in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Reach a score of 90,000" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:13];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.4 starReward:3000
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the eighth galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Collect 600 stars in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Reach a score of 100,000" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:14];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.4 starReward:3500
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the ninth galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Collect 800 stars in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Reach a score of 120,000" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    bools = [boolGroupsToUse objectAtIndex:15];
    [groups addObject:[[ObjectiveGroup alloc] initWithScoreMult:1.5 starReward:10000
                                                          item0:[[ObjectiveItem alloc] initWithText:@"Reach the tenth galaxy" isCompleted:[[bools objectAtIndex:0] boolValue]]
                                                          item1:[[ObjectiveItem alloc] initWithText:@"Collect 2,500 stars in one game" isCompleted:[[bools objectAtIndex:1] boolValue]]
                                                          item2:[[ObjectiveItem alloc] initWithText:@"Reach a score of 250,000" isCompleted:[[bools objectAtIndex:2] boolValue]]]];
    
    
    [[ObjectiveManager sharedInstance] setMaxObjectiveGroupNumber:totalObjectiveGroups - 1];
    objectives = groups;
    [[ObjectiveManager sharedInstance] setObjectiveGroups:objectives];
}

@end