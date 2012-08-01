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

#import "KCVideoTracker.h"
#import "DataStructures/NSMutableArray+QueueAdditions.h"

@class GTMOAuth2Authentication;

//////////////////////////////////////////////////////
// Begin KCVideoSharingState
@interface KCVideoShareInfo : NSObject

@property (readonly, nonatomic, copy)   NSString * message;
@property (readonly, nonatomic, assign) BOOL shareOnFacebook;
@property (readonly, nonatomic, assign) BOOL shareOnTwitter;
@property (readonly, nonatomic, assign) BOOL shareOnYouTube;
@property (readonly, nonatomic, assign) BOOL alreadySharedWithEmail;
@property (readonly, nonatomic, assign) NSDictionary * data;
@property (readonly, nonatomic, assign) GTMOAuth2Authentication * youTubeAuth;

- (id) initWithMessage:(NSString *)message
       shareOnFacebook:(BOOL)shareOnFacebook
        shareOnTwitter:(BOOL)shareOnTwitter
        shareOnYouTube:(BOOL)shareOnYouTube
alreadySharedWithEmail:(BOOL)alreadySharedWithEmail
                  data:(NSDictionary *)data
           youTubeAuth:(GTMOAuth2Authentication *)auth;

- (void) dealloc;

@end
// End KCVideoSharingState
//////////////////////////////////////////////////////



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

- (void)stopAllSounds:(BOOL)loop;

- (void)updateVideoTrackerSharing:(KCVideoShareInfo *)shareInfo;

// Erases all video files associated with this video
- (void)dealloc;

@end
// End KCVideo
//////////////////////////////////////////////////////
