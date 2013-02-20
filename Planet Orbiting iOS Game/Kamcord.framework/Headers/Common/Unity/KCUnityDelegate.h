//
//  KCUnityVideoDelegate.h
//  Unity-iPhone
//
//  Created by Kevin Wang on 10/3/12.
//
//

#import "Kamcord.h"

@interface KCUnityDelegate : NSObject<KamcordDelegate>

- (id)init;
- (void)dealloc;

////////////////////////////////////////////////////////////////
// KamcordDelegate protocol

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
- (void)videoFinishedUploadingWithSuccess:(BOOL)success
                           kamcordVideoID:(NSString *)videoID;

@end
