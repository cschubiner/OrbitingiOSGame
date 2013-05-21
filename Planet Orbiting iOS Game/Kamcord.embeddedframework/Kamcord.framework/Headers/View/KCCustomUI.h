//
//  KCCustomUI.h
//  cocos2d-ios
//
//  Created by Haitao Mao on 4/10/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/* An abstract representation of a Kamcord gameplay video. This video can either live locally or on the Kamcord servers. When the video has been uploaded, the copy stored on local disk will be deleted shortly after and the video live only on the server. */
@interface KCVideoTicket : NSObject

/* Metadata for the video. The title, level, score, can be modified before the video starts uploading. */
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * level;
@property (nonatomic, retain) NSNumber * score;
- (NSString *)getVideoID;
- (CGImageRef)getThumbnail;

/* Check the status of a local video. These will both be true if this video lives on the Kamcord server. */
- (BOOL)isFinishedProcessing;
- (BOOL)isFinishedUploading;

@end



/* Callbacks for changes in state of its corresponding video ticket. */
@protocol VideoTicketDelegate <NSObject>

@optional

/* Called when the video has finished its local processing and is ready to be replayed and uploaded */
- (void)videoFinishedProcessing;

/* Called when the video has finished uploading, video ID is available */
- (void)videoFinishedUploading;

/* Called when the upload failed for some reason */
- (void)videoUploadFailed;

/* Called when the video data has been retrieved from Kamcord servers */
- (void)videoFinishedRetrievalWithTicket:(KCVideoTicket *)ticket;

/* Called if the video data retrieval failed for some reason */
- (void)videoRetrievalFailed;
@end



/* The API for apps that want to implement Kamcord functionality but do not want to use the built-in UI. */
@interface KCCustomUI : NSObject

/* Records the video. Pass in a delegate after the recording is complete to receive an update on when the video finishes processing and is available for replaying and uploading. Once a new recording is started, old recordings that have not begun being uploaded are cleared from local storage. */
+ (void)startNewRecording;
+ (void)pauseRecording;
+ (void)resumeRecording;
+ (KCVideoTicket *)stopRecordingWithDelegate:(id <VideoTicketDelegate>)delegate;

/* Play the given video in the full screen Kamcord video player. If called before the video is 
   finished processing, nothing will happen.  */
+ (void)showVideoFullScreen:(KCVideoTicket *)ticket;
/* Upload the given video to Kamcord servers. The videoID becomes available after the upload finishes.
   If called before the video is finished processing, nothing will happen. Returns YES if this caused an 
   upload to start, and NO if the upload is already happening or the video has already been deleted. */
+ (BOOL)uploadVideo:(KCVideoTicket *)ticket;

/* Retrieves the video ticket for the video with the given just a video ID. The delegate will be passed the ticket once the download finishes. */
+ (void)retrieveTicketForVideoWithID:(NSString *)videoID
                            delegate:(id <VideoTicketDelegate>)delegate;

@end
