//
//  StoreItem.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/22/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoreItem : NSObject {
    NSString *title;
    NSString *description;
    int itemID;
    int price;
}

@property (nonatomic) int price;
@property (nonatomic) int itemID;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *description;

@end