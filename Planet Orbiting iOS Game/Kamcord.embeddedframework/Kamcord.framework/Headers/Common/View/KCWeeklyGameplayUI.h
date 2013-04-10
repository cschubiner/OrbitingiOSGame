//
//  KCWeeklyGameplayUIViewController.h
//  cocos2d-ios
//
//  Created by Haitao Mao on 3/27/13.
//
//

#import <UIKit/UIKit.h>
#import "Kamcord.h"
#import "KCViewController.h"
#import "KCUiAssetMap.h"

@interface KCWeeklyGameplayUI : KCViewController

- (id)initWithAssetMap:(KCUiAssetMap *)assetMap
                params:(NSDictionary *)params;
- (void)dismissView;
- (void)dismissViewAndShowWatchView;

@end
