#import "LandscapeNavigationViewController.h"
#import "Planet Orbiting iOS Game/StarStreamLayout.h"
NSString *const SSViewportDidChange = @"SSViewportDidChange";
static UIEdgeInsets ssLogicalInsets;
CGRect SSSafeViewport(void) {
    CGSize size = CCDirector.sharedDirector.winSize;
    return CGRectMake(ssLogicalInsets.left, ssLogicalInsets.bottom,
                      size.width - ssLogicalInsets.left - ssLogicalInsets.right,
                      size.height - ssLogicalInsets.top - ssLogicalInsets.bottom);
}
CGPoint SSMenuOrigin(void) {
    CGRect safe = SSSafeViewport();
    return ccp(CGRectGetMidX(safe) - 284, CGRectGetMidY(safe) - 160);
}
void SSFillViewport(CCNode *node) {
    CGSize size = CCDirector.sharedDirector.winSize;
    node.position = [node.parent convertToNodeSpace:ccp(size.width / 2, size.height / 2)];
    node.scaleX = size.width / node.contentSize.width;
    node.scaleY = size.height / node.contentSize.height;
}
@implementation SSMenuLayer {
    CCLayerColor *spaceBackground;
    CCParticleSystemQuad *spaceStars;
}
- (void)onEnter {
    [super onEnter];
    if (!spaceBackground) {
        spaceBackground = [CCLayerColor layerWithColor:ccc4(2, 3, 12, 255)];
        [self addChild:spaceBackground z:-100];
        for (CCNode *child in self.children) if ([child isKindOfClass:CCParticleSystemQuad.class]) { spaceStars=(CCParticleSystemQuad *)child; break; }
        if (!spaceStars) { spaceStars = [CCParticleSystemQuad particleWithFile:@"starParticleMenu.plist"]; [self addChild:spaceStars z:-99]; }
        spaceStars.totalParticles=160;
        spaceStars.emissionRate=16;
    }
    [self layoutViewport];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(layoutViewport) name:SSViewportDidChange object:nil];
}
- (void)layoutViewport {
    self.position = SSMenuOrigin();
    CGSize size = CCDirector.sharedDirector.winSize;
    spaceBackground.position = ccp(-self.position.x, -self.position.y);
    spaceBackground.contentSize = size;
    spaceStars.position = ccp(size.width / 2 - self.position.x, size.height / 2 - self.position.y);
    spaceStars.posVar = ccp(size.width / 2, size.height / 2);
}
- (void)onExit {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SSViewportDidChange object:nil];
    [super onExit];
}
@end
@implementation SSClippedLayer
- (void)visit {
    if (!self.visible) return;
    GLboolean clipped=glIsEnabled(GL_SCISSOR_TEST);
    GLint previous[4]; glGetIntegerv(GL_SCISSOR_BOX,previous);
    CGPoint a=[self convertToWorldSpace:self.clippingRect.origin];
    CGPoint b=[self convertToWorldSpace:ccp(CGRectGetMaxX(self.clippingRect),CGRectGetMaxY(self.clippingRect))];
    CGFloat scale=CC_CONTENT_SCALE_FACTOR();
    CGRect rect=CGRectMake(floor(a.x*scale),floor(a.y*scale),ceil((b.x-a.x)*scale),ceil((b.y-a.y)*scale));
    if (clipped) rect=CGRectIntersection(rect,CGRectMake(previous[0],previous[1],previous[2],previous[3]));
    if (CGRectIsNull(rect)) return;
    glEnable(GL_SCISSOR_TEST); glScissor(rect.origin.x,rect.origin.y,rect.size.width,rect.size.height);
    [super visit];
    glScissor(previous[0],previous[1],previous[2],previous[3]);
    if (!clipped) glDisable(GL_SCISSOR_TEST);
}
@end
@interface StarStreamHostController : UIViewController
@property(nonatomic,strong) UINavigationController *gameNavigation;
@end
@implementation StarStreamHostController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.015 green:0.02 blue:0.055 alpha:1];
    [self addChildViewController:self.gameNavigation];
    UIView *canvas = self.gameNavigation.view;
    canvas.autoresizingMask = UIViewAutoresizingNone;
    canvas.bounds = CGRectMake(0,0,568,320);
    canvas.clipsToBounds = YES;
    [self.view addSubview:canvas];
    [self.gameNavigation didMoveToParentViewController:self];
}
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGRect area = self.view.bounds;
    CGFloat scale = SSViewportScale(area.size);
    if (scale <= 0) return;
    CGSize logical = SSViewportSize(area.size);
    UIView *canvas = self.gameNavigation.view;
    canvas.transform = CGAffineTransformIdentity;
    canvas.bounds = (CGRect){CGPointZero, logical};
    canvas.center = CGPointMake(CGRectGetMidX(area),CGRectGetMidY(area));
    canvas.transform = CGAffineTransformMakeScale(scale,scale);
    UIEdgeInsets insets = self.view.safeAreaInsets;
    ssLogicalInsets = UIEdgeInsetsMake(insets.top / scale, insets.left / scale, insets.bottom / scale, insets.right / scale);
    [canvas setNeedsLayout];
    [canvas layoutIfNeeded];
    [CCDirector.sharedDirector.view setNeedsLayout];
    [CCDirector.sharedDirector.view layoutIfNeeded];
    [[NSNotificationCenter defaultCenter] postNotificationName:SSViewportDidChange object:nil];
}
- (void)viewSafeAreaInsetsDidChange { [super viewSafeAreaInsetsDidChange]; [self.view setNeedsLayout]; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation { return UIInterfaceOrientationLandscapeRight; }
- (BOOL)shouldAutorotate { return YES; }
- (BOOL)prefersStatusBarHidden { return YES; }
- (BOOL)prefersHomeIndicatorAutoHidden { return YES; }
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures { return UIRectEdgeAll; }
@end
@implementation LandscapeNavigationViewController
+ (UIViewController *)hostForNavigationController:(UINavigationController *)navigation {
    StarStreamHostController *host = [StarStreamHostController new];
    host.gameNavigation = navigation;
    return host;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation { return UIInterfaceOrientationLandscapeRight; }
- (BOOL)shouldAutorotate { return YES; }
- (BOOL)prefersStatusBarHidden { return YES; }
@end
