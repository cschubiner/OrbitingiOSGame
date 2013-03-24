//
//  KamcordAudioEngine.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 1/16/13.
//
//

#if COCOS2D

#import <AudioToolbox/AudioToolbox.h>
#import "../KCAudioListener.h"

#import "SimpleAudioEngine.h"
#import "CocosDenshion.h"


// ----------------------------------------------------------------
// Properties of the Kamcord Audio Engine
// ----------------------------------------------------------------
@interface KamcordAudioEngine : NSObject <AVAudioSessionDelegate>

// This static init method *MUST* be set before calling anything else.
+ (void)initWithSampleRate:(Float64)sampleRate;

+ (id <KCAudioListener>)audioListener;
+ (void)setAudioListener:(id <KCAudioListener>)listener;

+ (Float64)sampleRate;

@end

// ----------------------------------------------------------------
// This class inherits from CDSoundSource, so it includes all
// of those interface methods such as play, stop, pan, pitch, etc.
// ----------------------------------------------------------------
@interface KCAudioSource : CDSoundSource

@end

// ----------------------------------------------------------------
// Extension to play audio files
//
// By default, all calls to SimpleAudioEngine will use the Kamcord engine.
//
// If you want to  SimpleAudioEngine for a sound,
// call the corresponding method with the additional
// kamcord: parameter and pass in NO.
// ----------------------------------------------------------------
@interface SimpleAudioEngine (KamcordAudioEngineExtension)

// Volume
- (void)setBackgroundMusicVolume:(float)volume
                         kamcord:(BOOL)useKamcord;
- (float)backgroundMusicVolume:(BOOL)useKamcord;

- (void)setEffectsVolume:(float)effectsVolume
                 kamcord:(BOOL)useKamcord;
- (float)effectsVolume:(BOOL)useKamcord;

// For managing background sounds
- (void)preloadBackgroundMusic:(NSString*)filePath
                       kamcord:(BOOL)useKamcord;

- (void)playBackgroundMusic:(NSString*)filePath
                    kamcord:(BOOL)useKamcord;
- (void)playBackgroundMusic:(NSString*)filePath
                       loop:(BOOL)loop
                    kamcord:(BOOL)useKamcord;

- (void)stopBackgroundMusic:(BOOL)useKamcord;
- (void)pauseBackgroundMusic:(BOOL)useKamcord;
- (void)resumeBackgroundMusic:(BOOL)useKamcord;
- (void)rewindBackgroundMusic:(BOOL)useKamcord;

- (BOOL)isBackgroundMusicPlaying:(BOOL)useKamcord;


// New convenience methods that don't exist in SimpleAudioEngine
- (ALuint)playEffect:(NSString *)filePath
                loop:(BOOL)loop;

- (ALuint)playEffect:(NSString *)filePath
               pitch:(Float32)pitch
                 pan:(Float32)pan
                gain:(Float32)gain
                loop:(BOOL)loop;


// Methods to call SimpleAudioEngine (pass in NO for the kamcord: argument)

- (ALuint)playEffect:(NSString *)filePath
               pitch:(Float32)pitch
                 pan:(Float32)pan
                gain:(Float32)gain
             kamcord:(BOOL)useKamcord;

- (ALuint)playEffect:(NSString *)filePath
               pitch:(Float32)pitch
                 pan:(Float32)pan
                gain:(Float32)gain
                loop:(BOOL)loop
             kamcord:(BOOL)useKamcord;

- (ALuint)playEffect:(NSString *)filePath
             kamcord:(BOOL)useKamcord;

- (ALuint)playEffect:(NSString *)filePath
                loop:(BOOL)loop
             kamcord:(BOOL)useKamcord;

- (void)stopEffect:(ALuint)soundId
           kamcord:(BOOL)useKamcord;

- (void)preloadEffect:(NSString *)filePath
              kamcord:(BOOL)useKamcord;

- (void)unloadEffect:(NSString*)filePath
             kamcord:(BOOL)useKamcord;

- (CDSoundSource *)soundSourceForFile:(NSString *)filePath
                              kamcord:(BOOL)useKamcord;

@end

#endif
