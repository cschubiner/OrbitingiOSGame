//
//  ObjectiveManager.m
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/18/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "ObjectiveManager.h"

@implementation ObjectiveManager

@synthesize objectiveGroups, currentObjectiveGroupNumber, maxObjectiveGroupNumber;

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

-(void)completeObjectiveFromGroupNumber:(int)a_groupNumber itemNumber:(int)a_itemNumber view:(CCLayer*)view {
    if (currentObjectiveGroupNumber == a_groupNumber) {
        ObjectiveItem* obj = [self getObjectiveFromGroupNumber:a_groupNumber itemNumber:a_itemNumber];
        if ([self completeObjective:obj]) {
            //[[GKAchievementHandler defaultHandler] notifyAchievementTitle:@"Mission Completed!" andMessage:obj.text];
            Toast* toast =[[Toast alloc] initWithView:view text:obj.text];
            [toast showToast];
        }
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

-(float)getscoreMultFromGroupNumber:(int)a_groupNumber {
    ObjectiveGroup* objectives = [objectiveGroups objectAtIndex:a_groupNumber];
    return objectives.scoreMult;
}

-(int)getStarRewardFromGroupNumber:(int)a_groupNumber {
    ObjectiveGroup* objectives = [objectiveGroups objectAtIndex:a_groupNumber];
    return objectives.starReward;
}

-(CCLayer*)createMissionPopupWithX:(bool)withX withDark:(bool)a_hasDark {
    CCLayer* mPopup = [[CCLayer alloc] init];
    
    if (a_hasDark) {
        CCSprite* dark = [CCSprite spriteWithFile:@"OneByOne.png"];
        [mPopup addChild:dark];
        dark.position = ccp(240, 160);
        dark.color = ccBLACK;
        dark.opacity = 190;
        dark.scaleX = 480;
        dark.scaleY = 320;
    }
    
    CCSprite* bg = [CCSprite spriteWithFile:(withX) ? @"popup2.png" : @"popup.png"];
    [mPopup addChild:bg];
    bg.position = ccp(240, 160);
    
    CCLabelTTF* missionLabel = [CCLabelTTF labelWithString:@"CURRENT MISSIONS" fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
    [mPopup addChild:missionLabel];
    missionLabel.position = ccp(240, 246);
    
    
    
    if ([[ObjectiveManager sharedInstance] currentObjectiveGroupNumber] > [[ObjectiveManager sharedInstance] maxObjectiveGroupNumber]) {
        [missionLabel setString:@"NO MORE MISSIONS"];
        return mPopup;
    }
    
    NSMutableArray* objectivesAtThisLevel = [[ObjectiveManager sharedInstance] getObjectivesFromGroupNumber:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
    
    ObjectiveGroup* currentGroup = [[[ObjectiveManager sharedInstance] objectiveGroups] objectAtIndex:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
    
    
    CCSprite* ind0 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:0]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
    CCSprite* ind1 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:1]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
    CCSprite* ind2 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:2]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
    [mPopup addChild:ind0];
    [mPopup addChild:ind1];
    [mPopup addChild:ind2];
    ind0.position = ccp(108, 211);
    ind1.position = ccp(108, 161);
    ind2.position = ccp(108, 112);
    
    CCLabelTTF* label0 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:0]) text] dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];


    CCLabelTTF* label1 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:1]) text] dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    CCLabelTTF* label2 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:2]) text] dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    [mPopup addChild:label0];
    [mPopup addChild:label1];
    [mPopup addChild:label2];
    label0.position = ccp(label0.boundingBox.size.width/2 + 134, 211);
    label1.position = ccp(label1.boundingBox.size.width/2 + 134, 161);
    label2.position = ccp(label2.boundingBox.size.width/2 + 134, 112);
    
    
    
    NSString* footerString = [NSString stringWithFormat:@"COMPLETE TO EARN %@ STARS", [self commaInt:currentGroup.starReward]];
    
    CCLabelTTF* footer = [CCLabelTTF labelWithString:footerString fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    [mPopup addChild:footer];
    footer.position = ccp(240, 74);
    return mPopup;
}

-(bool)checkIsDoneWithAllMissionsOnThisGroupNumber {
    NSMutableArray* objItems = [self getObjectivesFromGroupNumber:currentObjectiveGroupNumber];
    bool isAllDone = true;
    for (ObjectiveItem* item in objItems) {
        if (!item.completed) {
            isAllDone = false;
            break;
        }
    }
    return isAllDone;
}

-(void)uncompleteObjectivesFromCurrentGroupNumber {
    NSMutableArray* objItems = [self getObjectivesFromGroupNumber:currentObjectiveGroupNumber];
    for (ObjectiveItem* item in objItems) {
        item.completed = false;
    }
}

- (NSString*)commaInt:(int)num {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}

@end