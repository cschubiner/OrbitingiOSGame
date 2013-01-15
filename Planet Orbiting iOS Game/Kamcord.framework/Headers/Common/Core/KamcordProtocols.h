//
//  KamcordProtocols.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 12/27/12.
//
//

// --------------------------------------------------------
// General Kamcord callbacks
//
@protocol KamcordDelegate <NSObject>

@optional

// Called when the Kamcord main view appears and disappears
- (void)mainViewDidAppear;
- (void)mainViewDidDisappear;

// Called when the Kamcord share view appears and disappears
- (void)shareViewDidAppear;
- (void)shareViewDidDisappear;

// Called when the movie player appears and disappears
- (void)moviePlayerDidAppear;
- (void)moviePlayerDidDisappear;

// Called when a thumbnail image for the video is ready
- (void)thumbnailReady:(CGImageRef)thumbnail;

#if KCUNITY
// Called when the thumbnail image for the video is ready
- (void)thumbnailReadyAtFilePath:(NSString *)thumbnailFilePath;
#endif

// Called when the user presses the share button and has successfully
// authorized with Facebook/Twitter/YouTube. This callback does NOT
// indicate that the share will successfully begin. The callback below
// named videoWillUploadToURL: indicates that the video will actually
// begin uploading.
- (void)shareButtonPressedWithMessage:(NSString *)message
                      shareToFacebook:(BOOL)facebook
                       shareToTwitter:(BOOL)twitter
                       shareToYouTube:(BOOL)youtube
                       shareWithEmail:(BOOL)email;


// Called when the video has started to upload
- (void)videoWillUploadToURL:(NSString *)kamcordURLString;

// Called when the video has finished uploading
- (void)videoFinishedUploadingWithSuccess:(BOOL)success;

@end

// --------------------------------------------------------
// Kamcord callbacks if you're implementing a custom UI
//


// --------------------------------------------------------
// The following enum and protocol are only relevant
// if you're implementing your own custom UI.
// If you're using the default Kamcord UI, please
// ignore the following as it is irrelevant for you.

@class GTMOAuth2Authentication;

// --------------------------------------------------------
// API elements for custom sharing UI.
// Will be documented soon as we roll out complete
// support for custom UIs.
typedef enum
{
    NO_ERROR,
    FACEBOOK_NOT_AUTHENTICATED,
    FACEBOOK_LOGIN_CANCELLED,
    FACEBOOK_DAILY_SHARE_EXCEEDED,
    FACEBOOK_SERVER_ERROR,
    
    TWITTER_NOT_SETUP,
    TWITTER_NOT_AUTHENTICATED,
    TWITTER_NO_ACCOUNTS,
    TWITTER_SERVER_ERROR,
    
    YOUTUBE_NOT_AUTHENTICATED,
    YOUTUBE_LOGIN_CANCELLED,
    YOUTUBE_SERVER_ERROR,
    
    EMAIL_NOT_SETUP,
    EMAIL_CANCELLED,
    EMAIL_FAILED,
    NO_INTERNET,
    
    KAMCORD_SERVER_ERROR,
    KAMCORD_S3_ERROR,
    
    NOTHING_TO_SHARE,
    MESSAGE_TOO_LONG,
    
    VIDEO_PROCESSING_ERROR,
} KCShareStatus;


typedef enum
{
    SUCCESS,
    NO_ACCOUNT,
    ACCESS_NOT_GRANTED,
} KCTwitterAuthStatus;


@protocol KCShareDelegate <NSObject>

@required
// Only after this callback (or a generalError below) is it safe
// make a new share request.
- (void)shareStartedWithSuccess:(BOOL)success error:(KCShareStatus)error;

// Errors that happen along the way
- (void)generalError:(KCShareStatus)error;



@optional
// --------------------------------------------------------
// Callbacks for case 1 (see below)

// Don't worry about deferring on sharing until these are
// called. Our internal system will wait until conversion
// is finished before your share request is executed.
- (void)videoMergeFinishedWithSuccess:(BOOL)success error:(NSError *)error;
- (void)videoConversionFinishedWithSuccess:(BOOL)success error:(NSError *)error;

// Auth requests
- (void)facebookAuthFinishedWithSuccess:(BOOL)success;
- (void)twitterAuthFinishedWithSuccess:(BOOL)success status:(KCTwitterAuthStatus)status;
- (void)youTubeAuthFinishedWithSuccess:(BOOL)success;

// Beginning of share process
// First: auth verification
- (void)facebookShareStartedWithSuccess:(BOOL)success error:(KCShareStatus)error;
- (void)twitterShareStartedWithSuccess:(BOOL)success error:(KCShareStatus)error;
- (void)youTubeUploadStartedWithSuccess:(BOOL)success error:(KCShareStatus)error;
- (void)emailSentWithSuccess:(BOOL)success error:(KCShareStatus)error;
//
// End of share process
- (void)facebookShareFinishedWithSuccess:(BOOL)success error:(KCShareStatus)error;
- (void)twitterShareFinishedWithSuccess:(BOOL)success error:(KCShareStatus)error;
- (void)youTubeUploadFinishedWithSuccess:(BOOL)success error:(KCShareStatus)error;

- (void)shareCancelled;


//
// Retrying failed uploads/shares
//


// Indicate that we are queueing a failed share for retrying later
- (void)queueingFailedShareForFutureRetry;

// Indicate that we are retrying failed uploads/shares
- (void)retryingPreviouslyFailedShares:(NSUInteger)numShares;

// Indicate that we have given up on retrying a failed share
- (void)stoppingRetryForFailedShare;


// The following callback will be made for both Option 1 and Option 2:

// We call this after we've received a video URL from the server.
// The purpose of this call is to give you two pieces of information:
//
//   1. The URL the video will be at once the upload finishes
//   2. The URL the video thumbnail will be at once the upload finishes
//
// We also pass in the data dictionary you passed in with the share request,
// along with any possible error messages.
- (void)videoWillBeginUploading:(NSURL *)onlineVideoURL
                      thumbnail:(NSURL *)onlineThumbnailURL
                           data:(NSDictionary *)data
                          error:(NSError *)error;


// If the error object is nil, then the video and thumbnail
// URLs are valid. Otherwise, the video and thumbnail URLs
// should not be considered valid, even if they are non-nil.
// The data is the original object that was passed in with the share request.
- (void)videoIsReadyToShare:(NSURL *)onlineVideoURL
                  thumbnail:(NSURL *)onlineThumbnailURL
                    message:(NSString *)message
                       data:(NSDictionary *)data
                      error:(NSError *)error;
@end

