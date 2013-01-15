//
//  KCAudioCollection.h
//  cocos2d-ios
//
//  Created by Matthew Zitzmann on 6/4/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CMTime.h>

#import "Kamcord.h"
#import "KCAudio.h"

@class KCVideo;

@interface KCAudioCollection : NSObject

// Store the audio objects
@property (nonatomic, retain) NSMutableArray * sounds;

// Add audio objects to the array
- (KCAudio *)playAudioWithName:(NSString *)name
                     extension:(NSString *)extension
                        volume:(float)volume
                          loop:(BOOL)loop
                      forVideo:(KCVideo *)video;

- (KCAudio *)playAudioAtURL:(NSURL *)url
                     volume:(float)volume
                       loop:(BOOL)loop
                   forVideo:(KCVideo *)video;

// Update the times of the audio objects in the array
- (void)startAllAndSetVideo:(KCVideo *)video;

- (void)stopAllSounds:(KC_SOUND_TYPE)soundType;

@end
