/*
 *
 * Kamcord macros
 *
 */

#ifndef KAMCORD_MACROS_H
#define KAMCORD_MACROS_H

// Logging
#if KCDEBUG
#define NLog(fmt, ...) printf("%s\n", [[NSString stringWithFormat:@"%s:%d %@", __PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:fmt, ##__VA_ARGS__]] UTF8String])
#define KLog(fmt, ...) printf(fmt, ##__VA_ARGS__)
#else
#define NLog(...)
#define KLog(...)
#endif

// HTML Prefix
#if KCDEBUG
#define KC_PREFIX_HTML @"http://www.kamcord.com/" // Change this to local ipv4 for testing. @"http://192.168.1.113:5000/"
#else
#define KC_PREFIX_HTML @"http://www.kamcord.com/"
#endif

// Tracking
#if KCDEBUG
#define trackAllAnalytics YES
#else
#define trackAllAnalytics NO
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
