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
static int MAX_BALANCE = 100000000;

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
        [self transactionMessageWithTitle:@"Upgrade Purchased" andBody:[NSString stringWithFormat:@"Remaining Balance: %i", [self getBalance]]];
    } else {
        [self transactionMessageWithTitle:@"Not Enough Coins" andBody:[NSString stringWithFormat:@"Current Balance: %i", [self getBalance]]];
    }
}

- (void)transactionMessageWithTitle:(NSString *)title andBody:(NSString *)body {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:@"Return" otherButtonTitles:nil];
    CGAffineTransform rot = CGAffineTransformMakeRotation(3.1415f * 0.5f); 
    CGAffineTransformScale(rot, 0.5f, 0.5f);
    [alertView show];
    [alertView release];
}

@end

