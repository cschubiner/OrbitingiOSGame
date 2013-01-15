//
//  KCSound.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 6/18/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@interface KCSound : NSObject

@property (nonatomic, copy) NSURL * url;
@property (nonatomic, assign) float volume; // Not yet functional
@property (nonatomic, assign) CMTime startTime;
@property (nonatomic, assign) CMTime endTime;

- (id)initWithSoundFileURL:(NSURL *)url
                 startTime:(CMTime)start
                   endTime:(CMTime)end;

- (void)dealloc;

@end
