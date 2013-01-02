//
//  KCVideoTracker.h
//  cocos2d-ios
//
//  Created by Aditya Rathnam on 6/30/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KCVideoTracker : NSManagedObject

@property (nonatomic, retain) NSDate * addedAt;
@property (nonatomic, retain) NSString * localVideoId;
@property (nonatomic, retain) NSNumber * s3UploadAttempt;
@property (nonatomic, retain) NSString * s3VideoId;
@property (nonatomic, retain) NSNumber * alreadySharedOnEmail;
@property (nonatomic, retain) NSNumber * sharedOnFacebook;
@property (nonatomic, retain) NSNumber * sharedOnTwitter;
@property (nonatomic, retain) NSNumber * sharedOnYoutube;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * videoPath;
@property (nonatomic, retain) NSNumber * videoStatus;
@property (nonatomic, retain) NSNumber * youtubeUploadAttempt;
@property (nonatomic, retain) NSNumber * uploadTrackingEnabled;

typedef enum
{
    KC_VIDEO_STATUS_NONE = 0,       // Just instantiated

    KC_VIDEO_BEGUN = 1,             // beginVideo
    KC_VIDEO_RECORDING = 2,         // startRecording
    KC_VIDEO_PAUSED = 3,            // pause
    KC_VIDEO_DONE_RECORDING = 4,    // stopRecording
    KC_VIDEO_ENDED = 5,             // endVideo

    KC_VIDEO_QUEUED_FOR_MERGE = 6,
    KC_VIDEO_MERGING = 7,
    KC_VIDEO_DONE_MERGING = 8,

    KC_VIDEO_QUEUED_FOR_CONVERSION = 9,
    KC_VIDEO_CONVERTING = 10,
    KC_VIDEO_DONE_CONVERTING = 11,

    KC_VIDEO_REQUESTING_KAMCORD_URL = 12,
    KC_VIDEO_RECEIVED_KAMCORD_URL = 13,

    KC_VIDEO_UPLOADING_TO_KAMCORD = 14,
    KC_VIDEO_DONE_UPLOADING_TO_KAMCORD = 15,

    KC_VIDEO_UPLOADING_TO_YOUTUBE = 16,
    KC_VIDEO_DONE_UPLOADING_TO_YOUTUBE = 17,

    KC_VIDEO_QUEUED_FOR_DELETION = 18,
    KC_VIDEO_DONE_DELETING = 19,
} KC_VIDEO_STATUS;

/*
- (KC_VIDEO_STATUS)videoStatusRaw;
- (void)setVideoStatusRaw:(KC_VIDEO_STATUS)videoStatus;
*/
@end
