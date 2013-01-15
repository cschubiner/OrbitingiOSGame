//
//  SHKXMLResponseParser.h
//  ShareKit
//
//  Created by Vilem Kurz on 27.1.2012.
//  Copyright (c) 2012 Cocoa Miners. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KC_SHKXMLResponseParser;
@compatibility_alias SHKXMLResponseParser KC_SHKXMLResponseParser;
@interface KC_SHKXMLResponseParser : NSObject <NSXMLParserDelegate>

+ (NSString *)getValueForElement:(NSString *)element fromResponse:(NSData *)data;

@end

