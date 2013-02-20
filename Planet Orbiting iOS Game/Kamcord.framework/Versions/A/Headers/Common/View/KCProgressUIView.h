//
//  KCProgressUIView.h
//  cocos2d-ios
//
//  Created by Amrik Kochhar on 1/21/13.
//
//

#import <UIKit/UIKit.h>
#import "KCVideo.h"
#import "VideoTableViewCell.h"

@interface KCProgressUIView : UITableViewCell

@property (nonatomic, retain) UIImageView * thumbnail;
@property (nonatomic, retain) UILabel *     title;
@property (nonatomic, retain) UIImageView * background;
@property (nonatomic, retain) UIProgressView * progressBar;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) VideoTableViewCell *internalCell;
@property (nonatomic, retain) UIButton *closeButton;
@property (nonatomic, retain) UIButton *retryButton;

- (id)initWithFrame:(CGRect) frame
              video:(KCVideo *)video;
- (void)setLabelText:(NSString *)text;
- (void)setProgressLevel:(float) progress;
-(void)setAnimating:(BOOL) animate;
@end
