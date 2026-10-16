#import "cocos2d.h"

// One uniform point scale preserves the artwork; the world grows on the other axis.
static inline CGFloat SSViewportScale(CGSize screen) {
    return MIN(screen.width / 568.0, screen.height / 320.0);
}
static inline CGSize SSViewportSize(CGSize screen) {
    CGFloat scale = SSViewportScale(screen);
    return scale > 0 ? CGSizeMake(screen.width / scale, screen.height / scale) : CGSizeMake(568, 320);
}
// An accumulator that starts at zero sits exactly on a tick boundary at 60 Hz, so
// microsecond timestamp noise alternates 0 and 2 steps per frame (visible stutter).
// Starting half a tick in keeps each 60-Hz frame at exactly one step.
static const double SSPhysicsPhase = 0.5 / 60.0;
// Display-link intervals land on a 120-Hz grid plus noise and slow refresh drift.
// Snapping near-grid intervals keeps the accumulator phase from drifting into a
// boundary; the sub-2 ms adjustment is imperceptible, and real hitches still count.
static inline double SSSnapFrameTime(double elapsed) {
    double frames = round(elapsed * 120.0);
    return frames >= 1 && fabs(elapsed - frames / 120.0) < .002 ? frames / 120.0 : elapsed;
}
static inline NSUInteger SSPhysicsSteps(double elapsed, double *remainder) {
    *remainder += fmax(0, fmin(elapsed, .1));
    NSUInteger ticks = (NSUInteger)floor((*remainder + 1e-8) * 60.0);
    *remainder -= ticks / 60.0;
    return ticks;
}
// Fraction of the next fixed step already accumulated: 0 draws the previous step's state,
// approaching 1 draws the latest. Used to draw between steps when their count varies.
static inline double SSInterpolationAlpha(double remainder) {
    return fmin(1, fmax(0, remainder * 60.0));
}
// Shortest-path angle blend in degrees; ship headings jump between -180 and 180.
static inline float SSLerpAngle(float from, float to, double t) {
    return from + remainderf(to - from, 360) * (float)t;
}
FOUNDATION_EXPORT NSString *const SSViewportDidChange;
FOUNDATION_EXPORT CGRect SSSafeViewport(void);
FOUNDATION_EXPORT CGPoint SSMenuOrigin(void);
FOUNDATION_EXPORT CGFloat SSMenuScale(void);
FOUNDATION_EXPORT void SSFillViewport(CCNode *node);

// Authored menu controls retain their proportions while the space background fills the display.
@interface SSMenuLayer : CCLayer
- (void)layoutViewport;
- (CGFloat)menuScale;
@end

@interface SSClippedLayer : CCLayer
@property(nonatomic) CGRect clippingRect;
@end
