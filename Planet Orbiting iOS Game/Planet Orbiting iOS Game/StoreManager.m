//
//  StoreManager.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/22/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "StoreManager.h"
#import "StoreItem.h"
#import "UserWallet.h"

@implementation StoreManager {
    StoreItem *itemToBuy;
}

@synthesize storeItems;

- (id)init {
    if (self = [super init]) {
        storeItems = [[NSMutableArray alloc] init];
        itemToBuy = nil;
    }
    return self;
}

- (void)purchaseItemWithID:(int)itemID {
    itemToBuy = [storeItems objectAtIndex:itemID];
    int itemPrice = [itemToBuy price];
    [[UserWallet sharedInstance] removeCoins:itemPrice];
}

- (void)addItemToStore:(StoreItem *)item {
    [storeItems addObject:item];
    NSLog(@"Items in store: %@", [self listItems]);
}

- (void)removeItemFromStore:(StoreItem *)item {
    [storeItems removeObject:item];
    NSLog(@"Items in store: %@", [self listItems]);
}

- (NSString *)listItems {
    NSString *itemsList = @"";
    for (StoreItem *item in storeItems) {
        itemsList = [itemsList stringByAppendingString:[item title]];
        itemsList = [itemsList stringByAppendingString:@", "];
    }
    return itemsList;
}

@end