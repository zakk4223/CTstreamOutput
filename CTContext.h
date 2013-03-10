#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

//////////////////////////////////////////////////////////////////////////
//
// NOTE:  This is a work in progress.  Expect this interface to change.
//
//////////////////////////////////////////////////////////////////////////

@class CTOffscreenContext;
@class SimpleQCRenderer;

@interface CTContext : NSObject 
{
	CGSize size;
	NSOpenGLContext *oglCtx;
	NSOpenGLPixelFormat *oglFmt;
	CVOpenGLBufferRef oglPBuff;

	CIContext *ciCtx;

	SimpleQCRenderer	*renderer;

	double				frameTime;
}

+ (void) clearContext:(NSOpenGLContext *) oglCtx
				toRed:(GLfloat)	red
				green:(GLfloat) green
				 blue:(GLfloat) blue
				alpha:(GLfloat) alpha;

+ (void) drawPBuffer:(CVOpenGLBufferRef) theBuffer
		   toContext:(NSOpenGLContext *) otherContext
			 flipped:(BOOL) flipped
			mirrored:(BOOL) mirrored;

+ (void) drawCVTexture:(CVOpenGLTextureRef) texture
			 toContext:(NSOpenGLContext *) otherContext
			   flipped:(BOOL) flipped
			  mirrored:(BOOL) mirrored;

+ (void) drawTexture:(GLuint) tname
			fromRect:(CGRect) fromRect
		   toContext:(NSOpenGLContext *) otherContext
			  inRect:(CGRect) inRect
			 flipped:(BOOL) flipped
			mirrored:(BOOL) mirrored;

- (void) setFrameTime:(double) time;
- (double) frameTime;

// Reset back to a known state
- (void) reset:(BOOL) clearAlpha;

- (CGSize) size;

- (CGColorSpaceRef) colorSpace;

- (NSOpenGLContext *) oglCtx;
- (NSOpenGLPixelFormat *) oglFmt;
- (CVOpenGLBufferRef) oglPBuff;
- (CIContext *) ciCtx;

- (CVOpenGLTextureRef) texture;	// You must release

- (void) setQCRenderer:(SimpleQCRenderer *) rend;
- (SimpleQCRenderer *) qcRenderer;

- (void) drawTexture:(GLuint) texture
			  inRect:(CGRect) inRect
			fromRect:(CGRect) fromRect;

- (void) renderToContext:(NSOpenGLContext *) otherContext;

- (void) flush;

- (void) fetchOpenGLPixels:(void *) data
				  rowBytes:(GLint) rowBytes;

@end
