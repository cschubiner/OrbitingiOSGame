//
//  KCPushNotifUi.h
//  cocos2d-ios
//
//  Created by Chris Perciballi on 3/2/13.
//
//

#import <UIKit/UIKit.h>
#import "Kamcord.h"
#import "KCViewController.h"
#import "KCUiAssetMap.h"

@interface KCPushNotifUi : KCViewController

@property (nonatomic, retain) UIImageView * firstPlayerImageView;
@property (nonatomic, retain) UIImageView * secondPlayerImageView;
@property (nonatomic, retain) UILabel     * firstPlayerNameLabel;
@property (nonatomic, retain) UILabel     * secondPlayerNameLabel;
@property (nonatomic, retain) UILabel     * aboveVideoLabel;
@property (nonatomic, retain) UILabel     * belowVideoLabel;
@property (nonatomic, retain) UIButton    * callToActionButton;

- (id)initWithAssetMap:(KCUiAssetMap *)assetMap
                params:(NSDictionary *)params;
- (void)dismissView;

@end
