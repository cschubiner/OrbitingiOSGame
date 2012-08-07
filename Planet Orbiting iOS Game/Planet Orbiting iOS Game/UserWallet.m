//
//  UserWallet.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/21/12.
//  Copyright (c) 2012 Clayton Schubiner. All rights reserved.
//

#import "UserWallet.h"

@implementation UserWallet

@synthesize balance;

static UserWallet *sharedInstance = nil;
static int MAX_BALANCE = 10000000000;

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
    }
}

- (void)removeCoins:(int)coinsToRemove {
    if (balance - coinsToRemove >= 0) {
        balance -= coinsToRemove;
    }
}

@end

