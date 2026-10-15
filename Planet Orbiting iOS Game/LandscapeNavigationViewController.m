#import "LandscapeNavigationViewController.h"
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
    CGRect area = UIEdgeInsetsInsetRect(self.view.bounds, self.view.safeAreaInsets);
    CGFloat scale = MIN(area.size.width / 568.0, area.size.height / 320.0);
    UIView *canvas = self.gameNavigation.view;
    canvas.transform = CGAffineTransformIdentity;
    canvas.bounds = CGRectMake(0,0,568,320);
    canvas.center = CGPointMake(CGRectGetMidX(area),CGRectGetMidY(area));
    canvas.transform = CGAffineTransformMakeScale(scale,scale);
}
- (void)viewSafeAreaInsetsDidChange { [super viewSafeAreaInsetsDidChange]; [self.view setNeedsLayout]; }
- (UIInterfaceOrientationMask)supportedInterfaceOrientations { return UIInterfaceOrientationMaskLandscape; }
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
- (BOOL)shouldAutorotate { return YES; }
- (BOOL)prefersStatusBarHidden { return YES; }
@end
