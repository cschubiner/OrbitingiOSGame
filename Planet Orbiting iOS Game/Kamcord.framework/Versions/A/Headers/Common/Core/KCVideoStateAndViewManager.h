//
//  KCVideoStateAndViewManager.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 7/13/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "KCVideoProcessingAndShareManager.h"
#import "KCAudioListener.h"

@class KCUI;
@class KCVideoWriter;

@interface KCVideoStateAndViewManager : NSObject<KCVideoProcessDelegate>

// Everything we need before we put the job on the share queues
@property (nonatomic, retain) KCUI * preUploadManager;

@property (nonatomic, assign) UIViewController * parentViewController;

#if (COCOS2D_1_0_1 || COCOS2D_2_0 || COCOS2D_2_1)
// Audio background
@property (nonatomic, retain) KCAudio * audioBackground;
#endif

// Should the UI wait for conversion to finish before
// dismissing the share view?
@property (assign, nonatomic) BOOL enableSynchronousConversionUI;
@property (assign, nonatomic) BOOL alwaysShowProgressBar;

// Show video controls when the replay is presented?
@property (assign, nonatomic) BOOL showVideoControlsOnReplay;

// The location of the Kamcord directory
@property (nonatomic, retain) NSURL * kamcordDirectory;

// The active video writer
@property (nonatomic, assign) KCVideoWriter * activeVideoWriter;

// Video properties
@property (nonatomic, assign) CGSize        dimensions;
@property (nonatomic, assign) NSUInteger    bitrate;
@property (nonatomic, assign) float         targetFPS;

+ (KC_OS_VERSION)getDeviceOSVersion;
+ (NSString *)deviceOSVersionToString:(KC_OS_VERSION)osVersion;

- (id)init;

- (void)showViewInViewController:(UIViewController *)parentViewController
                      useOldView:(BOOL)oldView;
- (UIView *) getThumbnailView:(NSUInteger)width
         parentViewController:(UIViewController *)parentViewController;

- (BOOL)cancelConversionForLatestVideo;

// Video
- (BOOL)beginVideoForce:(BOOL)force;
- (BOOL)endVideo;

- (BOOL)endVideoAndAddSounds:(NSArray *)sounds;

- (BOOL)startRecording;
- (BOOL)stopRecording;
- (BOOL)stopRecordingAndDiscardVideo;
- (BOOL)stopRecordingAndAddSounds:(NSArray *)sounds;
- (BOOL)pause;
- (BOOL)resume;
- (BOOL)isRecording;

- (void)markAbsoluteTime:(CFAbsoluteTime)absoluteTime;

#if (COCOS2D_1_0_1 || COCOS2D_2_0 || COCOS2D_2_1)
// Sound
- (KCAudio *)playAudioAtURL:(NSURL *)url
                     volume:(float)volume
                       loop:(BOOL)loop;
- (KCAudio *)playAudioWithName:(NSString *)name
                     extension:(NSString *)extension
                        volume:(float)volume
                          loop:(BOOL)loop;
- (void)stopAllSounds:(KC_SOUND_TYPE)soundType;
#endif

#if (COCOS2D_1_0_1 || COCOS2D_2_0 || COCOS2D_2_1)
- (id <KCAudioListener>)audioListener;
#endif

#if KCUNITY
- (void)writeAudioData:(float [])data
                length:(size_t)nbytes
           numChannels:(int)numChannels;
#endif

- (void)dealloc;


@end
