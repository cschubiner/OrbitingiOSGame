//
//  YouTubeUploader.h
//
//  Created by Kevin Wang on 3/23/12.
//  Copyright (c) 2012 Kamcord. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "../External/GData/GData.h"

// Upload status callbacks
@protocol KCYouTubeUploaderDelegate <NSObject>

@optional
- (void) loginIsSuccessful:(BOOL) success
              closedWindow:(BOOL) closedWindow
              deniedAccess:(BOOL) deniedAccess;

- (void) bytesSent:(unsigned long long) bytesSent
  ofTotalByteCount:(unsigned long long) dataLength;

- (void) uploadFinishedWithURL:(NSURL *) videoURL
                         error:(NSError *) error;
@end

@class GTMOAuth2Authentication;

@interface KCYouTubeUploader : NSObject <UIWebViewDelegate>
{
    NSString * developerKey_;
    NSString * appName_;
    NSURL * uploadLocationURL_;
    GDataServiceTicket * uploadTicket_;

    id <KCYouTubeUploaderDelegate> delegate_;

    UIViewController * parentViewController_;
}

// Public properties
@property (nonatomic, retain) NSString * developerKey;
@property (nonatomic, retain) NSString * appName;
@property (nonatomic, retain) id <KCYouTubeUploaderDelegate> delegate;
// The auth object
@property (nonatomic, retain) GTMOAuth2Authentication * auth;

// Public methods
- (BOOL)isAuthenticated;

- (id) initWithDelegate:(id <KCYouTubeUploaderDelegate>)delegate
        andDeveloperKey:(NSString *)developerKey
                appName:(NSString *)appName;
- (void) showUserLoginViewInViewController:(UIViewController *)parentViewController;

// Returns NO if the user is not logged in. The upload is not attempted (obviously).
// Returns YES if the user is logged in and the upload was attempted. Does NOT
// mean that the upload was successful. Must wait for the delegate callback
// uploadFinishedWithUrl:error: to verify that.
- (BOOL) uploadVideoFile:(NSString *)path
               withTitle:(NSString *)title
             description:(NSString *)description
                keywords:(NSString *)keywords;

// TODO: test somehow
- (void) restartUpload:(NSString *)path;

- (void) signOut;


@end
