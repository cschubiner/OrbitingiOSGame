//
//  KCVideo.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 5/30/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreMedia/CMTime.h>

#import "Kamcord.h"
#import "KCVideoTracker.h"
#import "DataStructures/NSMutableArray+QueueAdditions.h"

@class GTMOAuth2Authentication;
@class KCVideoSharingTask;

//////////////////////////////////////////////////////
// Begin KCVideoSharingRequest

typedef enum
{
    NONE,
    TRYING_TO_SHARE,
    EXPORT_CANCELLED,
    MAKING_PREUPLOAD_HTTP_POST,
    PREUPLOAD_HTTP_POST_DONE,
    SEND_SHARE_REQUEST,
    DONE_PENDING_CONVERSION,
    DONE,
    ERROR,
} KC_SHARE_REQUEST_STATE;


@interface KCVideoShareRequest : NSObject

@property (readonly, nonatomic, assign) KCVideo * video;
@property (readonly, nonatomic, copy)   NSString * message;

@property (nonatomic, assign) KC_SHARE_REQUEST_STATE shareState;
@property (nonatomic, assign) BOOL shareOnFacebook;
@property (nonatomic, assign) BOOL shareOnTwitter;
@property (nonatomic, assign) BOOL shareOnYouTube;
@property (nonatomic, assign) BOOL shareWithEmail;
@property (nonatomic, assign) BOOL alreadySharedWithEmail;
@property (readonly, nonatomic, assign) BOOL customUIShare;

@property (readonly, nonatomic, retain) NSDictionary * data;
@property (readonly, nonatomic, retain) GTMOAuth2Authentication * youTubeAuth;
@property (readonly, nonatomic, retain) id <KCShareDelegate> delegate;

- (id)    initForVideo:(KCVideo *)video
               message:(NSString *)message
       shareOnFacebook:(BOOL)shareOnFacebook
        shareOnTwitter:(BOOL)shareOnTwitter
        shareOnYouTube:(BOOL)shareOnYouTube
        shareWithEmail:(BOOL)shareWithEmail
alreadySharedWithEmail:(BOOL)alreadySharedWithEmail
         customUIShare:(BOOL)customUIShare
                  data:(NSDictionary *)data
           youTubeAuth:(GTMOAuth2Authentication *)auth
              delegate:(id <KCShareDelegate>)delegate;

- (void)finished:(KCVideoSharingTask *)task
           error:(NSError *)error;
- (void)dealloc;

@end
// End KCVideoSharingState
//////////////////////////////////////////////////////

 

// Used by KCVideo
@class KCVideoSharingTask;


//////////////////////////////////////////////////////
// Begin KCVideo
@class KCAudioCollection;

@interface KCVideo : NSObject

typedef enum
{
    KC_OS_PRE_5_0, // 3.x and 4.x
    KC_OS_5_0_0,   // 5.0.0
    KC_OS_5_0_1,   // 5.0.1
    KC_OS_POST_5_1 // 5.1 and later
} KC_OS_VERSION;

// The unique video ID
@property (readonly, nonatomic, copy) NSString * localVideoID;
@property (readonly, nonatomic, copy) NSURL * kamcordDirectory;

// Video state variable
@property KC_VIDEO_STATUS videoStatus;

@property (nonatomic, readonly, assign) BOOL hasStopped;
@property (nonatomic, readonly, assign) BOOL hasEnded;
@property (nonatomic, readonly, assign) BOOL isMerged;
@property (nonatomic, readonly, assign) BOOL isConverted;

// The marked times and time ranges (processed)
@property (nonatomic, readonly, retain) NSMutableArray * markedTimes;
@property (nonatomic, readonly, retain) NSMutableArray * markedTimeRanges;

// Information about the currently recorded clip
@property (nonatomic, assign) CFAbsoluteTime startTime;
@property (nonatomic, assign) CFAbsoluteTime timeOfLastRecordedFrame;

// The total duration of all previous clips (before the current clip)
@property (nonatomic, assign) CMTime durationOfAllPreviousClips;

// The maximum length of this video. If 0 (default), it's unlimited.
// If the video recording time goes over maximumLength, this video
// should be processed to only include the last maxiumLength time.
@property (nonatomic, assign) CMTime maximumLength;

// Only relevant if number of clips > 1 and maximumLength > 0
@property (nonatomic, assign) CMTime croppedVideoStartTime;

// Local video URLs
@property (nonatomic, readonly, retain) NSURL * videoDirectory;

@property (nonatomic, retain) NSMutableArray * videoClipLocalURLs;
@property (nonatomic, retain) NSURL * mergedVideoLocalURL;
@property (nonatomic, retain) NSURL * convertedVideoLocalURL;

@property (nonatomic, retain) CGImageRef thumbnail __attribute__((NSObject));
@property (nonatomic, retain) CGImageRef mergeThumbnail __attribute__((NSObject));
// Online URLs and IDs
@property (nonatomic, copy) NSString * onlineVideoID;
@property (nonatomic, copy) NSString * onlineThumbnailID;

@property (nonatomic, copy) NSString * onlineVideoBucketName;
@property (nonatomic, copy) NSString * onlineThumbnailBucketName;

@property (nonatomic, retain) NSURL * onlineKamcordVideoURL;
@property (nonatomic, retain) NSURL * onlineKamcordThumbnailURL;

// This is probably the solution to our Youtube problem
@property (nonatomic, retain) NSURL * onlineYouTubeVideoURL;

@property (nonatomic, assign) BOOL uploadedToKamcord;

// Audio
@property (nonatomic, retain) KCAudioCollection * audioCollection;

// Has everything that we need to do with this video been done?
// If so, we can just go ahead and erase it to save space.
@property (nonatomic, assign) BOOL markForDeletion;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, assign) BOOL markAsDoNotConvert;



// List of sharing tasks
@property (readonly, nonatomic, retain) NSMutableArray * pendingTasks;
@property (readonly, nonatomic, retain) NSMutableArray * activeTasks;
@property (readonly, nonatomic, retain) NSMutableArray * finishedTasks;



// The managed object context that we use to store video state.
@property (nonatomic, assign) NSManagedObjectContext * managedObjectContext;

// Public methods
+ (NSString *)videoStatusToString:(KC_VIDEO_STATUS)videoStatus;

// Initializes a video with an ID
- (id)initWithID:(NSString *)videoID
kamcordDirectory:(NSURL *)kamcordDirectory
managedObjectContext:(NSManagedObjectContext *)managedObjectContext
   maximumLength:(CMTime)maxLength;

- (KC_VIDEO_STATUS)videoStatus;
- (void)setVideoStatus:(KC_VIDEO_STATUS)videoStatus;

// Returns the URL of the current video being recorded
- (NSURL *)currentVideoClipLocalURL;

// Creates a new local file and sets the current video clip
// local URL to that file path. Returns YES on success.
- (BOOL)addNewVideoClip;

// Should be called to mark each individual interesting time
- (void)markAbsoluteTime:(CFAbsoluteTime)absoluteTime;

// Should be called only once after the video
// has finished recording.
- (void)compressMarkedTimes;

- (void)stopAllSounds:(KC_SOUND_TYPE)soundType;

- (void)updateVideoTrackerSharing:(KCVideoShareRequest *)shareRequest;

// API to track sharing task status
- (void)addTask:(KCVideoSharingTask *)shareTask;
- (void)taskStarted:(KCVideoSharingTask *)shareTask;
- (void)taskFinished:(KCVideoSharingTask *)shareTask
               error:(NSError *)error;


// Erases all video files associated with this video
- (void)dealloc;

@end
// End KCVideo
//////////////////////////////////////////////////////
