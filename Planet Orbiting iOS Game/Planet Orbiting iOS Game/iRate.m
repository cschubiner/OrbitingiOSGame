// StoreKit replacement. The original iRate network lookups and custom rating prompts are retired.
#import "iRate.h"
#import <StoreKit/StoreKit.h>
NSUInteger const iRateAppStoreGameGenreID = 6014;
NSString *const iRateErrorDomain = @"StarStreamReviews";
@implementation iRate
+ (iRate *)sharedInstance {
    static iRate *review; static dispatch_once_t once;
    dispatch_once(&once, ^{
        review = [iRate new];
        review.usesCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"StarStreamLaunchCount"] + 1;
        [[NSUserDefaults standardUserDefaults] setInteger:review.usesCount forKey:@"StarStreamLaunchCount"];
    });
    return review;
}
- (NSUInteger)eventCount { return [[NSUserDefaults standardUserDefaults] integerForKey:@"StarStreamReviewEvents"]; }
- (void)setEventCount:(NSUInteger)count { [[NSUserDefaults standardUserDefaults] setInteger:count forKey:@"StarStreamReviewEvents"]; }
- (void)logEvent:(BOOL)deferPrompt { self.eventCount += 1; }
- (BOOL)shouldPromptForRating { return NO; }
- (void)promptIfNetworkAvailable { }
- (void)promptForRating {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:UIWindowScene.class] && scene.activationState == UISceneActivationStateForegroundActive) {
            [SKStoreReviewController requestReviewInScene:(UIWindowScene *)scene];
            break;
        }
    }
}
- (void)openRatingsPageInAppStore { [self promptForRating]; }
- (float)usesPerWeek { return 0; }
- (BOOL)declinedAnyVersion { return NO; }
- (BOOL)ratedAnyVersion { return NO; }
@end
