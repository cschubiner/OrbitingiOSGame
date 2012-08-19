//
//  ObjectiveHeader.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/18/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ObjectiveItem : NSObject

@property (nonatomic, retain) NSString* text;
@property (nonatomic) bool completed;

-(id)initWithText:(NSString*)a_text;
-(bool)complete;

@end

@interface ObjectiveGroup : NSObject

@property (nonatomic, retain) NSMutableArray* objectiveItems;
@property (nonatomic) float scoreMult;
@property (nonatomic) int starReward;

-(id)initWithScoreMult:(float) a_scoreMult starReward:(int)a_starReward item0:(ObjectiveItem*)a_item0 item1:(ObjectiveItem*)a_item1 item2:(ObjectiveItem*)a_item2;

@end