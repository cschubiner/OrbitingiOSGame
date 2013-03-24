//
//  KCVideoWriter.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 5/2/12.
//  Copyright (c) 2012 Kamcord. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

#import "KCAudioListener.h"

@class KCVideo;

@interface KCVideoWriter : NSObject <KCAudioListener>

// Public properties
@property (nonatomic, retain, readonly) KCVideo * currentVideo;

// Only initializer
- (id)initWithDimensions:(CGSize)dimensions
            videoBitRate:(NSUInteger)bitRate
               targetFPS:(double)targetFPS
       videoWritingQueue:(dispatch_queue_t)queue;


- (BOOL)beginVideo:(KCVideo *)video;
- (BOOL)endVideo:(BOOL)discard;
- (BOOL)startRecording;
- (BOOL)pause;
- (BOOL)resume;
- (BOOL)stopRecordingWithCompletionHandler:(void (^)(BOOL))handler;
- (BOOL)isRecording;

- (BOOL)addFrameToVideo:(CVPixelBufferRef)pixelBuffer
                 atTime:(CFAbsoluteTime)time;

#if KCUNITY_VERSION
- (void)setAudioFormatDescription:(CMFormatDescriptionRef)desc;
- (void)audioBytesReady:(Float32 [])data numSamples:(UInt32)nsamples;
#endif

// Useful to know if we're currently writing frames or not
- (BOOL)isWriting;

- (void)markAbsoluteTime:(CFAbsoluteTime)absoluteTime;

// Housekeeping
- (void)prepare;
- (void)discardLastClip;

- (void)dealloc;

@end
