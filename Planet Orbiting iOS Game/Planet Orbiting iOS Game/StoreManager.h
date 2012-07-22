//
//  StoreManager.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/22/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StoreItem.h"
#import "UserWallet.h"

@protocol StoreManagerProtocol <NSObject>
- (void)refreshItemsView;
@end

@interface StoreManager : NSObject <UserWalletProtocol> {
    NSMutableArray *storeItems;
    id <StoreManagerProtocol> storeManagerDelegate;
}

@property (nonatomic, retain) NSMutableArray *storeItems;

// class methods
+ (id)sharedInstance;

// instance methods
- (void)addItemToStore:(StoreItem *)item;
- (void)removeItemFromStore:(StoreItem *)item;

// delegate methods
- (void)updatedWalletSuccess;
- (void)updatedWalletFailure:(NSString *)errorText;

@end