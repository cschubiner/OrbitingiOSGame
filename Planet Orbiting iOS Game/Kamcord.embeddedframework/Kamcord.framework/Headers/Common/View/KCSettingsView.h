//
//  KC_iPhoneSettingsViewLandscape.h
//  cocos2d-ios
//
//  Created by Chris Grimm on 6/27/12.
//  Copyright (c) 2012 Kamcord. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Kamcord.h"
#import "KCViewController.h"
#import "SHKSharer.h"
#import "KCUiAssetMap.h"

@interface KCSettingsView : UITableViewController <KCShareDelegate, UIAlertViewDelegate, UIActionSheetDelegate, KCSHKSharerDelegate>

@property (nonatomic, retain) NSMutableArray * networkInfo;

-(id) initWithAssetMap:(KCUiAssetMap *)assetMap;

@end


@interface NetworkShareInfo : NSObject

@property (nonatomic, retain) NSString * connectMessage;
@property (nonatomic, retain) NSString * disconnectMessage;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) UIButton * signInButton;
@property (nonatomic, retain) UIButton * signOutButton;
@property (nonatomic, retain) UILabel  * label;
@property (nonatomic, retain) UILabel  * titleLabel;

@end
