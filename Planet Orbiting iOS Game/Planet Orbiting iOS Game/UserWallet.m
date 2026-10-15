//
//  UserWallet.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/21/12.
//  Copyright (c) 2012 Clayton Schubiner. All rights reserved.
//

#import "UserWallet.h"
#import <limits.h>

@implementation UserWallet

@synthesize balance;

static UserWallet *sharedInstance = nil;
static int MAX_BALANCE = INT_MAX;

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
    if (coinsToAdd > 0) balance = (int)MIN((int64_t)MAX_BALANCE, (int64_t)balance + coinsToAdd);
}

- (void)removeCoins:(int)coinsToRemove {
    if (balance - coinsToRemove >= 0) {
        balance -= coinsToRemove;
    }
}

@end

