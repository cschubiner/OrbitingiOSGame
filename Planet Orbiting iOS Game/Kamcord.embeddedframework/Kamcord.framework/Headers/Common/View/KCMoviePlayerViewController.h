//
//  KCMoviePlayerViewController.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 2/1/13.
//
//

#import <MediaPlayer/MediaPlayer.h>

@interface KCMoviePlayerViewController : MPMoviePlayerViewController

@end

@interface KCMPMoviePlayerViewController : KCMoviePlayerViewController

@property (nonatomic, assign) int appId;
@property (nonatomic, copy) NSString * videoId;
@property (nonatomic, assign) int feedPosition;

- (id)initWithContentURL:(NSURL *)contentUrl
                   appId:(int)appId
                 videoId:(NSString *)videoId
            feedPosition:(int)feedPosition;

@end
