//
//  KCAudioListener.h
//  Kamcord
//
//  Created by Kevin Wang on 12/31/12.
//
//

#import <AudioToolbox/AudioToolbox.h>

@protocol KCAudioListener <NSObject>

- (void)setAudioStreamBasicDescription:(AudioStreamBasicDescription)asbd;
- (void)audioBytesReady:(Float32 [])data
             numSamples:(UInt32)nsamples;

@end
