//
//  KCVideoStateAndViewManager.h
//
//
//  Created by Kevin Wang on 7/13/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import <Kamcord.h>
#if !KCUNITY_VERSION
#import "KCAudioRecorder.h"
#endif
#import "KCVideoProcessingAndShareManager.h"

#if KCZYNGA
#import "ZyngaKamcordProtocols.h"
#endif


@class KCUI;
@class KCVideoWriter;

@interface KCVideoStateAndViewManager : NSObject<KCVideoProcessDelegate>

// Everything we need before we put the job on the share queues
@property (nonatomic, retain) KCUI * preUploadManager;

@property (nonatomic, assign) UIViewController * parentViewController;

#if (!KCUNITY_VERSION && (COCOS2D || KAMCORD_CUSTOM_ENGINE))
@property (nonatomic, retain) KCAudioRecorder * audioRecorder;
#endif

#ifndef KCUNITY_VERSION
// Audio background
@property (nonatomic, retain) KCAudio * audioBackground;
#endif

// Should the UI wait for conversion to finish before
// dismissing the share view?
@property (nonatomic, assign) BOOL enableSynchronousConversionUI;
@property (nonatomic, assign) BOOL alwaysShowProgressBar;

// Show video controls when the replay is presented?
@property (nonatomic, assign) BOOL showVideoControlsOnReplay;

// The location of the Kamcord directory
@property (nonatomic, retain) NSURL * kamcordDirectory;

// The active video writer
@property (nonatomic, assign) KCVideoWriter * activeVideoWriter;

// Video properties
@property (nonatomic, assign) CGSize        dimensions;
@property (nonatomic, assign) NSUInteger    bitrate;
@property (nonatomic, assign) float         targetFPS;

#if KCZYNGA
@property (nonatomic, assign) id <KamcordPushNotificationDelegate> pushNotifDelegate;
#endif

+ (KC_OS_VERSION)getDeviceOSVersion;
+ (NSString *)deviceOSVersionToString:(KC_OS_VERSION)osVersion;

- (id)init;

// Permanently disables Kamcord
- (void)disable;

- (BOOL)isViewShowing;
- (void)showWatchViewInViewController:(UIViewController *)parentViewController;
- (void)showViewInViewController:(UIViewController *)parentViewController;
- (void)showViewInViewController:(UIViewController *)parentViewController
                        forVideo:(KCVideo *)video
                        viewMode:(KC_VIEW_MODE)viewMode;
- (void)showZyngaShareViewInViewController:(UIViewController *)parentViewController;
- (void)showAutoPopViewInViewController:(UIViewController *)parentViewController;

- (UIView *)getThumbnailView:(NSUInteger)width
                    height:(NSUInteger)height
      parentViewController:(UIViewController *)parentViewController;

- (BOOL)cancelConversionForLatestVideo;

// Video
- (BOOL)beginVideoForce:(BOOL)force;
- (BOOL)endVideo:(KCVideoWriter *)videoWriter;
- (BOOL)endVideoAndDiscardVideo:(KCVideoWriter *)videoWriter;
- (BOOL)endVideo:(KCVideoWriter *)videoWriter
    andAddSounds:(NSArray *)sounds;

- (BOOL)startRecording;
- (BOOL)stopRecording;
- (BOOL)stopRecordingAndDiscardVideo;
- (BOOL)stopRecordingAndAddSounds:(NSArray *)sounds;
- (BOOL)pause;
- (BOOL)resume;
- (BOOL)isRecording;

- (void)markAbsoluteTime:(CFAbsoluteTime)absoluteTime;

// Video push notifications
- (void)retrieveMetadataForVideoWithID:(NSString *)videoID
                 withCompletionHandler:(void (^)(NSMutableDictionary *, NSError *))completionHandler;

- (void)showPushNotificationViewInParent:(UIViewController *)parentViewController
                              withParams:(NSDictionary *)params;

#if KCZYNGA
- (void)showVideoPushNotificationReceiverViewInParentViewController:(UIViewController *)parentViewController
                                                         withParams:(NSDictionary *)params;
#endif

- (void)setValue:(NSObject *)value
  forUiComponent:(KC_UI_COMPONENT)uiComponent;

#ifndef KCUNITY_VERSION
// Sound
- (KCAudio *)playAudioAtURL:(NSURL *)url
                     volume:(float)volume
                       loop:(BOOL)loop;
- (KCAudio *)playAudioWithName:(NSString *)name
                     extension:(NSString *)extension
                        volume:(float)volume
                          loop:(BOOL)loop;
- (void)stopAllSounds:(KC_SOUND_TYPE)soundType;

- (id <KCAudioListener>)audioListener;
#endif

#if KCUNITY_VERSION
- (void)writeAudioData:(void *)data
                length:(size_t)nbytes
           numChannels:(int)numChannels;
#endif

- (void)dealloc;


@end
