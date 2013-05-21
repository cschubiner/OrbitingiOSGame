//
//  KamcordAudioEngine.h
//

#import <AVFoundation/AVFoundation.h>

// ----------------------------------------------------------------
// The Kamcord Audio Engine for playing background sounds
// ----------------------------------------------------------------
@interface KamcordAudioEngine : NSObject <AVAudioSessionDelegate>

+ (void)init;

@end
