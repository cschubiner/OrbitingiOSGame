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
@property (nonatomic, assign) int price;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int number;
@property (nonatomic, assign) BOOL purchased;
@property (nonatomic, assign) BOOL equipped;

- (id)initWithTitle:(NSString*)cTitle description:(NSString*)cDescription price:(int)cPrice type:(int)cType purchased:(BOOL)cPurchased equipped:(BOOL)cEquipped number:(int)a_number;

@end