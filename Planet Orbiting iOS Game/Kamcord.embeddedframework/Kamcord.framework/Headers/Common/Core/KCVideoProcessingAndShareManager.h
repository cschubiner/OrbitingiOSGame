//
//  KCShareManager.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 5/29/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

#import "KCVideo.h"
#import "Reachability.h"

// Forward class declarations
@class KCVideoProcessor;
@class KCShareHandler;

// Handles when a video is merged or converted
@protocol KCVideoProcessDelegate <NSObject>

- (void) mergeFinished:(KCVideo *)video
                 error:(NSError *)error;
- (void) conversionFinished:(KCVideo *)video
                      error:(NSError *)error;

- (void)setConversionProgress:(float)progress;

@end

typedef enum
{
    KC_MERGE_VIDEO,
    KC_CONVERT_VIDEO
} KC_VIDEO_PROCESS_TYPE;

typedef enum
{
    KC_STATE_NONE               = 1,
    KC_STATE_SUCCESS,
    KC_STATE_FAILED,
    KC_STATE_CANCELLED,
    KC_STATE_CANCEL_AND_RETRY,
    KC_STATE_FAILED_NONPOSITIVE_RENDERSIZE,
} KC_VIDEO_PROCESS_STATUS;

// An object needed to merge/convert a video
@interface KCVideoProcessingTask : NSObject

@property (nonatomic, retain) KCVideo * video;
@property (nonatomic, assign) id <KCVideoProcessDelegate> delegate;
@property (nonatomic, retain) KCVideoProcessor * taskHandler;
@property (nonatomic, assign) KC_VIDEO_PROCESS_TYPE type;
@property (nonatomic, assign) KC_VIDEO_PROCESS_STATUS status;

- (id) initWithVideo:(KCVideo *)video
            delegate:(id <KCVideoProcessDelegate>)delegate
                type:(KC_VIDEO_PROCESS_TYPE)processType;
- (void) dealloc;

@end

// An object needed to upload and share a video
@interface KCVideoSharingTask : NSObject

@property (nonatomic, retain) KCVideoShareRequest * shareRequest;
@property (nonatomic, retain) KCShareHandler * taskHandler;
@property (nonatomic, assign, readonly) BOOL finished;

// Number of times we've tried to process this task
@property (nonatomic, assign) int numAttempts;

// The error object for taskFinished (only valid once finished == YES
@property (nonatomic, retain) NSError * error;

- (id) initWithVideoShareRequest:(KCVideoShareRequest *)request;

// Tell the task it's started
- (void)started;

// Call this to tell the task that it's all done.
// This will release all the objects except for
// the share info.
- (void)finished:(NSError *)error;

- (void)dealloc;

@end


///////////////////////////////////////////////////////////////
// Handles video conversion and merging
@interface KCVideoProcessingAndShareManager : NSObject

// Are we currently merging, converting, or uploading/sharing?
@property (nonatomic, readonly) BOOL isActive;

-(id) init;

// Own custom video process callback
- (void)mergeFinished:(KCVideoProcessingTask *)obj
                error:(NSError *)error;
- (void)conversionFinished:(KCVideoProcessingTask *)obj
                     error:(NSError *)error;
- (void)shareFinished:(KCVideoSharingTask *)task
                error:(NSError *)error;

// Puts a job on the worker queue. Returns immediately and calls
// back to the delegates when finished.
- (void)mergeVideo:(KCVideo *)video
          delegate:(id <KCVideoProcessDelegate>)delegate;
- (void)convertVideo:(KCVideo *)video
            delegate:(id <KCVideoProcessDelegate>)delegate;
- (void)shareVideoRequest:(KCVideoShareRequest *)request;

// Try to erase this video
- (BOOL)safelyPerformTaskAndVideoCleanup:(KCVideo *)video;
// Cancel conversion for this video
- (BOOL)cancelConversionForVideo:(KCVideo *)video;

// Resume and cancel task queues
- (void)resumeTasks;
- (void)cancelAllActiveTasksAndPause;

// Moves this list of KCVideoSharingTasks to the front of the retry queue.
// Returns the number of tasks moved.
- (NSUInteger)moveTasksToFrontOfRetryQueue:(NSArray *)tasks;
- (void)processRetryQueue:(BOOL)requireWiFi;

// Are there any active or pending tasks?
// I don't care if it's a video converison, share, or pending share.
- (BOOL)hasActiveOrPendingTasks;

- (void)dealloc;

+ (NetworkStatus)getNetworkStatus;

@end
