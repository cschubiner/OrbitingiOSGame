// AVFoundation replacement for the original CocosDenshion/OpenAL adapter.
#import "SimpleAudioEngine.h"
#import <AVFoundation/AVFoundation.h>
@interface SimpleAudioEngine () <AVAudioPlayerDelegate> {
    AVAudioPlayer *_music;
    NSMutableDictionary *_effects, *_preloaded;
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
        _effects = [NSMutableDictionary new]; _preloaded = [NSMutableDictionary new];
        _musicVolume = _effectsVolume = 1; enabled_ = YES;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:YES error:nil];
        NSNotificationCenter *n = [NSNotificationCenter defaultCenter];
        [n addObserver:self selector:@selector(interrupted:) name:AVAudioSessionInterruptionNotification object:nil];
        [n addObserver:self selector:@selector(backgrounded:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [n addObserver:self selector:@selector(foregrounded:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}
- (NSURL *)urlForFile:(NSString *)file {
    NSString *path = [[NSBundle mainBundle] pathForResource:[file stringByDeletingPathExtension] ofType:[file pathExtension]];
    return path ? [NSURL fileURLWithPath:path] : nil;
}
- (AVAudioPlayer *)playerForFile:(NSString *)file {
    NSURL *url = [self urlForFile:file];
    if (!url) { NSLog(@"Missing audio asset: %@", file); return nil; }
    NSData *data = [_preloaded objectForKey:file];
    AVAudioPlayer *p = data ? [[AVAudioPlayer alloc] initWithData:data error:nil] : [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [p prepareToPlay]; return [p autorelease];
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
- (void)preloadEffect:(NSString *)file {
    NSURL *url = [self urlForFile:file]; NSData *data = url ? [NSData dataWithContentsOfURL:url] : nil;
    if (data) [_preloaded setObject:data forKey:file];
}
- (void)unloadEffect:(NSString *)file { [_preloaded removeObjectForKey:file]; }
- (ALuint)playEffect:(NSString *)file { return [self playEffect:file pitch:1 pan:0 gain:1]; }
- (ALuint)playEffect:(NSString *)file pitch:(Float32)pitch pan:(Float32)pan gain:(Float32)gain {
    if (!enabled_ || mute_ || _effectsVolume <= 0) return 0;
    if (_effects.count >= 32) {
        NSNumber *key = [[_effects allKeys] objectAtIndex:0]; [[_effects objectForKey:key] stop]; [_effects removeObjectForKey:key];
    }
    AVAudioPlayer *p = [self playerForFile:file]; if (!p) return 0;
    p.enableRate = YES; p.rate = MAX(0.5, MIN(2.0, pitch));
    p.pan = MAX(-1, MIN(1, pan)); p.volume = MAX(0, MIN(1, gain * _effectsVolume)); p.delegate = self;
    ALuint soundID = ++_nextID; [_effects setObject:p forKey:@(soundID)];
    if (![p play]) { [_effects removeObjectForKey:@(soundID)]; return 0; }
    return soundID;
}
- (void)stopEffect:(ALuint)soundID { [[_effects objectForKey:@(soundID)] stop]; [_effects removeObjectForKey:@(soundID)]; }
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)success {
    for (NSNumber *key in [[[_effects allKeys] copy] autorelease])
        if ([_effects objectForKey:key] == player) [_effects removeObjectForKey:key];
}
- (float)backgroundMusicVolume { return _musicVolume; }
- (void)setBackgroundMusicVolume:(float)value { _musicVolume = MAX(0, MIN(1, value)); _music.volume = mute_ || !enabled_ ? 0 : _musicVolume; }
- (float)effectsVolume { return _effectsVolume; }
- (void)setEffectsVolume:(float)value {
    _effectsVolume = MAX(0, MIN(1, value));
    if (_effectsVolume == 0) for (AVAudioPlayer *p in [_effects allValues]) [p stop];
}
- (BOOL)mute { return mute_; }
- (void)setMute:(BOOL)value {
    mute_ = value; [self setBackgroundMusicVolume:_musicVolume];
    if (value) { for (AVAudioPlayer *p in [_effects allValues]) [p stop]; [_effects removeAllObjects]; }
}
- (BOOL)enabled { return enabled_; }
- (void)setEnabled:(BOOL)value { enabled_ = value; if (!value) [self pauseBackgroundMusic]; [self setBackgroundMusicVolume:_musicVolume]; }
- (void)backgrounded:(NSNotification *)n {
    [self pauseBackgroundMusic]; for (AVAudioPlayer *p in [_effects allValues]) [p stop]; [_effects removeAllObjects];
}
- (void)foregrounded:(NSNotification *)n { if (_resumeMusic && enabled_) [_music play]; }
- (void)interrupted:(NSNotification *)n {
    if ([n.userInfo[AVAudioSessionInterruptionTypeKey] unsignedIntegerValue] == AVAudioSessionInterruptionTypeBegan) [self backgrounded:n];
    else if ([n.userInfo[AVAudioSessionInterruptionOptionKey] unsignedIntegerValue] & AVAudioSessionInterruptionOptionShouldResume) [self foregrounded:n];
}
+ (void)end { [sharedEngine release]; sharedEngine = nil; }
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self]; [_music stop]; [_music release];
    for (AVAudioPlayer *p in [_effects allValues]) [p stop];
    [_effects release]; [_preloaded release]; [super dealloc];
}
@end
