//
//  KamcordMacros.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 5/21/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#ifndef cocos2d_ios_KamcordMacros_h
#define cocos2d_ios_KamcordMacros_h

// Tell Kamcord which version we're using
#define PRE_IOS_6 1         // Comment out as necessary
#define COCOS2D_2_0 1       // Comment out as necessary
// #define COCOS2D_2_1 1    // Comment out as necessary

#define CC_DIRECTOR_INIT_KAMCORD()                                                              \
do	{																							\
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];					\
    if( ! [CCDirector setDirectorType:kCCDirectorTypeDisplayLink] )								\
        [CCDirector setDirectorType:kCCDirectorTypeNSTimer];									\
    CCDirector *__director = [CCDirector sharedDirector];										\
    [__director setDisplayFPS:NO];																\
    [__director setAnimationInterval:1.0/60];													\
    KCGLView *__glView = [KCGLView viewWithFrame:[window bounds]								\
                                     pixelFormat:kEAGLColorFormatRGB565							\
                                     depthFormat:0 /* GL_DEPTH_COMPONENT24_OES */				\
                              preserveBackbuffer:NO												\
                                      sharegroup:nil											\
                                   multiSampling:NO                                             \
                                numberOfSamples:0												\
                                                    ];                                          \
    window.rootViewController = [[KCViewController alloc] initWithNibName:nil bundle:nil];      \
    window.rootViewController.view = __glView;                                                  \
    [Kamcord setParentViewController:window.rootViewController];                                \
    [Kamcord setView:__glView];                                                           \
} while(0)


// Logging
#ifdef DEBUG

#define NLog(fmt, ...) printf("%s\n", [[NSString stringWithFormat:@"%s:%d %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:fmt, ##__VA_ARGS__]] UTF8String])

#else

#define NLog(...)

#endif


////////////////////////////////////////////////
// Macros that make it easier to port Kamcord
// to different engines.

// Orientation
#define KCDeviceOrientation UIInterfaceOrientation

#define KCDeviceOrientationPortrait UIInterfaceOrientationPortrait 
#define KCDeviceOrientationPortraitUpsideDown UIInterfaceOrientationPortraitUpsideDown
#define KCDeviceOrientationLandscapeLeft UIInterfaceOrientationLandscapeLeft
#define KCDeviceOrientationLandscapeRight UIInterfaceOrientationLandscapeRight

// OpenGL
#define KC_CONTENT_SCALE_FACTOR() CC_CONTENT_SCALE_FACTOR()

#endif

