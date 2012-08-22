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

-(CCLayer*)createMissionPopupWithX:(bool)withX {
    CCLayer* mPopup = [[CCLayer alloc] init];
    
    CCSprite* bg = [CCSprite spriteWithFile:(withX) ? @"missionsModal.png" : @"missionsBG.png"];
    [mPopup addChild:bg];
    bg.position = ccp(240, 160);
    
    CCLabelTTF* missionLabel = [CCLabelTTF labelWithString:@"CURRENT MISSIONS" fontName:@"HelveticaNeue-CondensedBold" fontSize:22];
    [mPopup addChild:missionLabel];
    missionLabel.position = ccp(240, 252);
    
    NSMutableArray* objectivesAtThisLevel = [[ObjectiveManager sharedInstance] getObjectivesFromGroupNumber:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
    
    ObjectiveGroup* currentGroup = [[[ObjectiveManager sharedInstance] objectiveGroups] objectAtIndex:[[ObjectiveManager sharedInstance] currentObjectiveGroupNumber]];
    
    
    CCSprite* ind0 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:0]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
    CCSprite* ind1 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:1]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
    CCSprite* ind2 = [CCSprite spriteWithFile:([((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:2]) completed]) ? @"missioncomplete.png" : @"yousuck.png"];
    [mPopup addChild:ind0];
    [mPopup addChild:ind1];
    [mPopup addChild:ind2];
    ind0.position = ccp(104, 209);
    ind1.position = ccp(104, 154);
    ind2.position = ccp(104, 100);
    
    CCLabelTTF* label0 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:0]) text] dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    CCLabelTTF* label1 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:1]) text] dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    CCLabelTTF* label2 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:2]) text] dimensions:CGSizeMake(273, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    [mPopup addChild:label0];
    [mPopup addChild:label1];
    [mPopup addChild:label2];
    label0.position = ccp(label0.boundingBox.size.width/2 + 134, 209);
    label1.position = ccp(label1.boundingBox.size.width/2 + 134, 154);
    label2.position = ccp(label2.boundingBox.size.width/2 + 134, 100);
    
    
    
    NSString* footerString = [NSString stringWithFormat:@"REWARD: %.1fx MULTIPLIER & %@ STARS", currentGroup.scoreMult, [self commaInt:currentGroup.starReward]];
    
    CCLabelTTF* footer = [CCLabelTTF labelWithString:footerString fontName:@"HelveticaNeue-CondensedBold" fontSize:17];
    [mPopup addChild:footer];
    footer.position = ccp(240, 61);
    return mPopup;
}

- (NSString*)commaInt:(int)num {
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    return [formatter stringFromNumber:[NSNumber numberWithInteger:num]];
}

@end