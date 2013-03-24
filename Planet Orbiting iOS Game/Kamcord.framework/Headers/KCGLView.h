//
//  KCGLView.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 5/28/12.
//  Copyright (c) 2012 Kamcord Inc. All rights reserved.
//

#import "CCGLView.h"

@class KCVideoWriter;

@interface KCGLView : CCGLView

// Initializers
+ (id) viewWithFrame:(CGRect)frame;
- (id) initWithFrame:(CGRect)frame;

- (id) initWithFrame:(CGRect)frame 
         pixelFormat:(NSString*)format
         depthFormat:(GLuint)depth
  preserveBackbuffer:(BOOL)retained 
          sharegroup:(EAGLSharegroup*)sharegroup
       multiSampling:(BOOL)sampling
     numberOfSamples:(unsigned int)nSamples;

- (id) initWithCoder:(NSCoder *)aDecoder;

// The rendering function
- (void) swapBuffers;

@end
