//
//  IAPHelper.m
//  InAppRage
//
//  Created by Ray Wenderlich on 2/28/11.
//  Copyright 2011 Ray Wenderlich. All rights reserved.
//

#import "IAPHelper.h"
#import "iRate.h"
#import "UserWallet.h"
#import "UpgradeManager.h"

@implementation IAPHelper
@synthesize productIdentifiers = _productIdentifiers;
@synthesize products = _products;
@synthesize purchasedProducts = _purchasedProducts;
@synthesize request = _request;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers {
    if ((self = [super init])) {
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        // Store product identifiers
        _productIdentifiers = [productIdentifiers retain];
        
        // Check for previously purchased products
        NSMutableSet * purchasedProducts = [NSMutableSet set];
        for (NSString * productIdentifier in _productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            if (productPurchased) {
                [purchasedProducts addObject:productIdentifier];
                NSLog(@"Previously purchased: %@", productIdentifier);
            }
            NSLog(@"Not purchased: %@", productIdentifier);
        }
        self.purchasedProducts = purchasedProducts;
                        
    }
    return self;
}

- (void)requestProducts {
    
    self.request = [[[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers] autorelease];
    _request.delegate = self;
    [_request start];
    
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    NSLog(@"Received products results...");   
    self.products = response.products;
    self.request = nil;    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kProductsLoadedNotification object:_products];    
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {    
    // TODO: Record the transaction on the server side...    
}

- (void)provideContent:(NSString *)productIdentifier {
    
    NSLog(@"Toggling flag for: %@", productIdentifier);
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_purchasedProducts addObject:productIdentifier];
    
    [self productPurchased:productIdentifier];
    
}

- (void)productPurchased:(NSString*)productIdentifier{
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    NSLog(@"Purchased: %@", productIdentifier);
    
    NSString * purchaseTitle = @"upgrade";
    
    for (int i = 0 ; i < 8; i++)
        [[iRate sharedInstance] logEvent:YES];
    
    if ([productIdentifier isEqualToString:@"1000000stars"]) {
        int curBalance = [[UserWallet sharedInstance] getBalance];
        int newBalance = curBalance + 1000000;
        [[UserWallet sharedInstance] setBalance:newBalance];
        purchaseTitle = @"One Million Star Pack";
    }
    else if ([productIdentifier isEqualToString:@"300000stars"]) {
        int curBalance = [[UserWallet sharedInstance] getBalance];
        int newBalance = curBalance + 300000;
        [[UserWallet sharedInstance] setBalance:newBalance];
        purchaseTitle = @"300,000 Star Pack";
        
    }
    else if ([productIdentifier isEqualToString:@"120000stars"]) {
        int curBalance = [[UserWallet sharedInstance] getBalance];
        int newBalance = curBalance + 120000;
        [[UserWallet sharedInstance] setBalance:newBalance];
        purchaseTitle = @"120,000 Star Pack";
    }
    else if ([productIdentifier isEqualToString:@"70000stars"]) {
        int curBalance = [[UserWallet sharedInstance] getBalance];
        int newBalance = curBalance + 70000;
        [[UserWallet sharedInstance] setBalance:newBalance];
        purchaseTitle = @"70,000 Star Pack";
    }
    else if ([productIdentifier isEqualToString:@"30000stars"]) {
        int curBalance = [[UserWallet sharedInstance] getBalance];
        int newBalance = curBalance + 30000;
        [[UserWallet sharedInstance] setBalance:newBalance];
        purchaseTitle = @"30,000 Star Pack";
    }
    else if ([productIdentifier isEqualToString:@"pinkstars"]) {
        [[UpgradeManager sharedInstance] setUpgradeIndex:11 purchased:true equipped:true];
        purchaseTitle = @"Pink Star Upgrade";
        
    }
    else if ([productIdentifier isEqualToString:@"doublestars"]) {
        [[UpgradeManager sharedInstance] setUpgradeIndex:3 purchased:true equipped:true];
        purchaseTitle = @"Double Star Multiplier";
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations!" message:[NSString stringWithFormat:@"Thank you for purchasing the %@!",purchaseTitle] delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles: nil, nil];
    [alert show];
}

- (void)productPurchaseFailed:(SKPaymentTransaction *)transaction {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    if (transaction.error.code != SKErrorPaymentCancelled) {
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Transaction Error"
                                                         message:transaction.error.localizedDescription
                                                        delegate:nil
                                               cancelButtonTitle:nil
                                               otherButtonTitles:@"OK", nil] autorelease];
        
        [alert show];
    }
    
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"completeTransaction...");
    
    [self recordTransaction: transaction];
    [self provideContent: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    
    NSLog(@"restoreTransaction...");
    
    [self recordTransaction: transaction];
    [self provideContent: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction code: %d message: %@", transaction.error.code, transaction.error.localizedDescription);
    }
    
    [self productPurchaseFailed:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    }
}



- (void)buyProductIdentifier:(NSString *)productIdentifier {
    
    NSLog(@"Buying %@...", productIdentifier);
    
    SKPayment *payment = [SKPayment paymentWithProductIdentifier:productIdentifier];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
    
}

- (void)dealloc
{
    [_productIdentifiers release];
    _productIdentifiers = nil;
    [_products release];
    _products = nil;
    [_purchasedProducts release];
    _purchasedProducts = nil;
    [_request release];
    _request = nil;
    [super dealloc];
}

@end
