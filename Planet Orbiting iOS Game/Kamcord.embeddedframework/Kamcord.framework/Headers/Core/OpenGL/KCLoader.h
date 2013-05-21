//
//  KCLoader.h
//  cocos2d-ios
//
//  Created by Dennis Qin on 4/23/13.
//
//

#import <UIKit/UIKit.h>

typedef enum
{
    KCEngineTypeUnknown = 0,
    KCEngineTypeCocos1,
    KCEngineTypeCocos2,
    KCEngineTypeCocosX,
    KCEngineTypeCocos, //Use for general cocos, keep cocos engines above this and others below, so then we can use e.g. if (engineType < KCEngineTypeCocos)
    KCEngineTypeCustom,
    KCEngineTypeUnity
} KCEngineType;


@interface KCLoader : UIView

+ (KCEngineType)engineType;
+ (void)setEngineType:(KCEngineType)engineType;

@end
