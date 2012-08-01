//
//  AppDelegate.m
//  Planet Orbiting iOS Game
//
//  Created by Clay Schubiner on 6/22/12.
//  Copyright Clayton Schubiner 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "GameConfig.h"
#import "MainMenuLayer.h"
#import "RootViewController.h"
#import "GameplayLayer.h"
#import "CCBReader.h"
#import "DataStorage.h"

@implementation AppDelegate

@synthesize window;

-(void)setIsInTutorialMode:(bool)mode{
    isInTutorialMode = mode;
}

-(bool)getIsInTutorialMode{
    return isInTutorialMode;
}

- (void) removeStartupFlicker
{
	//
	// THIS CODE REMOVES THE STARTUP FLICKER
	//
	// Uncomment the following code if your Application only supports landscape mode
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController

//	CC_ENABLE_DEFAULT_GL_STATES();
//	CCDirector *director = [CCDirector sharedDirector];
//	CGSize size = [director winSize];
//	CCSprite *sprite = [CCSprite spriteWithFile:@"Default.png"];
//	sprite.position = ccp(size.width/2, size.height/2);
//	sprite.rotation = -90;
//	[sprite visit];
//	[[director openGLView] swapBuffers];
//	CC_ENABLE_DEFAULT_GL_STATES();
	
#endif // GAME_AUTOROTATION == kGameAutorotationUIViewController	
}

-(UIViewController*)getViewController{
    return viewController;
}

-(bool)getWasJustBackgrounded {
    return wasJustBackgrounded;
}

-(void)setWasJustBackgrounded:(bool)isItBackgrounded{
    wasJustBackgrounded = isItBackgrounded;
}
- (void) applicationDidFinishLaunching:(UIApplication*)application
{   
    // installs HandleExceptions as the Uncaught Exception Handler
    NSSetUncaughtExceptionHandler(&HandleExceptions);
    // create the signal action structure 
    struct sigaction newSignalAction;
    // initialize the signal action structure
    memset(&newSignalAction, 0, sizeof(newSignalAction));
    // set SignalHandler as the handler in the signal action structure
    newSignalAction.sa_handler = &SignalHandler;
    // set SignalHandler as the handlers for SIGABRT, SIGILL and SIGBUS
    sigaction(SIGABRT, &newSignalAction, NULL);
    sigaction(SIGILL, &newSignalAction, NULL);
    sigaction(SIGBUS, &newSignalAction, NULL);
    // Call takeOff after install your own unhandled exception and signal handlers
    [TestFlight takeOff:@"d617a481887a5d2cf7db0f22b735c89f_MTExODYwMjAxMi0wNy0xOCAxOToxNToyNC43NzQ3NjA"];

    [Flurry startSession:@"96GKYS7HQZHNKZJJN2CZ"];
    
    [Kamcord setDeveloperKey:@"d05f73399ff3c1755bd97ec94cb5fdda"
             developerSecret:@"prcU7MltdajQ1YVTSeFDtPtywe2zABOmzzpSB5pGP79"
                     appName:@"Star Dash"];
    
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Try to use CADisplayLink director
	// if it fails (SDK < 3.1) use the default director
	if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )
		[CCDirector setDirectorType:kCCDirectorTypeDefault];
	
	
	CCDirector *director = [CCDirector sharedDirector];
	
	// Init the View Controller
	viewController = [[RootViewController alloc] initWithNibName:nil bundle:nil];
	viewController.wantsFullScreenLayout = YES;
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	//
	KCGLView *glView = [KCGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565	// kEAGLColorFormatRGBA8
								   depthFormat:0						// GL_DEPTH_COMPONENT16_OES
						];
    
    window.rootViewController = [[KCViewController alloc]initWithNibName:nil bundle:nil];
    window.rootViewController.view = glView;
    
    [Kamcord setParentViewController:window.rootViewController];
	
	// attach the openglView to the director
	[Kamcord setOpenGLView:glView];
	
    isRetinaDisplay = true;
//	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	if( ! [director enableRetinaDisplay:YES] ) {
		CCLOG(@"Retina Display Not supported");
        isRetinaDisplay = false;
	}
    
	//
	// VERY IMPORTANT:
	// If the rotation is going to be controlled by a UIViewController
	// then the device orientation should be "Portrait".
	//
	// IMPORTANT:
	// By default, this template only supports Landscape orientations.
	// Edit the RootViewController.m file to edit the supported orientations.
	//
#if GAME_AUTOROTATION == kGameAutorotationUIViewController
	[Kamcord setDeviceOrientation:kCCDeviceOrientationPortrait];
    
#else
	[Kamcord setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
#endif
    [Kamcord setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
   // [director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
  // [[UIApplication sharedApplication]setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];

	
	[director setAnimationInterval:1.0/60];
	[director setDisplayFPS:NO];
    
    [CCTexture2D PVRImagesHavePremultipliedAlpha:YES];

	
	// make the OpenGLView a child of the view controller
//	[viewController setView:glView];
	
	// make the View Controller a child of the main window
	//[window addSubview: viewController.view];
	
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];

	
	// Removes the startup flicker
	[self removeStartupFlicker];
    
    // Load the scene from the example.ccb file
 //   CCScene* scene = [CCBReader sceneWithNodeGraphFromFile:@"example.ccb"];
    
    // Run the loaded scene
	//[[CCDirector sharedDirector] runWithScene: scene];

	
	// Run the intro Scene
	//[[CCDirector sharedDirector] runWithScene: [GameplayLayer scene]];
    
    [DataStorage fetchData];
    
    [[CCDirector sharedDirector] runWithScene: [MainMenuLayer scene]];
    
}

/*
 My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void HandleExceptions(NSException *exception) {
    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
    NSLog(@"This is where we save the application data during a exception");
    // Save application data on crash (we're not doing this yet)
}
/*
 My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void SignalHandler(int sig) {
    NSLog(@"This is where we save the application data during a signal");
    // Save application data on crash
}

-(bool)getIsRetinaDisplay {
    return isRetinaDisplay;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
    wasJustBackgrounded = true;
    [DataStorage storeData];
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[DataStorage storeData];
    CCDirector *director = [CCDirector sharedDirector];
	[[director openGLView] removeFromSuperview];
	[viewController release];
	[window release];
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
