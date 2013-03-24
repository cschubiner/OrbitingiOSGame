//
//  KCAudioRecorder.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 1/9/13.
//
//

#import "KCAudioListener.h"

@class KCVideoWriter;

@interface KCAudioRecorder : NSObject <KCAudioListener>

@property (nonatomic, retain) id <KCAudioListener> delegate;

- (id)init;
- (void)setASBDForAudioListener:(id <KCAudioListener>)audioListener;
- (void)dealloc;

@end
