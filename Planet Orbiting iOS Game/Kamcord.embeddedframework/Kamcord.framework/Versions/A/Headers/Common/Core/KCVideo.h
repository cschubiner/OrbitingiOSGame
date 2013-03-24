//
//  KCVideo.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 5/30/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreMedia/CMTime.h>

#import "Kamcord.h"
#import "DataStructures/NSMutableArray+QueueAdditions.h"

@class KCVideo;
@class GTMOAuth2Authentication;
@class KCVideoSharingTask;

//////////////////////////////////////////////////////
// Begin KCVideoUploadStatus
@interface KCVideoUploadStatus : NSObject

@property (nonatomic, assign) int uploadPartSizeInBytes;
@property (nonatomic, assign) int lastUploadPartNumber;
@property (nonatomic, assign) int totalUploadParts;
@property (nonatomic, retain) NSString * s3VideoId;
@property (nonatomic, retain) NSString * s3BucketName;
@property (nonatomic, retain) NSString * s3UploadId;
@property (nonatomic, retain) NSString * s3Etags;
@property (nonatomic, assign) short youtubeUploadAttempt;
@property (nonatomic, assign) short kamcordUploadAttempt;
@property (nonatomic, assign) short uploadCompleted;

- (id)     initForUpload:(int)uploadPartSizeInBytes
    lastUploadPartNumber:(int)lastUploadPartNumber
        totalUploadParts:(int)totalUploadParts
               s3VideoId:(NSString *)s3VideoId
            s3BucketName:(NSString *)s3BucketName
              s3UploadId:(NSString *)s3UploadId
                 s3Etags:(NSString *)s3Etags
    youtubeUploadAttempt:(short)youtubeUploadAttempt
    kamcordUploadAttempt:(short)kamcordUploadAttempt
         uploadCompleted:(BOOL)uploadCompleted;

@end
// End KCVideoUploadStatus
//////////////////////////////////////////////////////


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

@property (readonly, nonatomic, retain) KCVideo * video;
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
@property (readonly, nonatomic, retain) id <KCShareDelegate> shareDelegate;
@property (readonly, nonatomic, retain) id <KamcordDelegate> delegate;

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
         shareDelegate:(id <KCShareDelegate>)shareDelegate
              delegate:(id <KamcordDelegate>)delegate;

- (void)finished:(KCVideoSharingTask *)task
           error:(NSError *)error;

- (NSDictionary *)getSharedOnDict;

- (void)dealloc;

@end
// End KCVideoSharingRequest
//////////////////////////////////////////////////////


//////////////////////////////////////////////////////
// Begin KCVideo
#if COCOS2D
@class KCAudioCollection;
#endif

@interface KCVideo : NSObject

// Make sure to modify deviceOSVersionToString if any values are added/removed to this enum.
typedef enum
{
    KC_OS_PRE_5_0, // 3.x and 4.x
    KC_OS_5_0_0,   // 5.0.0
    KC_OS_5_0_1,   // 5.0.1
    KC_OS_5_1,     // 5.1 and 5.1.1
    KC_OS_POST_6_0 // 6.0 and later
} KC_OS_VERSION;

// Make sure to modify videoStatusToString if any values are added/removed to this enum.
typedef enum
{
    KC_MAIN_VIEW = 0,
    KC_WATCH_ONLY_VIEW,
    KC_AUTO_POP_VIEW,
    KC_PUSH_NOTIF_RECEIVE_VIEW,
    KC_ZYNGA_MAIN_VIEW
} KC_VIEW_MODE;

// Make sure to modify viewModeToString if any values are added/removed to this enum.
typedef enum
{
    KC_VIDEO_STATUS_NONE                = 0,    // Just instantiated

    KC_VIDEO_BEGUN,                             // beginVideo
    KC_VIDEO_RECORDING,                         // startRecording
    KC_VIDEO_PAUSING,
    KC_VIDEO_PAUSED,                            // pause
    KC_VIDEO_STOPPING,
    KC_VIDEO_DONE_RECORDING,                    // stopRecording
    KC_VIDEO_ENDED,                             // endVideo

    KC_VIDEO_QUEUED_FOR_MERGE,
    KC_VIDEO_MERGING,
    KC_VIDEO_DONE_MERGING,

    KC_VIDEO_QUEUED_FOR_CONVERSION,
    KC_VIDEO_CONVERTING,
    KC_VIDEO_DONE_CONVERTING,

    KC_VIDEO_REQUESTING_KAMCORD_URL,
    KC_VIDEO_RECEIVED_KAMCORD_URL,

    KC_VIDEO_UPLOADING_TO_KAMCORD,
    KC_VIDEO_DONE_UPLOADING_TO_KAMCORD,

    KC_VIDEO_UPLOADING_TO_YOUTUBE,
    KC_VIDEO_DONE_UPLOADING_TO_YOUTUBE,

    KC_VIDEO_QUEUED_FOR_DELETION,
    KC_VIDEO_DONE_DELETING       
} KC_VIDEO_STATUS;

// The unique video ID
@property (readonly, nonatomic, copy) NSString * localVideoID;
@property (readonly, nonatomic, copy) NSURL * kamcordDirectory;

// Video state variable
@property KC_VIDEO_STATUS videoStatus;

@property (nonatomic, readonly, assign) BOOL hasStopped;
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

@property (nonatomic, assign) BOOL showViewForVideoAfterStopRecording;
@property (nonatomic, assign) KC_VIEW_MODE awaitingViewMode;

// Online URLs and IDs
@property (nonatomic, copy) NSString * onlineVideoID;
@property (nonatomic, copy) NSString * onlineThumbnailID;

@property (nonatomic, copy) NSString * onlineVideoBucketName;
@property (nonatomic, copy) NSString * onlineThumbnailBucketName;

@property (nonatomic, copy) NSString * onlineVideoTitle;
@property (nonatomic, copy) NSString * onlineVideoApplicationId;
@property (nonatomic, copy) NSString * onlineVideoApplicationName;
@property (nonatomic, copy) NSString * onlineVideoAddedAt;
@property (nonatomic, copy) NSString * onlineAppStoreURL;

@property (nonatomic, retain) NSURL * onlineKamcordWatchPageURL;
@property (nonatomic, retain) NSURL * onlineKamcordThumbnailURL;
@property (nonatomic, retain) NSURL * onlineKamcordExpectedVideoURL;

// This is probably the solution to our Youtube problem
@property (nonatomic, retain) NSURL * onlineYouTubeVideoURL;

@property (nonatomic, assign) BOOL uploadedToKamcord;
@property (nonatomic, assign) float uploadProgress;

#if COCOS2D
// Audio
@property (nonatomic, retain) KCAudioCollection * audioCollection;
#endif

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
@property (nonatomic, assign) NSPersistentStoreCoordinator * persistentStoreCoordinator;

// Public methods
+ (NSString *)videoStatusToString:(KC_VIDEO_STATUS)videoStatus;
+ (NSString *)viewModeToString:(KC_VIEW_MODE)viewMode;

+ (NSString *)getVideoDirectoryForVideo:(NSURL *)kamcordDirectory
                                videoId:(NSString *)videoId;

// Initializes a video with an ID
- (id)initWithID:(NSString *)videoID
kamcordDirectory:(NSURL *)kamcordDirectory
persistentStoreCoordinator:(NSPersistentStoreCoordinator *)persistentStoreCoordinator
   maximumLength:(CMTime)maxLength
   coreDataQueue:(dispatch_queue_t)coreDataQueue;

- (KC_VIDEO_STATUS)videoStatus;
- (void)setVideoStatus:(KC_VIDEO_STATUS)videoStatus;

- (void)updateVideoTrackerUploadStatus:(KCVideoUploadStatus *)uploadStatus
                                  eTag:(NSString *)eTag;

- (KCVideoUploadStatus *)getUploadStatus:(int)numberOfParts
                              numAttempt:(int)numAttempt
                          uploadPartSize:(int)uploadPartSize;

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

#if COCOS2D
- (void)stopAllSounds:(KC_SOUND_TYPE)soundType;
#endif

// Extracts the thumbnail from the video asset and saves it
// as the thumbnail for this video. If a thumbnail already exists,
// it just returns that one.
- (CGImageRef)extractThumbnailFromAsset:(AVURLAsset *)asset;

// API to track sharing task status
- (void)addTask:(KCVideoSharingTask *)shareTask;
- (void)taskStarted:(KCVideoSharingTask *)shareTask;
- (void)taskFinished:(KCVideoSharingTask *)shareTask
               error:(NSError *)error;

// Goes through all active tasks and will retry them
// if they've failed. These are the tasks that
// did not succeed and are queued for future retries.
//
// Returns the number of active tasks that were actually
// added for retrying.
- (NSUInteger)retryFailedActiveTasks;

// Erases all video files associated with this video
- (void)dealloc;

@end
// End KCVideo
//////////////////////////////////////////////////////
