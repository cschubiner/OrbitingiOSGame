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

@class KCUI;
@class KCVideoWriter;

@interface KCVideoStateAndViewManager : NSObject<KCVideoProcessDelegate>

// Everything we need before we put the job on the share queues
@property (nonatomic, retain) KCUI * preUploadManager;

@property (nonatomic, assign) UIViewController * parentViewController;

// Audio background
@property (nonatomic, retain) KCAudio * audioBackground;

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

- (BOOL)endVideoAndDiscardVideo;
- (BOOL)endVideoAndAddSounds:(NSArray *)sounds;

- (BOOL)startRecording;
- (BOOL)stopRecording;
- (BOOL)pause;
- (BOOL)resume;
- (BOOL)isRecording;

- (void)markAbsoluteTime:(CFAbsoluteTime)absoluteTime;

// Sound
- (KCAudio *)playAudioAtURL:(NSURL *)url
                     volume:(float)volume
                       loop:(BOOL)loop;
- (KCAudio *)playAudioWithName:(NSString *)name
                     extension:(NSString *)extension
                        volume:(float)volume
                          loop:(BOOL)loop;
- (void)stopAllSounds:(KC_SOUND_TYPE)soundType;

#if KCUNITY
- (void)writeAudioData:(float [])data
                length:(size_t)nsamples
           numChannels:(int)numChannels;
#endif

- (void)dealloc;


@end
