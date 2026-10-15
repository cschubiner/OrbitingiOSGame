#import "cocos2d.h"

// One uniform point scale preserves the artwork; the world grows on the other axis.
static inline CGFloat SSViewportScale(CGSize screen) {
    return MIN(screen.width / 568.0, screen.height / 320.0);
}
static inline CGSize SSViewportSize(CGSize screen) {
    CGFloat scale = SSViewportScale(screen);
    return scale > 0 ? CGSizeMake(screen.width / scale, screen.height / scale) : CGSizeMake(568, 320);
}
static inline NSUInteger SSPhysicsSteps(double elapsed, double *remainder) {
    *remainder += fmax(0, fmin(elapsed, .1));
    NSUInteger ticks = (NSUInteger)floor((*remainder + 1e-8) * 60.0);
    *remainder -= ticks / 60.0;
    return ticks;
}
FOUNDATION_EXPORT NSString *const SSViewportDidChange;
FOUNDATION_EXPORT CGRect SSSafeViewport(void);
FOUNDATION_EXPORT CGPoint SSMenuOrigin(void);
FOUNDATION_EXPORT void SSFillViewport(CCNode *node);

// Authored menu controls retain their proportions while the space background fills the display.
@interface SSMenuLayer : CCLayer
- (void)layoutViewport;
@end

@interface SSClippedLayer : CCLayer
@property(nonatomic) CGRect clippingRect;
@end
