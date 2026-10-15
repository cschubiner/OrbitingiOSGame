//
//  AppDelegate.m
//  Star Dash
//
//  Created by Clayton Schubiner on 8/13/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "StarStream-Swift.h"
#import "DataStorage.h"
#import "GameplayLayer.h"
#import "DataStorage.h"
#import "PlayerStats.h"
#import "DeviceDetection.h"
#import "LandscapeNavigationViewController.h"
#import "SSMapSession.h"

@implementation AppDelegate

@synthesize window=window_, navController=navController_, director=director_;

-(bool)getShouldPlayMenuMusic {
    return shouldPlayMenuMusic;
}

-(void)setShouldPlayMenuMusic:(bool)a_shouldPlay {
    shouldPlayMenuMusic = a_shouldPlay;
}

-(void)setdidGetToMainMenu:(bool)didGet{
    didGetToMainMenu = didGet;
}
-(bool)getdidGetToMainMenu{
    return didGetToMainMenu;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{ return YES; }

- (void)connectGameScene:(UIWindowScene *)scene
{
    if (window_) { window_.windowScene = scene; [window_ makeKeyAndVisible]; return; }
    didGetToMainMenu = false;
    [self setdidGetToMainMenu:false];
    shouldPlayMenuMusic = true;
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithWindowScene:scene];
    
    //NSLog([NSString stringWithFormat:@"Kamcord version: %@",(void)0;]); // we're on 1.0.1 3/25/2013
   	// CCGLView creation
	// viewWithFrame: size of the OpenGL view. For full screen use [_window bounds]
	//  - Possible values: any CGRect
	// pixelFormat: Format of the render buffer. Use RGBA8 for better color precision (eg: gradients). But it takes more memory and it is slower
	//	- Possible values: kEAGLColorFormatRGBA8, kEAGLColorFormatRGB565
	// depthFormat: Use stencil if you plan to use CCClippingNode. Use Depth if you plan to use 3D effects, like CCCamera or CCNode#vertexZ
	//  - Possible values: 0, GL_DEPTH_COMPONENT24_OES, GL_DEPTH24_STENCIL8_OES
	// sharegroup: OpenGL sharegroup. Useful if you want to share the same OpenGL context between different threads
	//  - Possible values: nil, or any valid EAGLSharegroup group
	// multiSampling: Whether or not to enable multisampling
	//  - Possible values: YES, NO
	// numberOfSamples: Only valid if multisampling is enabled
	//  - Possible values: 0 to glGetIntegerv(GL_MAX_SAMPLES_APPLE)
    CCGLView *glView = [CCGLView viewWithFrame:CGRectMake(0, 0, 568, 320)
        pixelFormat:kEAGLColorFormatRGBA8 depthFormat:0 preserveBackbuffer:NO
        sharegroup:nil multiSampling:NO numberOfSamples:0];

	director_ = (CCDirectorIOS*) [CCDirector sharedDirector];
    
	director_.wantsFullScreenLayout = YES;
    
	// Display FSP and SPF
	[director_ setDisplayStats:NO];
    
	// set FPS at 60
	[director_ setAnimationInterval:1.0/60.0f];
    
	// attach the openglView to the director
	[director_ setView:glView];
    
	// for rotation and other messages
	[director_ setDelegate:self];
    
	// 2D projection
	[director_ setProjection:kCCDirectorProjection2D];
    //	[director setProjection:kCCDirectorProjection3D];
    
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
    //if ([DeviceDetection detectDevice]!=MODEL_IPHONE_4) //uncomment this line to disable retina on iphone 4
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
    
    
    
    if ([DeviceDetection detectDevice]==MODEL_IPHONE_4){
     //   [[iRate sharedInstance]setPromptAtLaunch:NO];
          [[iRate sharedInstance]setEventCount:2*[[iRate sharedInstance]eventCount]];
          [[iRate sharedInstance]setDaysUntilPrompt:2*[[iRate sharedInstance]daysUntilPrompt]];
    }
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
    
    if ([DeviceDetection detectDevice]!=MODEL_IPHONE_4)
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    else [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB5A1];
    
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:YES];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-hd"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-hd"];	// Default on iPad RetinaDisplay is "-ipadhd"
    
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    [DataStorage fetchData];
    [[StarStore shared] start];
    
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	//[director_ pushScene: [MainMenuLayer scene]];
    
	
	// Create a Navigation Controller with the Director
	navController_ = [[LandscapeNavigationViewController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
    
	
	// set the Navigation Controller as the root view controller
    //	[window_ addSubview:navController_.view];	// Generates flicker.
//	[window_ setRootViewController:[LandscapeNavigationViewController hostForNavigationController:navController_]];
    
    (void)0;
    
    
    (void)0;
    /*    if ([DeviceDetection detectDevice]==MODEL_IPHONE_4)
     {
     (void)0;
     
     
     }*/
    //   (void)0; //leave this disabled!!

    
    (void)0;
    

    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0){
        [window_ setRootViewController:[LandscapeNavigationViewController hostForNavigationController:navController_]];
    }
    else{
        [window_ addSubview:navController_.view];
    }
	// make main window visible
	[window_ makeKeyAndVisible];
	
}

-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notif
{
    if (notif != nil){
    if ([notif.userInfo objectForKey:@"Kamcord"] != nil)
    {
        (void)0;
    }
    }
}
-(void)directorDidReshapeProjection:(CCDirector *)director{
    if (director.runningScene == nil){
        // and add the scene to the stack. The director will run it when it automatically when the view is displayed.
#if COCOS2D_DEBUG
        if ([NSUserDefaults.standardUserDefaults boolForKey:@"SSProfileGameplay"]) {
            uint32_t seed=(uint32_t)[NSUserDefaults.standardUserDefaults integerForKey:@"SSMapSeed"];
            if (seed) [SSMapSession.shared selectMap:[SSMapSession generateMapWithSeed:seed]];
            [director_ runWithScene:[GameplayLayer scene]];
        } else
#endif
        [director_ runWithScene: [MainMenuLayer scene]];
    }
}

/*
 My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void HandleExceptions(NSException *exception) {
    //NSLog(@"This is where we save the application data during a exception");
    (void)0;
    // Save application data on crash
    [DataStorage storeData];
}

/*
 My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void SignalHandler(int sig) {
    //NSLog(@"This is where we save the application data during a signal");
    // Save application data on crash
    [DataStorage storeData];
}


-(NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window{
    //return (NSUInteger)[application supportedInterfaceOrientationsForWindow:window] | (1<<UIInterfaceOrientationPortrait);
    
   // if ([DeviceDetection detectDevice] == MODEL_IPHONE_4)
    return UIInterfaceOrientationMaskLandscape;
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}
/*
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskLandscape;
}*/

-(UIViewController*)getViewController{
    return navController_;
}



-(int)getGalaxyCounter {
    return galaxyCounter;
}

-(bool)getIsRetinaDisplay {
    return isRetinaDisplay;
}

-(bool)getIsInTutorialMode{
    @try {
        int numPlays = [[PlayerStats sharedInstance] getPlays];
        return !(([self getHighestScore]>9000 && numPlays > 1) || (numPlays>5));
    }
    @catch (NSException *exception) { }
    
    return false;
}


-(void)setIsInTutorialMode:(bool)mode {
   // isInTutorialMode=mode;
}


-(void)setGalaxyCounter:(int)count {
    galaxyCounter = count;
}


-(bool)getWasJustBackgrounded {
    return wasJustBackgrounded;
}

-(void)setWasJustBackgrounded:(bool)isItBackgrounded{
    wasJustBackgrounded = isItBackgrounded;
}

-(void)setChosenLevelNumber:(int)num {
    chosenLevelNumber = num;
}

-(int)getChosenLevelNumber {
    return chosenLevelNumber;
}

// getting a call, pause the game
-(void) applicationWillResignActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ pause];
    
     (void)0;
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
        //(void)0;09
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
    
   wasJustBackgrounded = true;
   [DataStorage storeData];
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    [[StarStore shared] refreshOwnedProducts];
	if( [navController_ visibleViewController] == director_ )
		[director_ startAnimation];
}

-(bool)getShouldDisplayPredPoints {
    @try {
        int numPlays = [[PlayerStats sharedInstance] getPlays];
        return !(([self getHighestScore]>40000 && numPlays > 3) || (numPlays>10));
    }
    @catch (NSException *exception) { }
    
    return false;
}

- (int)getHighestScore {
    @try {
        NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
        int highestScore = 0;
        for (int i = 0 ; i < highScores.count ; i++) {
            NSNumber * highscoreObject = [highScores objectAtIndex:i];
            int score = [highscoreObject intValue];
            if (score>highestScore)
                highestScore=score;
        }
        return highestScore;
    }
    @catch (NSException *exception) {
        return 0;
    }
}

- (NSMutableDictionary *)getDictionaryOfFlurryParameters
{
    
    NSMutableDictionary *parameterDict = [[NSMutableDictionary alloc]init];
    @try {
        NSMutableArray *highScores = [[PlayerStats sharedInstance] getScores];
        NSMutableDictionary * keyValuePairs = [[PlayerStats sharedInstance] getKeyValuePairs];
        for (int i = 0 ; i < highScores.count ; i++) {
            NSNumber * highscoreObject = [highScores objectAtIndex:i];
            NSString *scoreInt = [NSString stringWithFormat:@"%d", [highscoreObject intValue]];
            NSString *scoreName = [keyValuePairs valueForKey:scoreInt ];
            if (!scoreName)
                [parameterDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:highscoreObject,scoreName, nil]];
        }
        [parameterDict addEntriesFromDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
                                                 [NSNumber numberWithInt:[[UserWallet sharedInstance] getBalance]],@"Coin Balance",
                                                 [NSNumber numberWithInt:[[PlayerStats sharedInstance] getPlays]],@"Number of total plays",
                                                 //[[PlayerStats sharedInstance] recentName],@"Player Name",
                                                 nil]];

    }
    @catch (NSException *exception) {
        
    }
   
    return parameterDict;
}

// application will be killed
- (void)applicationWillTerminate:(UIApplication *)application
{
    (void)0;
    	[DataStorage storeData];
	CC_DIRECTOR_END();
}

// purge memory
- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
	[[CCDirector sharedDirector] purgeCachedData];
}

// next delta time will be zero
-(void) applicationSignificantTimeChange:(UIApplication *)application
{
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}


bool isIOSVersionGreaterThan6(){
    // Obtain iOS version
    @try {
        unsigned int OSVersion_ = 0;
        NSString *OSVer = [[UIDevice currentDevice] systemVersion];
        NSArray *arr = [OSVer componentsSeparatedByString:@"."];
        int idx = 0x01000000;
        for( NSString *str in arr ) {
            int value = [str intValue];
            OSVersion_ += value * idx;
            idx = idx >> 8;
        }
      //  CCLOG(@"VERSION: OS version: %@ (0x%08x)", OSVer, OSVersion_);
        
        return OSVersion_ >= kCCiOSVersion_6_0_0;
    }
    @catch (NSException *exception) {
        return false;
    }
    return false;
}


+ (void)initialize
{
    // StoreKit owns review prompting; never ask for a particular rating.
    [iRate sharedInstance].promptAtLaunch = NO;
}

-(void)iRateUserDidAttemptToRateApp {
    (void)0;
}

-(void)iRateUserDidDeclineToRateApp {
    (void)0;
}

-(void)iRateUserDidRequestReminderToRateApp {
    (void)0;
}


@end


@interface StarStreamSceneDelegate : NSObject <UIWindowSceneDelegate>
@property(nonatomic,strong) UIWindow *window;
@end
@implementation StarStreamSceneDelegate
- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)options {
    AppDelegate *app = (AppDelegate *)UIApplication.sharedApplication.delegate;
    [app connectGameScene:(UIWindowScene *)scene];
    self.window = app.window;
}
- (void)sceneWillResignActive:(UIScene *)scene { [(AppDelegate *)UIApplication.sharedApplication.delegate applicationWillResignActive:UIApplication.sharedApplication]; }
- (void)sceneDidBecomeActive:(UIScene *)scene { [(AppDelegate *)UIApplication.sharedApplication.delegate applicationDidBecomeActive:UIApplication.sharedApplication]; }
- (void)sceneDidEnterBackground:(UIScene *)scene { [(AppDelegate *)UIApplication.sharedApplication.delegate applicationDidEnterBackground:UIApplication.sharedApplication]; }
- (void)sceneWillEnterForeground:(UIScene *)scene { [(AppDelegate *)UIApplication.sharedApplication.delegate applicationWillEnterForeground:UIApplication.sharedApplication]; }
@end
