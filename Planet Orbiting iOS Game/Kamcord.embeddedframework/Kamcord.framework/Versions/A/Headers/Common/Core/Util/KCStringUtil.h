//
//  KCStringUtil.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 3/4/13.
//
//

#import <Foundation/Foundation.h>

@interface KCStringUtil : NSObject

// Returns str if str is non-nil.
// Else if default is non-nil, returns default.
// Else returns @""
+ (NSString *)string:(NSString *)str
           orDefault:(NSString *)defaultStr;

@end
