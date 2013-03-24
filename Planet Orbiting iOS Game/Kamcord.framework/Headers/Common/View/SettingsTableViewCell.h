//
//  SettingsTableViewCell.h
//  cocos2d-ios
//
//  Created by Chris Perciballi on 12/22/12.
//
//

#import <UIKit/UIKit.h>

@interface SettingsTableViewCell : UITableViewCell

typedef struct
{
    int backgroundPosX;
    int backgroundPosY;
    int backgroundWidth;
    int backgroundHeight;
    bool roundCorners;
    
    int imagePosX;
    int imagePosY;
    int imageWidth;
    int imageHeight;
    
    int titlePosX;
    int titlePosY;
    int titleWidth;
    int titleHeight;
    int titleFontSize;
    
    int labelPosX;
    int labelPosY;
    int labelWidth;
    int labelHeight;
    int labelFontSize;
    
    int buttonPosX;
    int buttonPosY;
    int buttonWidth;
    int buttonHeight;
    int buttonFontSize;
    
} KCSettingsLayout;


@property (nonatomic, retain) UIButton * button;
@property (nonatomic, retain) UIImageView * image;
@property (nonatomic, assign) KCSettingsLayout *layout;

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
            xOffset:(int) xOffset;

-(void)setupWithBounds:(CGSize)bounds
                 image:(NSString*)imageName
                button:(UIButton*)newButton
               imgSize:(NSInteger)size
                 label:(UILabel*)label
            titleLabel:(UILabel*)titleLabel
;

@end
