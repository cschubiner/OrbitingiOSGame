//
//  UserWallet.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/21/12.
//  Copyright (c) 2012 Stanford University. All rights reserved.
//

#import "UserWallet.h"

@implementation UserWallet {
    int balance;
}

static UserWallet *sharedInstance = nil;
static int MAX_BALANCE = 1000;

+ (id)sharedInstance {
    @synchronized([UserWallet class]) {
        if (sharedInstance == nil) {
            sharedInstance = [[UserWallet alloc] init];
        }
    }
    return sharedInstance;
}

- (int)getBalance {
    return balance;
}

- (void)addCoins:(int)coinsToAdd {
    if (balance + coinsToAdd <= MAX_BALANCE) {
        balance += coinsToAdd;
        [self callGotUserWalletSuccess];
    } else {
        [self callGotUserWalletFailure:@"Coins exceed max balance"];
    }
}

- (void)removeCoins:(int)coinsToRemove {
    if (balance - coinsToRemove >= 0) {
        balance -= coinsToRemove;
        [self callGotUserWalletSuccess];
    } else {
        [self callGotUserWalletFailure:@"Not enough coins"];
    }
}

- (void)callGotUserWalletSuccess {
    NSLog(@"callGotUserWalletSuccess");
    if (userWalletDelegate) {
        if ([userWalletDelegate respondsToSelector:@selector(gotUserWalletSuccess)]) {
            [userWalletDelegate updatedWalletSuccess];
        } else {
            NSLog(@"delegate does not respond to gotUserWalletSuccess");
        }
    }
}

- (void)callGotUserWalletFailure:(NSString *)errorText {
    NSLog(@"callGotUserWalletFailure");
    if (userWalletDelegate) {
        if ([userWalletDelegate respondsToSelector:@selector(gotUserWalletFailure:)]) {
            [userWalletDelegate updatedWalletFailure:errorText];
        } else {
            NSLog(@"delegate does not respond to gotUserWalletFailure");
        }
    }
}

@end