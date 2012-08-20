//
//  ObjectiveManager.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/18/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ObjectiveManager.h"

@implementation ObjectiveManager

@synthesize objectiveGroups, currentObjectiveGroupNumber;

static ObjectiveManager *sharedInstance = nil;

+ (id)sharedInstance {
    @synchronized([ObjectiveManager class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[ObjectiveManager alloc] init];
        }
    }
    return sharedInstance;
}

- (bool)completeObjective:(ObjectiveItem*)objective {
    return [objective complete];
}

-(void)completeObjectiveFromGroupNumber:(int)a_groupNumber itemNumber:(int)a_itemNumber {
    if (currentObjectiveGroupNumber == a_groupNumber) {
        ObjectiveItem* obj = [self getObjectiveFromGroupNumber:a_groupNumber itemNumber:a_itemNumber];
        if ([self completeObjective:obj])
            [[GKAchievementHandler defaultHandler] notifyAchievementTitle:@"Mission Completed!" andMessage:obj.text];
    }
}

-(NSMutableArray*)getObjectivesFromGroupNumber:(int)groupNumber {
    ObjectiveGroup* objectives = [objectiveGroups objectAtIndex:groupNumber];
    return objectives.objectiveItems;
}

-(ObjectiveItem*)getObjectiveFromGroupNumber:(int)groupNumber itemNumber:(int)itemNumber {
    ObjectiveGroup* objectives = [objectiveGroups objectAtIndex:groupNumber];
    return [objectives.objectiveItems objectAtIndex:itemNumber];
}

@end