//
//  KCAudioRecorder.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 1/9/13.
//
//

#import "KCAudioListener.h"

@interface KCAudioRecorder : NSObject <KCAudioListener>

@property (nonatomic, retain) id <KCAudioListener> delegate;

- (id)init;
- (void)dealloc;

@end
