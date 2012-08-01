//
//  KamcordMacros.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 5/21/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

// Tell Kamcord which version of which engine we're using
#define COCOS2D_1_0_1 1

#ifndef cocos2d_ios_KamcordMacros_h
#define cocos2d_ios_KamcordMacros_h

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
    [Kamcord setOpenGLView:__glView];                                                           \
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
#define KCDeviceOrientation ccDeviceOrientation

#define KCDeviceOrientationPortrait CCDeviceOrientationPortrait 
#define KCDeviceOrientationPortraitUpsideDown CCDeviceOrientationPortraitUpsideDown
#define KCDeviceOrientationLandscapeLeft CCDeviceOrientationLandscapeLeft
#define KCDeviceOrientationLandscapeRight CCDeviceOrientationLandscapeRight


// OpenGL
#define KC_CONTENT_SCALE_FACTOR() CC_CONTENT_SCALE_FACTOR()

#endif
