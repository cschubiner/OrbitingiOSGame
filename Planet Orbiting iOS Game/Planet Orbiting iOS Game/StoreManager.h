//
//  StoreManager.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/22/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreItem.h"

@interface StoreManager : NSObject {
    NSMutableArray *storeItems;
}

@property (nonatomic, retain) NSMutableArray *storeItems;

- (void)addItemToStore:(StoreItem *)item;
- (void)removeItemFromStore:(StoreItem *)item;

@end