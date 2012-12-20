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

-(bool)completeObjectiveFromGroupNumber:(int)a_groupNumber itemNumber:(int)a_itemNumber view:(CCLayer*)view {
    if (currentObjectiveGroupNumber == a_groupNumber) {
        ObjectiveItem* obj = [self getObjectiveFromGroupNumber:a_groupNumber itemNumber:a_itemNumber];
        if ([self completeObjective:obj]) {
            //[[GKAchievementHandler defaultHandler] notifyAchievementTitle:@"Mission Completed!" andMessage:obj.text];
            Toast* toast =[[Toast alloc] initWithView:view text:obj.text];
            [toast showToast];
            return true;
        }
    }
    return false;
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
    if (a_groupNumber > maxObjectiveGroupNumber)
        a_groupNumber = maxObjectiveGroupNumber;
    ObjectiveGroup* objectives = [objectiveGroups objectAtIndex:a_groupNumber];
    return objectives.scoreMult;
}

-(float)getscoreMultFromCurrentGroupNumber {
    return [self getscoreMultFromGroupNumber:currentObjectiveGroupNumber];
}

-(int)getStarRewardFromGroupNumber:(int)a_groupNumber {
    ObjectiveGroup* objectives = [objectiveGroups objectAtIndex:a_groupNumber];
    return objectives.starReward;
}

+(CCSprite*)labelWithString:(NSString *)string fontName:(NSString *)fontName fontSize:(CGFloat)fontSize color:(ccColor3B)color strokeSize:(CGFloat)strokeSize stokeColor:(ccColor3B)strokeColor {
    
	CCLabelTTF *label = [CCLabelTTF labelWithString:string fontName:fontName fontSize:fontSize];
    
	CCRenderTexture* rt = [CCRenderTexture renderTextureWithWidth:label.texture.contentSize.width + strokeSize*2  height:label.texture.contentSize.height+strokeSize*2];
    
	[label setFlipY:YES];
	[label setColor:strokeColor];
	ccBlendFunc originalBlendFunc = [label blendFunc];
	[label setBlendFunc:(ccBlendFunc) { GL_SRC_ALPHA, GL_ONE }];
    
	CGPoint bottomLeft = ccp(label.texture.contentSize.width * label.anchorPoint.x + strokeSize, label.texture.contentSize.height * label.anchorPoint.y + strokeSize);
	CGPoint position = ccpSub([label position], ccp(-label.contentSize.width / 2.0f, -label.contentSize.height / 2.0f));
    
	[rt begin];
    
	for (int i=0; i<360; i++) // you should optimize that for your needs
	{
		[label setPosition:ccp(bottomLeft.x + sin(CC_DEGREES_TO_RADIANS(i))*strokeSize, bottomLeft.y + cos(CC_DEGREES_TO_RADIANS(i))*strokeSize)];
		[label visit];
	}
    
	[label setPosition:bottomLeft];
	[label setBlendFunc:originalBlendFunc];
	[label setColor:color];
	[label visit];
    
	[rt end];
    
	[rt setPosition:position];
    
	return [CCSprite spriteWithTexture:rt.sprite.texture];
    
}

-(CCLayer*)createMissionPopupWithX:(bool)withX withDark:(bool)a_hasDark {
    size = [[CCDirector sharedDirector] winSize];

    CCLayer* mPopup = [[CCLayer alloc] init];
    if (IS_IPHONE_5)
    {
        mPopup.position = ccpAdd(mPopup.position, ccp(HALF_IPHONE_5_ADDITIONAL_WIDTH,0));
    }
    if (a_hasDark) {
        CCSprite* dark = [CCSprite spriteWithFile:@"black.png"];
        [mPopup addChild:dark];
        dark.position = ccp(240, 160);
        dark.opacity = 200;
        
        if (IS_IPHONE_5)
            dark.scaleX = IPHONE_5_RATIO;
    }
    
    CCSprite* bg = [CCSprite spriteWithFile:(withX) ? @"popup2.png" : @"popup.png"];
    [mPopup addChild:bg];
    bg.position = ccp(240, 160);
    
    CCLabelTTF* missionLabel = [CCLabelTTF labelWithString:@"CURRENT MISSIONS" fontName:@"HelveticaNeue-CondensedBold" fontSize:24];
    //[mPopup addChild:missionLabel];
    missionLabel.position = ccp(240, 246);
    
    CCSprite* missionLabelSprite = [self.class labelWithString:@"CURRENT MISSIONS" fontName:@"HelveticaNeue-CondensedBold" fontSize:24 color:ccWHITE strokeSize:1.1 stokeColor:ccBLACK];
    [mPopup addChild:missionLabelSprite];
    missionLabelSprite.position = ccp(240, 246);
    
    if ([[ObjectiveManager sharedInstance] currentObjectiveGroupNumber] > [[ObjectiveManager sharedInstance] maxObjectiveGroupNumber]) {
        [missionLabel setString:@"ALL MISSIONS COMPLETE!"];
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
    
    CCLabelTTF* label0 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:0]) text] dimensions:CGSizeMake(263, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];


    CCLabelTTF* label1 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:1]) text] dimensions:CGSizeMake(263, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    CCLabelTTF* label2 = [CCLabelTTF labelWithString:[((ObjectiveItem*)[objectivesAtThisLevel objectAtIndex:2]) text] dimensions:CGSizeMake(263, 55) hAlignment:UITextAlignmentLeft vAlignment:UITextAlignmentCenter lineBreakMode:UITextAlignmentLeft fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    [mPopup addChild:label0];
    [mPopup addChild:label1];
    [mPopup addChild:label2];
    label0.position = ccp(label0.boundingBox.size.width/2 + 134, 211);
    label1.position = ccp(label1.boundingBox.size.width/2 + 134, 161);
    label2.position = ccp(label2.boundingBox.size.width/2 + 134, 112);
    
    
    
    NSString* footerString = [NSString stringWithFormat:@"COMPLETE TO EARN %@", [self commaInt:currentGroup.starReward]];
    
    CCLabelTTF* footer = [CCLabelTTF labelWithString:footerString fontName:@"HelveticaNeue-CondensedBold" fontSize:18];
    [mPopup addChild:footer];
    footer.position = ccp(240, 74);
    
    
    CCSprite* starSprite = [CCSprite spriteWithFile:@"staricon.png"];
    [mPopup addChild:starSprite];
    starSprite.scale = .42;
    starSprite.position = ccpAdd(footer.position, ccp(footer.boundingBox.size.width/2 + 12, 2));
    
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

-(bool)shouldDisplayLevelUpAnimation {
    if (currentObjectiveGroupNumber > maxObjectiveGroupNumber)
        return false;
    if ([self checkIsDoneWithAllMissionsOnThisGroupNumber]) {
        if ([self currentObjectiveGroupNumber] < [self maxObjectiveGroupNumber] + 1)
            return true;
    }
    return false;
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