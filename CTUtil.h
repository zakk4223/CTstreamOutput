#import <Cocoa/Cocoa.h>

#ifndef CTClass
#define CTClass(x) x
#endif

@interface CTClass(CTUtil) : NSObject
{
}

+ (CGImageRef) loadImage:(NSString *) path;
+ (CGImageRef) loadPNGImage:(NSString *) path;

// Create an xRGB offscreen bitmap
+ (CGContextRef) CreateBitmapContextWithData:(void *) bitmapData
								  pixelsWide:(int) pixelsWide
								  pixelsHigh:(int) pixelsHigh;

// NOTE: You must free the bytes as well as releasing the context!
// Create an xRGB offscreen bitmap
+ (CGContextRef) CreateBitmapContextPixelsWide:(int) pixelsWide
								    pixelsHigh:(int) pixelsHigh;

+ (CGRect) fitRect:(CGSize) imageSize
	   inContainer:(CGSize) container;

+ (CIImage *) coreImageFromNSImage:(NSImage *) xx;

@end
