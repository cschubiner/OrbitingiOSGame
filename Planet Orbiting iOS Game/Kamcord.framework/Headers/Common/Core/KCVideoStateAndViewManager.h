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

@interface KCVideoStateAndViewManager : NSObject<KCVideoProcessDelegate>

// Everything we need before we put the job on the share queues
@property (nonatomic, retain) KCUI * preUploadManager;

@property (nonatomic, assign) UIViewController * parentViewController;

// Audio background
@property (nonatomic, retain) KCAudio * audioBackground;

// Should the UI wait for conversion to finish before
// dismissing the share view?
@property (assign, nonatomic) BOOL enableSynchronousConversionUI;

// Show video controls when the replay is presented?
@property (assign, nonatomic) BOOL showVideoControlsOnReplay;


// Video properties
@property (nonatomic, assign) CGSize        dimensions;
@property (nonatomic, assign) NSUInteger    bitrate;
@property (nonatomic, assign) float         targetFPS;

- (id)init;

- (void)showView;
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

// Sound
- (KCAudio *)playAudioWithName:(NSString *)name
                     extension:(NSString *)extension
                        volume:(float)volume
                          loop:(BOOL)loop;

- (void)stopAllSounds:(KC_SOUND_TYPE)soundType;

- (void)dealloc;


@end
