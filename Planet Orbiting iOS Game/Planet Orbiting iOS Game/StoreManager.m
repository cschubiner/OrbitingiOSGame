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

static StoreManager *sharedInstance = nil;

@synthesize storeItems;

+ (id)sharedInstance {
    @synchronized([StoreManager class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[StoreManager alloc] init];
        }
    }
    return sharedInstance;
}

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

- (void)updatedWalletSuccess {
    [storeItems removeObject:itemToBuy];
    [self callRefreshItemsView];
    itemToBuy = nil;
}

- (void)updatedWalletFailure:(NSString *)errorText {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Transaction Failed" message:errorText delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}

// the delegate is a GUI class that displays the items, so its view must be updated after each transaction/change
- (void)callRefreshItemsView {
    NSLog(@"callRefreshItemsView");
    if (storeManagerDelegate) {
        if ([storeManagerDelegate respondsToSelector:@selector(refreshItemsView)]) {
            [storeManagerDelegate refreshItemsView];
        } else {
            NSLog(@"delegate does not respond to callRefreshItemsView");
        }
    }
}

@end