//
//  KamcordRecorder.h
//  cocos2d-ios
//
//  Created by Kevin Wang on 2/27/13.
//
//

#import <Foundation/Foundation.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>

@interface KamcordRecorder : NSObject

// OpenGL setup. Should be called once before any OpenGL rendering
// is done.
+ (BOOL)initWithEAGLContext:(EAGLContext *)context
                      layer:(CAEAGLLayer *)layer;

// If you don't use MSAA
+ (BOOL)createFramebuffers:(GLuint)defaultFramebuffer;

// If you use MSAA
+ (BOOL)createFramebuffers:(GLuint)defaultFramebuffer
           msaaFramebuffer:(GLuint)msaaFramebuffer;

// Call whenever framebuffers need to get deleted and recreated
+ (void)deleteFramebuffers;

// OpenGL rendering loop
// Call these before and after you call
// [context presentRenderbuffer:GL_RENDERBUFFER].
+ (BOOL)beforePresentRenderbuffer:(GLuint)framebuffer;
+ (BOOL)afterPresentRenderBuffer:(GLuint)framebuffer;

@end
