//
//  AmazonClientManager.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 5/13/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <S3/AmazonS3Client.h>
#import "Constants.h"
#import "Response.h"


@interface AmazonClientManager : NSObject

+ (AmazonS3Client *)s3;

+ (bool)hasCredentials;
+ (Response *)validateCredentials;
+ (void)clearCredentials;
+ (void)wipeAllCredentials;

@end
