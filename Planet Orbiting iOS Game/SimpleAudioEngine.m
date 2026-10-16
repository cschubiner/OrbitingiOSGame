// AVFoundation replacement for the original CocosDenshion/OpenAL adapter.
#import "SimpleAudioEngine.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>

// Effects mix through AVAudioEngine from buffers decoded once into memory. AVAudioPlayer's
// play, pause and seek are synchronous calls into the system audio service; issuing them
// for every star pickup inside the physics tick stalled gameplay frames. Player nodes only
// queue work for the render thread. Varispeed resamples like OpenAL's pitch, so the rising
// pickup chime changes tone (and length) as it did originally, up to the game's 3x.
static const NSUInteger SSEffectVoiceCount = 12;

@interface SSEffectVoice : NSObject
@property (nonatomic, retain) AVAudioPlayerNode *player;
@property (nonatomic, retain) AVAudioUnitVarispeed *varispeed;
@property (nonatomic) ALuint soundID;
@property (nonatomic) CFTimeInterval endTime;
@end
@implementation SSEffectVoice
- (void)dealloc { [_player release]; [_varispeed release]; [super dealloc]; }
@end

@interface SimpleAudioEngine () {
    AVAudioPlayer *_music;
    AVAudioEngine *_engine;
    AVAudioFormat *_effectFormat;
    NSMutableArray *_voices;
    NSMutableDictionary *_buffers;
    ALuint _nextID;
    float _musicVolume, _effectsVolume;
    BOOL _resumeMusic;
}
@end
@implementation SimpleAudioEngine
static SimpleAudioEngine *sharedEngine;
+ (SimpleAudioEngine *)sharedEngine {
    if (!sharedEngine) sharedEngine = [[self alloc] init];
    return sharedEngine;
}
- (id)init {
    if ((self = [super init])) {
        _buffers = [NSMutableDictionary new]; _voices = [NSMutableArray new];
        _musicVolume = _effectsVolume = 1; enabled_ = YES;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        // Mono voices: the mixer still pans them, and every effect converts to one format.
        _effectFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100 channels:1];
        _engine = [AVAudioEngine new];
        for (NSUInteger i = 0; i < SSEffectVoiceCount; i++) {
            SSEffectVoice *voice = [SSEffectVoice new];
            voice.player = [[AVAudioPlayerNode new] autorelease];
            voice.varispeed = [[AVAudioUnitVarispeed new] autorelease];
            [_engine attachNode:voice.player]; [_engine attachNode:voice.varispeed];
            [_engine connect:voice.player to:voice.varispeed format:_effectFormat];
            [_engine connect:voice.varispeed to:_engine.mainMixerNode format:_effectFormat];
            [_voices addObject:voice]; [voice release];
        }
        [_engine prepare];
        [self startEffectsEngine];
        NSNotificationCenter *n = [NSNotificationCenter defaultCenter];
        [n addObserver:self selector:@selector(interrupted:) name:AVAudioSessionInterruptionNotification object:nil];
        [n addObserver:self selector:@selector(backgrounded:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [n addObserver:self selector:@selector(foregrounded:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}
// Voices stay playing for the engine's lifetime: -[AVAudioPlayerNode play] waits for an audio
// I/O cycle, so starting or stopping nodes per pickup would block the frame again.
- (void)startEffectsEngine {
    if (!_engine.isRunning) {
        NSError *error = nil;
        if (![_engine startAndReturnError:&error]) { NSLog(@"Audio engine did not start: %@", error); return; }
    }
    for (SSEffectVoice *voice in _voices) if (!voice.player.playing) [voice.player play];
}
- (NSURL *)urlForFile:(NSString *)file {
    NSString *path = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
    return path ? [NSURL fileURLWithPath:path] : nil;
}
- (AVAudioPlayer *)playerForFile:(NSString *)file {
    NSURL *url = [self urlForFile:file];
    if (!url) { NSLog(@"Missing audio asset: %@", file); return nil; }
    AVAudioPlayer *p = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [p prepareToPlay]; return [p autorelease];
}
- (AVAudioPCMBuffer *)effectBufferForFile:(NSString *)file {
    AVAudioPCMBuffer *buffer = [_buffers objectForKey:file];
    if (buffer) return buffer;
    NSURL *url = [self urlForFile:file];
    if (!url) { NSLog(@"Missing audio asset: %@", file); return nil; }
    AVAudioFile *source = [[[AVAudioFile alloc] initForReading:url error:nil] autorelease];
    AVAudioFormat *format = source.processingFormat;
    AVAudioFrameCount frames = (AVAudioFrameCount)source.length;
    if (!source || frames == 0) return nil;
    AVAudioPCMBuffer *decoded = [[[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity:frames] autorelease];
    if (![source readIntoBuffer:decoded error:nil]) return nil;
    if (![format isEqual:_effectFormat]) {
        AVAudioConverter *converter = [[[AVAudioConverter alloc] initFromFormat:format toFormat:_effectFormat] autorelease];
        converter.downmix = YES;
        AVAudioFrameCount capacity = (AVAudioFrameCount)ceil(frames * _effectFormat.sampleRate / format.sampleRate) + 4096;
        AVAudioPCMBuffer *converted = [[[AVAudioPCMBuffer alloc] initWithPCMFormat:_effectFormat frameCapacity:capacity] autorelease];
        __block BOOL supplied = NO;
        AVAudioConverterOutputStatus status = [converter convertToBuffer:converted error:nil withInputFromBlock:^AVAudioBuffer *(AVAudioPacketCount count, AVAudioConverterInputStatus *inputStatus) {
            if (supplied) { *inputStatus = AVAudioConverterInputStatus_EndOfStream; return nil; }
            supplied = YES; *inputStatus = AVAudioConverterInputStatus_HaveData; return decoded;
        }];
        if (status == AVAudioConverterOutputStatus_Error || converted.frameLength == 0) return nil;
        decoded = converted;
    }
    [_buffers setObject:decoded forKey:file];
    return decoded;
}
- (void)preloadBackgroundMusic:(NSString *)file { [_music stop]; [_music release]; _music = [[self playerForFile:file] retain]; }
- (void)playBackgroundMusic:(NSString *)file { [self playBackgroundMusic:file loop:YES]; }
- (void)playBackgroundMusic:(NSString *)file loop:(BOOL)loop {
    [self preloadBackgroundMusic:file]; _music.numberOfLoops = loop ? -1 : 0;
    _music.volume = mute_ || !enabled_ ? 0 : _musicVolume;
    if (enabled_) [_music play];
}
- (void)stopBackgroundMusic { _resumeMusic = NO; [_music stop]; _music.currentTime = 0; }
- (void)pauseBackgroundMusic { _resumeMusic = _music.playing; [_music pause]; }
- (void)resumeBackgroundMusic { if (enabled_) [_music play]; }
- (void)rewindBackgroundMusic { _music.currentTime = 0; }
- (BOOL)isBackgroundMusicPlaying { return _music.playing; }
- (BOOL)willPlayBackgroundMusic { return enabled_; }
- (void)preloadEffect:(NSString *)file { [self effectBufferForFile:file]; }
- (void)unloadEffect:(NSString *)file { [_buffers removeObjectForKey:file]; }
- (ALuint)playEffect:(NSString *)file { return [self playEffect:file pitch:1 pan:0 gain:1]; }
- (ALuint)playEffect:(NSString *)file pitch:(Float32)pitch pan:(Float32)pan gain:(Float32)gain {
    if (!enabled_ || mute_ || _effectsVolume <= 0) return 0;
    AVAudioPCMBuffer *buffer = [self effectBufferForFile:file];
    if (!buffer) return 0;
    if (!_engine.isRunning) [self startEffectsEngine];
    if (!_engine.isRunning) return 0;
    CFTimeInterval now = CACurrentMediaTime();
    SSEffectVoice *voice = nil;
    for (SSEffectVoice *candidate in _voices) {
        if (candidate.endTime <= now) { voice = candidate; break; }
        if (!voice || candidate.endTime < voice.endTime) voice = candidate; // Steal the voice ending first.
    }
    float rate = MAX(0.25f, MIN(4.0f, pitch));
    voice.varispeed.rate = rate;
    voice.player.pan = MAX(-1, MIN(1, pan));
    voice.player.volume = MAX(0, MIN(1, gain * _effectsVolume));
    [voice.player scheduleBuffer:buffer atTime:nil options:AVAudioPlayerNodeBufferInterrupts completionHandler:nil];
    if (!voice.player.playing) [voice.player play]; // Only after an engine reset.
    if (++_nextID == 0) _nextID = 1;
    voice.soundID = _nextID;
    voice.endTime = now + buffer.frameLength / buffer.format.sampleRate / rate;
    return voice.soundID;
}
- (void)silenceVoice:(SSEffectVoice *)voice {
    // Muting is immediate; the next sound on this voice interrupts the rest of the buffer.
    voice.player.volume = 0; voice.endTime = 0; voice.soundID = 0;
}
- (void)stopEffect:(ALuint)soundID {
    if (!soundID) return;
    for (SSEffectVoice *voice in _voices) if (voice.soundID == soundID) [self silenceVoice:voice];
}
- (void)silenceAllEffects { for (SSEffectVoice *voice in _voices) [self silenceVoice:voice]; }
- (float)backgroundMusicVolume { return _musicVolume; }
- (void)setBackgroundMusicVolume:(float)value { _musicVolume = MAX(0, MIN(1, value)); _music.volume = mute_ || !enabled_ ? 0 : _musicVolume; }
- (float)effectsVolume { return _effectsVolume; }
- (void)setEffectsVolume:(float)value {
    _effectsVolume = MAX(0, MIN(1, value));
    if (_effectsVolume == 0) [self silenceAllEffects];
}
- (BOOL)mute { return mute_; }
- (void)setMute:(BOOL)value {
    mute_ = value; [self setBackgroundMusicVolume:_musicVolume];
    if (value) [self silenceAllEffects];
}
- (BOOL)enabled { return enabled_; }
- (void)setEnabled:(BOOL)value { enabled_ = value; if (!value) [self pauseBackgroundMusic]; [self setBackgroundMusicVolume:_musicVolume]; }
- (void)backgrounded:(NSNotification *)n {
    [self pauseBackgroundMusic]; [self silenceAllEffects];
}
- (void)foregrounded:(NSNotification *)n {
    [self startEffectsEngine];
    if (_resumeMusic && enabled_) [_music play];
}
- (void)interrupted:(NSNotification *)n {
    if ([n.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue] == AVAudioSessionInterruptionTypeBegan) [self backgrounded:n];
    else if ([n.userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue] & AVAudioSessionInterruptionOptionShouldResume) [self foregrounded:n];
}
+ (void)end { [sharedEngine release]; sharedEngine = nil; }
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; [_music stop]; [_music release];
    [_engine stop]; [_engine release]; [_effectFormat release];
    [_voices release]; [_buffers release]; [super dealloc];
}
@end
