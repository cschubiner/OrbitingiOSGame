/*
 *
 * Kamcord Framework for recording and sharing gameplays on iOS.
 *
 */

#import <UIKit/UIKit.h>

/*
 * Core Kamcord video recording
 */
#import "KamcordMacros.h"
#import "Core/OpenGL/KamcordRecorder.h"
#import "Core/KamcordProtocols.h"
#import "Core/KCAnalytics.h"
#import "View/KCViewController.h"

@class KCVideo;

/*
 * Audio recording
 */
#if (COCOS2D || KAMCORD_CUSTOM_ENGINE)
#import <CoreAudio/CoreAudioTypes.h>
#endif

/*
 * Unity specific imports
 */
#if KCUNITY_VERSION >= 4100
#import "../Unity/GlesHelper_Kamcord.h"
#elif KCUNITY_VERSION
#import "../Unity/iPhone_GlesSupport_Kamcord.h"
#endif

#ifndef KCUNITY_VERSION
/*
 * Audio overlay
 */
@protocol KCAudioListener;

#import "Core/Audio/KCAudio.h"
#import "Core/Audio/KCSound.h"
#endif

/*
 * Cocos2D specific imports
 */
#if COCOS2D
#import "../KCGLView.h"
#import "CCDirectorIOS.h"
#import "Core/Audio/KamcordAudioEngine/KamcordAudioEngine.h"
#endif

/*
 * Current verion is 1.1 (3/17/2013)
 */
FOUNDATION_EXPORT NSString * const KamcordVersion;

/*
 * Devices that can be automatically blacklisted.
 */
static NSString * const DEVICE_TYPE_IPOD_4G     = @"DEVICE_TYPE_IPOD_4G";
static NSString * const DEVICE_TYPE_IPOD_5G     = @"DEVICE_TYPE_IPOD_5G";
static NSString * const DEVICE_TYPE_IPAD_1      = @"DEVICE_TYPE_IPAD_1";
static NSString * const DEVICE_TYPE_IPAD_2      = @"DEVICE_TYPE_IPAD_2";
static NSString * const DEVICE_TYPE_IPAD_MINI   = @"DEVICE_TYPE_IPAD_MINI";
static NSString * const DEVICE_TYPE_IPHONE_3GS  = @"DEVICE_TYPE_IPHONE_3GS";
static NSString * const DEVICE_TYPE_IPHONE_4    = @"DEVICE_TYPE_IPHONE_4";

/*
 * Keys for skinning the Kamcord UI. For more information, please refer to here:
 * https://github.com/kamcord/cocos2d-2.0-kamcord/wiki/Using-the-Kamcord-API%3A-Skinning-the-Kamcord-UI
 */
typedef enum
{
    KC_NAV_BAR = 0,
    KC_NAV_BAR_TEXT_COLOR,
    KC_BACKGROUND,
    KC_BACKGROUND_TALL,
    KC_TOOLBAR_DONE_BUTTON,
    KC_TOOLBAR_DONE_BUTTON_TEXT_COLOR,
    KC_TABLE_CELL_BACKGROUND_COLOR,
    KC_TABLE_CELL_TEXT_COLOR,
    KC_TOOLBAR_SHARE_BUTTON,
    KC_TOOLBAR_SHARE_BUTTON_TEXT_COLOR,
    KC_MAIN_SHARE_BUTTON,
    KC_MAIN_SHARE_BUTTON_TEXT_COLOR,
    KC_SHARE_TITLE_TEXT_COLOR,
    KC_SHARE_GRID_LABEL_COLOR,
    KC_TABLE_CELL_SPLIT_COLOR,
    KC_POWERED_BY_KAMCORD_COLOR,
    KC_REFRESH_ARROW,
    KC_REFRESH_TEXT_SPINNER_COLOR,
    KC_PROGRESS_VIEW_BACKGROUND,
    KC_WATCH_VIEW_CELL_BACKGROUND,
    KC_WATCH_VIEW_VIDEO_TITLE_COLOR,
    KC_WATCH_VIEW_VIDEO_TIME_COLOR,
    KC_SETTINGS_SIGN_IN_BUTTON,
    KC_SETTINGS_SIGN_IN_BUTTON_TEXT_COLOR,
    KC_SETTINGS_SIGN_OUT_BUTTON,
    KC_SETTINGS_SIGN_OUT_BUTTON_TEXT_COLOR,
    KC_WATCH_VIEW_TOP_BAR_BACKGROUND,
    KC_WATCH_VIEW_TOP_BUTTON_SELECTED,
    KC_WATCH_VIEW_TOP_BUTTON_DESELECTED,
    KC_WATCH_VIEW_TOGGLE_BUTTON_TEXT_COLOR,
    KC_NOTIFICATION_CALL_TO_ACTION_BUTTON_TEXT,
} KC_UI_COMPONENT;



/*
 * The Kamcord API
 */
@interface Kamcord : NSObject

// -------------------------------------------------------------------------
// Kamcord Setup
// -------------------------------------------------------------------------

/*
 * The current version of the Kamcord SDK
 */
+ (NSString *)kamcordSDKVersion;

/*
 * You can gracefully turn off Kamcord on the devices listed at the top
 * of this header file by using the following method call.
 * If you use this method, make sure it's the first Kamcord call you make.
 * (even before nstantiating KCGLView).
 *
 * Pass in an NSArray consisting of any of the devices listed above
 * (i.e. DEVICE_TYPE_IPOD, etc.).
 */
+ (void)setDeviceBlacklist:(NSArray *)blacklist;

/*
 * Returns YES if and only if the device is running iOS 5+ and
 * it has not been blacklisted via setDeviceBlacklist.
 */
+ (BOOL)isEnabled;

+ (void)disable;

/*
 * Pass in your developer key, secret, and application name
 */
+ (void)setDeveloperKey:(NSString *)key
        developerSecret:(NSString *)secret
                appName:(NSString *)name;
+ (NSString *)developerKey;
+ (NSString *)developerSecret;
+ (NSString *)appName;

/*
 * You must set the parentViewController that will later present
 * the Kamcord when you call [Kamcord showView].
 */
+ (void)setParentViewController:(UIViewController *)viewController;
+ (UIViewController *)parentViewController;


/*
 * Returns the current device orientation.
 */
+ (void)setDeviceOrientation:(KCDeviceOrientation)deviceOrientation;
+ (KCDeviceOrientation)deviceOrientation;

/*
 * Turns on and off Kamcord notifications.
 *
 * Today, we schedule 4 "Gameplay of the Week" notifications for each of the
 * next 4 weeks.
 */
+ (void)setNotificationsEnabled:(BOOL)enabled;
+ (BOOL)notificationsEnabled;

/*
 * Pass Kamcord the local notifications from didReceiveLocalNotification: and
 * didFinishLaunchingWithOptions: if the notification data has the "Kamcord" key.
 * You can also pass us all your local notifications and we will handle the ones
 * relevant to Kamcord and ignore the rest.
 */
+ (void)handleKamcordNotification:(UILocalNotification *)notification;

#if COCOS2D

/*
 * Set the KCGLView so Kamcord can record the rendered frames.
 * setView and setOpenGLView do the same thing internally and are only here for legacy reasons.
 */

+ (void)setView:(KCGLView *)glView;
+ (void)setOpenGLView:(KCGLView *)glView;
+ (KCGLView *)openGLView;

#endif

// -------------------------------------------------------------------------
// Video Recording
// -------------------------------------------------------------------------

/*
 * Basic API to record video.
 */
+ (BOOL)startRecording;
+ (BOOL)stopRecording;
+ (BOOL)resume;
+ (BOOL)pause;

/*
 * Is a video currently being recorded?
 */
+ (BOOL)isRecording;

/*
 * Displays the Kamcord view and watch view inside the previously set parentViewController;
 */
+ (void)showView;
+ (void)showViewInViewController:(UIViewController *)parentViewController;
+ (void)showWatchView;
+ (void)showWatchViewInViewController:(UIViewController *)parentViewController;

/*
 * Receive callbacks about the life of a recorded video.
 * The KamcordDelegate protocol is defined in Common/Core/KamcordProtocols.h
 */
+ (void)setDelegate:(id <KamcordDelegate>)delegate;
+ (id <KamcordDelegate>)delegate;

/*
 * Set the resolution of the recorded video
 *
 * When you release your game, use one of:
 *  - SMART_VIDEO_RESOLUTION/LOW_VIDEO_RESOLUTION
 *  - MEDIUM_VIDEO_RESOLUTION
 *
 * For trailers, use TRAILER_VIDEO_RESOLUTION.
 */
typedef enum
{
    SMART_VIDEO_RESOLUTION      = 0,
    LOW_VIDEO_RESOLUTION        = 0,
    MEDIUM_VIDEO_RESOLUTION     = 1,
    TRAILER_VIDEO_RESOLUTION    = 2,
} KC_VIDEO_RESOLUTION;

+ (void)setVideoResolution:(KC_VIDEO_RESOLUTION)resolution;
+ (KC_VIDEO_RESOLUTION)videoResolution;


/*
 * You can set the maximum length of a recorded video in seconds. If the gameplay lasts longer
 * than that, only the last N seconds will get recorded in the final video.
 */
+ (void)setMaximumVideoLength:(NSUInteger)seconds;
+ (NSUInteger)maximumVideoLength;

/*
 * Returns a UIView of the thumbnail cropped to the given width and height.
 */
+ (UIView *)getThumbnailViewWithWidth:(NSUInteger)width
                               height:(NSUInteger)height
                 parentViewController:(UIViewController *)parentViewController;

// -------------------------------------------------------------------------
// Audio Recording
// -------------------------------------------------------------------------
#if (COCOS2D || KAMCORD_CUSTOM_ENGINE)
/*
 * Declare the ASBD of the audio stream. This method MUST be called before
 * any audio data is written.
 */
+ (void)setASBD:(AudioStreamBasicDescription)asbd;

/*
 * 
 */
+ (void)writeAudioBytes:(void *)data
             numSamples:(UInt32)numSamples;
#endif

// -------------------------------------------------------------------------
// Video Metadata and Social Media Settings
// -------------------------------------------------------------------------

/*
 * Set the level and score of the last recorded video.
 */
+ (void)setLevel:(NSString *)level
           score:(NSNumber *)score;
+ (NSString *)level;
+ (NSNumber *)score;

/*
 * The default text to show in the share box regardless of network shared to.
 */
+ (void)setDefaultTitle:(NSString *)title;
+ (NSString *)defaultTitle;

/*
 * Set metadata for YouTube, Facebook, Twitter, Email
 */

/*
 * Pass Facebook Native iOS 6 credentials by using this setting
 */
+ (void)setFacebookAppID:(NSString *)facebookAppID;
+ (NSString *)facebookAppID;

+ (void)setYouTubeDescription:(NSString *)description
                         tags:(NSString *)tags;
+ (void)setYouTubeVideoCategory:(NSString *)category;
+ (NSString *)youtubeDescription;
+ (NSString *)youtubeTags;
+ (NSString *)youtubeCategory;

/*
 * Facebook share defaults
 */
+ (void)setFacebookTitle:(NSString *)title
                 caption:(NSString *)caption
             description:(NSString *)description;
+ (NSString *)facebookTitle;
+ (NSString *)facebookCaption;
+ (NSString *)facebookDescription;

+ (void)setTwitterDescription:(NSString *)description;
+ (NSString *)twitterDescription;

+ (void)setDefaultEmailBody:(NSString *)body;
+ (NSString *)defaultEmailBody;

/*
 * Attach arbitrary key/value metadata to the last recorded video
 * that you can retrieve later from the Kamcord servers.
 */
+ (void)setVideoMetadata:(NSDictionary *)metadata;
+ (NSDictionary *)videoMetadata;

/*
 * This method will query the Kamcord servers for metadata you've previously
 * associated with an uploaded video via the setVideoMetadata API call.
 * When the server request returns, the original metadata you had set
 * will be returned to you as the first argument of the block.
 * There is also NSError argument in the block that will indicate if the
 * request was successful (for example, if the connection failed due to
 * a poor internet connection). The returned NSDictionary is valid if and only if
 * the NSError object is nil.
 *
 * You can get the Kamcord Video ID to pass to this method by implementing the
 * KamcordDelegate protocol defined in Common/Core/KamcordProtocols.h.
 * Implement the videoFinishedUploadingWithSuccess:kamcordVideoID: callback
 * to get the Kamcord Video ID.
 */
+ (void)retrieveMetadataForVideoWithID:(NSString *)kamcordVideoID
                 withCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler;

+ (void)showPushNotificationViewInParent:(UIViewController *)parentViewController
                                                         withParams:(NSDictionary *)params;

// -------------------------------------------------------------------------
// Advanced Settings
// -------------------------------------------------------------------------

/*
 * Control whether or not the video controls display when the video is replayed.
 */
+ (void)setShowVideoControlsOnReplay:(BOOL)showControls;
+ (BOOL)showVideoControlsOnReplay;


// -------------------------------------------------------------------------
// Custom Skinning
// For more information, please visit here:
// https://github.com/kamcord/cocos2d-2.0-kamcord/wiki/Using-the-Kamcord-API%3A-Skinning-the-Kamcord-UI
// -------------------------------------------------------------------------

/*
 * Set the value for a particular part of the UI you'd like to reskin.
 */
+ (void)setValue:(NSObject *)value
  forUiComponent:(KC_UI_COMPONENT)uiComponent;


// -------------------------------------------------------------------------
// Custom sharing API
// -------------------------------------------------------------------------

// Used for both Case 1 and Case 2

/* Replay the latest video in the parent view controller.
 * The "latest video" is defined as the last one for which
 * you called [Kamcord stopRecording].
 */
+ (void)presentVideoPlayerInViewController:(UIViewController *)parentViewController
                                  forVideo:(KCVideo *)video;

/* The object that will receive callbacks about sharing state.
 * This delegate is retained by Kamcord until all the callbacks
 * are complete, after which it is released by Kamcord.
 */
+ (void)setShareDelegate:(id <KCShareDelegate>)delegate;
+ (id <KCShareDelegate>)shareDelegate;

/*
 * Case 1: Use the following API for sharing if you want
 *         your own custom UI but would like Kamcord to handle
 *         all of the Facebook/Twitter/YouTube authentication for you.
 */

/*
 * Authenticate to the three social media services
 */
+ (void)showFacebookLoginView;
+ (void)showTwitterAuthentication;
+ (void)showYouTubeLoginViewInViewController:(UIViewController *)parentViewController;

/*
 * Retrieve status of authentication
 */
+ (BOOL)facebookIsAuthenticated;
+ (BOOL)twitterIsAuthenticated;
+ (BOOL)youTubeIsAuthenticated;

/*
 * Log out
 */
+ (void)performFacebookLogout;
+ (void)performYouTubeLogout;

/*
 * The method to share a message on these services.
 * You can also use this if you want to mix different
 * authentications. For instance, you can handle
 * Facebook and Twitter auth and let Kamcord upload
 * to YouTube with its own auth (which it got via
 * presentYouTubeLoginViewInViewController: above.
 * Simply call this with shareFacebook and shareTwitter set to NO
 * and shareYouTube set to YES.
 *
 * Once the video uploads are done, we will call back
 * to videoIsReadyToShare.
 *
 * Returns YES if the share was accepted for processing.
 * Returns NO if there was a previous share that is still
 * in its early stages (specifically, before a generalError:
 * or shareshareStartedWithSuccess:error: callback).
 */
+ (BOOL)shareVideo:(KCVideo *)video
        onFacebook:(BOOL)shareFacebook
           Twitter:(BOOL)shareTwitter
           YouTube:(BOOL)shareYouTube
             Email:(BOOL)shareEmail
       withMessage:(NSString *)message
mailViewParentViewController:(UIViewController *)parentViewController;

/*
 * Show the send email dialog with the Kamcord URL in the message.
 * Any additional body text you'd like to add should be passed in the
 * second argument.
 */
+ (void)presentComposeEmailViewInViewController:(UIViewController *)parentViewController
                                       withBody:(NSString *)bodyText;


/*
 * Case 2: Use the following API for sharing if you want to use
 *         your own custom UI and will also perform all of the
 *         Facebook/Twitter/YouTube authentication yourself.
 *         Simply call this one function that will upload the video
 *         to Kamcord (and optionally YouTube). Once the video is successfully
 *         uploaded, you'll get a callback to
 *
 *         - (void)videoIsReadyToShare:(NSURL *)onlineVideoURL
 *                           thumbnail:(NSURL *)onlineThumbnailURL
 *                             message:(NSString *)message
 *                                data:(NSDictionary *)data
 *                               error:(NSError *)error;
 *
 *         (defined above in KCShareDelegate).
 *         If you don't want to upload to YouTube, simply pass
 *         in nil for the youTubeAuth object.
 *
 *          The data object you pass in will be passed back to you
 *         in videoIsReadyToShare.
 *
 *         Returns YES if the share was accepted for processing.
 *         Returns NO if there was a previous share that is still
 *         in its early stages (specifically, before a generalError:
 *         or shareshareStartedWithSuccess:error: callback).
 */
+ (BOOL)shareVideoWithMessage:(NSString *)message
              withYouTubeAuth:(GTMOAuth2Authentication *)youTubeAuth
                         data:(NSDictionary *)data;


// -------------------------------------------------------------------------
// Audio Overlay APIs
// -------------------------------------------------------------------------

#ifndef KCUNITY_VERSION

/*
 * Deprecated audio recording API (since V1.0.2).
 */

+ (KCAudio *)playSound:(NSString *)filename
                  loop:(BOOL)loop;
+ (KCAudio *)playSound:(NSString *)filename;
+ (KCAudio *)playSoundAtURL:(NSURL *)fileURL
                       loop:(BOOL)loop;
+ (KCAudio *)playSoundAtURL:(NSURL *)fileURL;
+ (KCAudio *)audioBackground;

// Will stop all looping, non-looping, or looping and non-looping sounds.
typedef enum
{
    NONLOOPING_SOUNDS,
    LOOPING_SOUNDS,
    ALL_SOUNDS
} KC_SOUND_TYPE;
+ (void)stopAllSounds:(KC_SOUND_TYPE)soundType;

// If you have specific sounds you want to overlay at particular times,
// pass in an array populated with KCSound objects.
+ (BOOL)stopRecordingAndAddSounds:(NSArray *)sounds;

#endif


// -------------------------------------------------------------------------
// For Kamcord internal used, don't worry about these
// -------------------------------------------------------------------------

// Returns the singleton Kamcord object. You don't ever really need this, just
// use the static API calls.
+ (Kamcord *)sharedManager;

+ (BOOL)prepareNextVideo;
+ (BOOL)prepareNextVideo:(BOOL)async;

/*
 * Analytics
 */
+ (void)track:(NSString *)eventName
   properties:(NSDictionary *)properties
analyticsType:(KC_ANALYTICS_TYPE)analyticsType;

/*
 * Support for retina displays
 */
+ (unsigned int)resolutionScaleFactor;

/*
 * Is this device an iPhone 5?
 */
+ (BOOL)isIPhone5;

/*
 * Returns YES if an internet connection is available.
 */
+ (BOOL)checkInternet;


/*
 * Deprecated audio API
 */
+ (BOOL)enableSynchronousConversionUI;

/*
 * Using UIKit autorotation?
 */
+ (BOOL)useUIKitAutorotation;

/*
 * Supports portrait and portrait-upsidedown?
 */
+ (BOOL)supportPortraitAndPortraitUpsideDown;
+ (void)setSupportPortraitAndPortraitUpsideDown:(BOOL)value;

#ifndef KCUNITY_VERSION
/*
 * The audio recorder
 */
+ (id <KCAudioListener>)audioListener;

#endif

#if KCUNITY_VERSION

+ (int)audioSampleRate;
+ (int)audioBufferSize;
+ (int)numAudioChannels;

#endif


@end
