//
//  VideoTableViewCell.h
//  cocos2d-ios
//
//  Created by Chris Perciballi on 12/20/12.
//
//

#import <UIKit/UIKit.h>
#import "KCUiAssetMap.h"

typedef struct
{
    int titlePosX;
    int titlePosY;
    int titleWidth;
    int titleHeight;
    
    int timestampPosX;
    int timestampPosY;
    int timestampWidth;
    int timestampHeight;
    
    int labelFontSize;
    
    int thumbnailPosX;
    int thumbnailPosY;
    int thumbnailWidth;
    int thumbnailHeight;
    
    int playButtonCenterX;
    int playButtonCenterY;
    int playButtonWidth;
    int playButtonHeight;
    
    int backgroundPosX;
    int backgroundPosY;
    int backgroundWidth;
    int backgroundHeight;
    
    bool roundCorners;
    
} KCLayout;

@interface VideoTableViewCell : UITableViewCell

@property (nonatomic, retain) UIImageView * thumbnail;
@property (nonatomic, retain) UIImageView * playButton;
@property (nonatomic, retain) UILabel *     title;
@property (nonatomic, retain) UILabel *     timestampLabel;
@property (nonatomic, retain) UIImageView * background;
//@property (nonatomic, retain) UIImageView * commentIcon;
//@property (nonatomic, retain) UIButton *    commentButton;
//@property (nonatomic, retain) UIImageView * likeIcon;
//@property (nonatomic, retain) UIButton *    likeButton;	
@property (atomic, assign)  KCLayout *layout;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
            xOffset:(int)xOffset
            forUser:(BOOL)forUser
           assetMap:(KCUiAssetMap *)assetMap;

@end
