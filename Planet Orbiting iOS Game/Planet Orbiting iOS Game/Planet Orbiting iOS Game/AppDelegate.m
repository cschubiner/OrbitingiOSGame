//
//  AppDelegate.m
//  Star Dash
//
//  Created by Clayton Schubiner on 8/13/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//

#import "cocos2d.h"

#import "AppDelegate.h"
#import "DataStorage.h"
#import "GameplayLayer.h"
#import "DataStorage.h"
#import "IntroLayer.h"
#import "PlayerStats.h"

@implementation AppDelegate

@synthesize window=window_, navController=navController_, director=director_;

-(bool)getShouldPlayMenuMusic {
    return shouldPlayMenuMusic;
}

-(void)setShouldPlayMenuMusic:(bool)a_shouldPlay {
    shouldPlayMenuMusic = a_shouldPlay;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
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
    //[TestFlight takeOff:@"d617a481887a5d2cf7db0f22b735c89f_MTExODYwMjAxMi0wNy0xOCAxOToxNToyNC43NzQ3NjA"];
    
    [Flurry startSession:@"96GKYS7HQZHNKZJJN2CZ"];
    [Flurry setUserID:[[UIDevice currentDevice] uniqueIdentifier]];

    //[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    
    //[[iRate sharedInstance]setDebug:YES];
    [[iRate sharedInstance]setAppStoreGenreID:iRateAppStoreGameGenreID];
    [[iRate sharedInstance]setMessage:[NSString stringWithFormat:@"If you enjoy playing %@, would you mind taking a moment to rate it? 5 Star ratings help us provide free updates. It'll only take a minute! :)",[[iRate sharedInstance]applicationName]]];
    [[iRate sharedInstance]setCancelButtonLabel:@"No Thanks"];
    NSLog(@"iRate: Number of events: %d Number of uses: %d",[[iRate sharedInstance]eventCount],[[iRate sharedInstance]usesCount]);
    
    shouldPlayMenuMusic = true;
    
	// Create the main window
	window_ = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
	// Create an CCGLView with a RGB565 color buffer, and a depth buffer of 0-bits
	KCGLView *glView = [KCGLView viewWithFrame:[window_ bounds]
									 pixelFormat:kEAGLColorFormatRGB565
									 depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */
							  preserveBackbuffer:NO
									  sharegroup:nil
								   multiSampling:NO
								 numberOfSamples:0];
    
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
	if( ! [director_ enableRetinaDisplay:YES] )
		CCLOG(@"Retina Display Not supported");
    
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
    
	// If the 1st suffix is not found and if fallback is enabled then fallback suffixes are going to searched. If none is found, it will try with the name without suffix.
	// On iPad HD  : "-ipadhd", "-ipad",  "-hd"
	// On iPad     : "-ipad", "-hd"
	// On iPhone HD: "-hd"
	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
	[sharedFileUtils setEnableFallbackSuffixes:NO];				// Default: NO. No fallback suffixes are going to be used
	[sharedFileUtils setiPhoneRetinaDisplaySuffix:@"-hd"];		// Default on iPhone RetinaDisplay is "-hd"
	[sharedFileUtils setiPadSuffix:@"-ipad"];					// Default on iPad is "ipad"
	[sharedFileUtils setiPadRetinaDisplaySuffix:@"-ipadhd"];	// Default on iPad RetinaDisplay is "-ipadhd"
    
	// Assume that PVR images have premultiplied alpha
	[CCTexture2D PVRImagesHavePremultipliedAlpha:YES];
    
    [DataStorage fetchData];
    
	// and add the scene to the stack. The director will run it when it automatically when the view is displayed.
	[director_ pushScene: [IntroLayer scene]];
    
	
	// Create a Navigation Controller with the Director
	navController_ = [[UINavigationController alloc] initWithRootViewController:director_];
	navController_.navigationBarHidden = YES;
    
	
	// set the Navigation Controller as the root view controller
    //	[window_ addSubview:navController_.view];	// Generates flicker.
	[window_ setRootViewController:navController_];
    
    [Kamcord setDeveloperKey:@"d05f73399ff3c1755bd97ec94cb5fdda"
             developerSecret:@"prcU7MltdajQ1YVTSeFDtPtywe2zABOmzzpSB5pGP79"
                     appName:@"Star Stream"];

	
	// make main window visible
	[window_ makeKeyAndVisible];
	
	return YES;
}

/*
 My Apps Custom uncaught exception catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void HandleExceptions(NSException *exception) {
    NSLog(@"This is where we save the application data during a exception");
    [Flurry logError:@"Game crashed" message:@"game crashed" exception:exception];
    // Save application data on crash
}

/*
 My Apps Custom signal catcher, we do special stuff here, and TestFlight takes care of the rest
 **/
void SignalHandler(int sig) {
    NSLog(@"This is where we save the application data during a signal");
    // Save application data on crash
}

// Supported orientations: Landscape. Customize it for your own needs
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

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
}

// call got rejected
-(void) applicationDidBecomeActive:(UIApplication *)application
{
	if( [navController_ visibleViewController] == director_ )
		[director_ resume];
}

-(void) applicationDidEnterBackground:(UIApplication*)application
{
        //[Flurry logEvent:@"Application Backgrounded" withParameters:[self getDictionaryOfFlurryParameters]];
	if( [navController_ visibleViewController] == director_ )
		[director_ stopAnimation];
    
   wasJustBackgrounded = true;
}

-(void) applicationWillEnterForeground:(UIApplication*)application
{
    [Flurry logEvent:@"Application entered foreground"];
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
    [Flurry logEvent:@"Application Terminated" withParameters:[self getDictionaryOfFlurryParameters]];
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

+ (void)initialize
{
    //configure iRate
    [iRate sharedInstance].daysUntilPrompt = 0;
    [iRate sharedInstance].usesUntilPrompt = 10;
    [iRate sharedInstance].eventsUntilPrompt = 17;
}

-(void)iRateUserDidAttemptToRateApp {
    [Flurry logEvent:@"iRate user did attempt to rate app" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[PlayerStats sharedInstance] getPlays]],@"Number of total plays", nil]];
}

-(void)iRateUserDidDeclineToRateApp {
    [Flurry logEvent:@"iRate user did decline to rate app" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[PlayerStats sharedInstance] getPlays]],@"Number of total plays", nil]];
}

-(void)iRateUserDidRequestReminderToRateApp {
    [Flurry logEvent:@"iRate user did request reminder to rate app" withParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:[[PlayerStats sharedInstance] getPlays]],@"Number of total plays", nil]];
}

@end
