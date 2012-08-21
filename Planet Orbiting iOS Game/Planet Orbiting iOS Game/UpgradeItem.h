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
@property (nonatomic, assign) BOOL exclusive;
@property (nonatomic, assign) BOOL equipped;

-(id)initWithTitle:(NSString*)cTitle description:(NSString*)cDescription exclusive:(BOOL)cExclusive equipped:(BOOL)cEquipped;

@end
