//
//  KCVideoTracker.h
//  cocos2d-ios
//
//  Created by Aditya Rathnam on 12/22/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface KCVideoTracker : NSManagedObject

@property (nonatomic, retain) NSDate * addedAt;
@property (nonatomic, retain) NSNumber * alreadySharedOnEmail;
@property (nonatomic, retain) NSNumber * lastUploadPartNumber;
@property (nonatomic, retain) NSNumber * kamcordUploadAttempt;
@property (nonatomic, retain) NSString * localVideoId;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSString * s3VideoId;
@property (nonatomic, retain) NSNumber * sharedOnFacebook;
@property (nonatomic, retain) NSNumber * sharedOnTwitter;
@property (nonatomic, retain) NSNumber * sharedOnYoutube;
@property (nonatomic, retain) NSNumber * totalUploadParts;
@property (nonatomic, retain) NSNumber * uploadCompleted;
@property (nonatomic, retain) NSString * uploadMethod;
@property (nonatomic, retain) NSNumber * uploadPartSizeInBytes;
@property (nonatomic, retain) NSString * videoPath;
@property (nonatomic, retain) NSNumber * videoStatus;
@property (nonatomic, retain) NSNumber * youtubeUploadAttempt;
@property (nonatomic, retain) NSString * s3BucketName;
@property (nonatomic, retain) NSString * s3Etags;
@property (nonatomic, retain) NSString * s3UploadId;

@end
