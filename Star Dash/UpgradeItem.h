//
//  UpgradeItem.h
//  Planet Orbiting iOS Game
//
//  Created by Alex Blickenstaff on 8/8/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpgradeItem : NSObject

@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* description;
@property (nonatomic, retain) NSString* icon;
@property (nonatomic, retain) NSMutableArray* prices;
@property (nonatomic) int level;

-(id)initWithTitle:(NSString*)tit description:(NSString*)desc icon:(NSString*)ic prices:(NSMutableArray*)prs level:(int)lvl;

@end
