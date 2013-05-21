//
//  KamcordRecorder.h
//

#import <OpenGLES/EAGL.h>
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

// If you want cropping
+ (BOOL)createFramebuffers:(GLuint)defaultFramebuffer
                boundaries:(CGRect)boundaries;

+ (BOOL)createFramebuffers:(GLuint)defaultFramebuffer
           msaaFramebuffer:(GLuint)msaaFramebuffer
                boundaries:(CGRect)boundaries;

// Call whenever framebuffers need to get deleted and recreated
+ (void)deleteFramebuffers;


// Call before [context presentRenderbuffer:GL_RENDERBUFFER]
// Pass the opengl framebuffer to which the renderbuffer you are presenting
// is attached.  Returns NO on failure or if Kamcord is disabled.
+ (BOOL)beforePresentRenderbuffer:(GLuint)framebuffer;

// Call after [context presentRenderbuffer:GL_RENDERBUFFER]
+ (BOOL)afterPresentRenderbuffer;

// DEPRECATED
+ (BOOL)afterPresentRenderBuffer:(GLuint)framebuffer;

// Call to capture a frame of video before the call to beforePresentRenderbuffer
// For instance if the game has a HUD, call captureFrame before drawing the HUD;
// the HUD will not appear in the final video.
+ (BOOL)captureFrame;

+ (GLuint)kamcordFramebuffer;

/*!
 *
 * Set the target video FPS. The default value is 30 FPS.
 *
 * Valid values are 30 or 60. Only newer devices can typically handle 60 FPS.
 *
 */
+ (void)setTargetVideoFPS:(NSUInteger)fps;
+ (NSUInteger)targetVideoFPS;

@end
