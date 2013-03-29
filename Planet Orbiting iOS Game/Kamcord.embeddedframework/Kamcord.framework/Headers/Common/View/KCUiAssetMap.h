//
//  KCUiAssetMap.h
//  cocos2d-ios
//
//  Created by Chris Perciballi on 2/15/13.
//
//

#import <Foundation/Foundation.h>
#import "Kamcord.h"

// Starting this enum at 1000 because we use it inter-changeably with KC_UI_COMPONENT which starts at 0.
typedef enum
{
    KC_TURN_OFF_SHARE_GRID = 1000,
    KC_UI_TYPE,
    KC_ADD_SHADOW_TO_SHARE_BUTTONS_TEXT,
    KC_SHARE_PROMPT,
    KC_SHARE_GRID_LABEL,
    KC_ADJUST_SHARE_BUTTON_DIMENSIONS,
    KC_WATCH_VIEW_VIDEO_TAB,
    KC_SHARE_VIEW_CELL_WIDTH,
    KC_NAV_BAR_TEXT,
    KC_SHARE_PROMPT_WIDTH,
    KC_WATCH_VIEW_VIDEO_TIME_WORDING
} KC_INTERNAL_UI_COMPONENT;

@interface KCUiAssetMap : NSObject

- (id)initWithDefaults;

- (void)updateWithZyngaValues;
- (void)updateWithAutopopValues;

- (void)setValue:(id)value forUiComponent:(KC_UI_COMPONENT)uiComponent;
- (id)getValueForUiComponent:(KC_UI_COMPONENT)uiComponent;

@end
