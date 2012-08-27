//
//  ObjectiveManager.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/18/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectiveHeader.h"
#import "GKAchievementHandler.h"
#import "cocos2d.h"
#import "Toast.h"

@interface ObjectiveManager : NSObject

@property (nonatomic, retain) NSMutableArray* objectiveGroups;
@property (nonatomic) int currentObjectiveGroupNumber;
@property (nonatomic) int maxObjectiveGroupNumber;

+ (id)sharedInstance;

- (bool)completeObjective:(ObjectiveItem*)objective;

-(NSMutableArray*)getObjectivesFromGroupNumber:(int)groupNumber;
-(ObjectiveItem*)getObjectiveFromGroupNumber:(int)groupNumber itemNumber:(int)itemNumber;
-(CCLayer*)createMissionPopupWithX:(bool)withX withDark:(bool)a_hasDark;

-(void)completeObjectiveFromGroupNumber:(int)a_groupNumber itemNumber:(int)a_itemNumber view:(CCLayer*)view;

-(void)uncompleteObjectivesFromCurrentGroupNumber;

-(float)getscoreMultFromGroupNumber:(int)a_groupNumber;
-(int)getStarRewardFromGroupNumber:(int)a_groupNumber;

-(bool)checkIsDoneWithAllMissionsOnThisGroupNumber;

@end