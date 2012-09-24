//
//  KCVideoProcessor.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 6/1/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KCVideoProcessingAndShareManager.h"

@interface KCVideoProcessor : NSObject

// Weak reference since the task itself
// retains this object, so don't want a retain cycle.
@property (nonatomic, assign) KCVideoProcessingTask * task;
@property (nonatomic, retain) KCVideoProcessingAndShareManager * delegate;

- (id) initWithTask:(KCVideoProcessingTask *)task
           delegate:(KCVideoProcessingAndShareManager *)delegate;
- (BOOL) doTask;
- (void) cancel;
- (void) cancelAndRetry;
- (void) dealloc;

@end
