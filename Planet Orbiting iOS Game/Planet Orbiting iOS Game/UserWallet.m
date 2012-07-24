//
//  UserWallet.m
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/21/12.
//  Copyright (c) 2012 Clayton Schubiner. All rights reserved.
//

#import "UserWallet.h"

@implementation UserWallet {
    int balance;
}

@synthesize userWalletDelegate;

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
    } else {
        [self transactionMessageWithTitle:@"Can't Add Coins" andBody:[NSString stringWithFormat:@"Max coins reached.\n\nCurrent Balance: %i", [self getBalance]]];    }
}

- (void)removeCoins:(int)coinsToRemove {
    if (balance - coinsToRemove >= 0) {
        balance -= coinsToRemove;
        [self transactionMessageWithTitle:@"Upgrade Purchased" andBody:[NSString stringWithFormat:@"You bought some shitty upgrade. Good riddance to it.\n\nRemaining Balance: %i", [self getBalance]]];
    } else {
        [self transactionMessageWithTitle:@"Transaction Failed" andBody:[NSString stringWithFormat:@"Not enough coins.\n\nCurrent Balance: %i", [self getBalance]]];
    }
}

- (void)transactionMessageWithTitle:(NSString *)title andBody:(NSString *)body {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:@"Return" otherButtonTitles: nil];
    [alertView show];
    [alertView release];
}

@end

