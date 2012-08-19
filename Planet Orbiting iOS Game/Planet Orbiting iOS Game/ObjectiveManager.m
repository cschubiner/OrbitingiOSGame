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
            sharedInstance.currentObjectiveGroupNumber = 0;
        }
    }
    return sharedInstance;
}

- (bool)completeObjective:(ObjectiveItem*)objective {
    return ([objective complete] ? true : false);
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