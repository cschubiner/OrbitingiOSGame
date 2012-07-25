//
//  UserWallet.h
//  Planet Orbiting iOS Game
//
//  Created by Jeff Grimes on 7/21/12.
//  Copyright (c) 2012 Clayton Schubiner. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserWallet : NSObject {
    int balance;
}

@property (nonatomic) int balance;

+ (id)sharedInstance;

- (int)getBalance;
- (void)addCoins:(int)coinsToAdd;
- (void)removeCoins:(int)coinsToRemove;

@end