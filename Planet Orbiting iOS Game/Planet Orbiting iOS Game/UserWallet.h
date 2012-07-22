//
//  UserWallet.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/21/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserWalletProtocol <NSObject>
- (void)updatedWalletSuccess;
- (void)updatedWalletFailure:(NSString *)errorText;
@end

@interface UserWallet : NSObject {
    id <UserWalletProtocol> userWalletDelegate;
}

+ (id)sharedInstance;

- (int)getBalance;
- (void)addCoins:(int)coinsToAdd;
- (void)removeCoins:(int)coinsToRemove;

@end