//
//  KamcordMacros.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 5/21/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#ifndef KAMCORD_MACROS_H
#define KAMCORD_MACROS_H

#define KAMCORD_CUSTOM_ENGINE 1

// Logging
#if KCDEBUG

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

// iOS Versioning
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#endif
