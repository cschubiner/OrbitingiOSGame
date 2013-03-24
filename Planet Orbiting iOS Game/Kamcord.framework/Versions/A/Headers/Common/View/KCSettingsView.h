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

@interface KCSettingsView : UITableViewController <KCShareDelegate, UIAlertViewDelegate, UIActionSheetDelegate, KCSHKSharerDelegate>

@property (nonatomic, retain) NSMutableArray * networkInfo;

@end


@interface NetworkShareInfo : NSObject

@property (nonatomic, retain) NSString * connectMessage;
@property (nonatomic, retain) NSString * disconnectMessage;
@property (nonatomic, retain) NSString * imageName;
@property (nonatomic, retain) UIButton * button;
@property (nonatomic, retain) UILabel  * label;
@property (nonatomic, retain) UILabel  * titleLabel;

@end
