//
//  streamOutput.m
//  streamOutput
//
//  Created by Zakk on 3/5/13.
//  Copyright (c) 2013 Zakk. All rights reserved.
//

#import "streamOutput.h"



@implementation streamOutput



+ (NSString *) name
{
	return @"streamOutput";
}


- (void) connectDestination
{
    
    
    if (!self.destinationValue || self.captureHeight == 0 ||
        self.captureWidth == 0 || self.videoCaptureFPS == 0 ||
        self.captureVideoAverageBitrate == 0
        )
    {
        self.connected = NO;
    }
    
    
    self.streamDestination = [[FFMpegTask alloc] init];
    self.streamDestination.height = self.captureHeight;
    self.streamDestination.width = self.captureWidth;
    self.streamDestination.framerate = self.videoCaptureFPS;
    self.streamDestination.stream_output = self.destinationValue;
    self.streamDestination.samplerate = 44100;
    
    
    [self setupAudioCapture];
    [self setupCompression];

}


-(void) selectedAudioCaptureFromID:(NSString *)uniqueID
{
    self.selectedAudioCapture = [AVCaptureDevice deviceWithUniqueID:uniqueID];
}



- (void) initStreamer
{
    
    self.startEnabled = YES;
    
    
    self.viewController = [[NSViewController alloc] initWithNibName:@"streamOutput"
														bundle:[NSBundle bundleForClass:[streamOutput class]]];
    
    [self.viewController setRepresentedObject:self];
    
    
    if (self.captureHeight == 0)
        self.captureHeight = [[self context] size].height;
    
    if (self.captureWidth == 0)
        self.captureWidth = [[self context] size].width;
    
    if (self.audioBitrate == 0)
        self.audioBitrate = 128;
        
    
    self.audioCaptureDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio];
    
    
    
}



- (NSView *) inspectorView
{
    
	return [self.viewController view];
}

- (id) initWithContext:(CTContext *) ctContext
{

    self = [super initWithContext:ctContext];
    [self initStreamer];
    return self;
}


- (id) initWithCoder:(NSCoder *) coder
{
    self = [super initWithCoder:coder];
    
    self.captureHeight = [coder decodeIntForKey:@"height"];
    self.captureWidth = [coder decodeIntForKey:@"width"];
    self.captureVideoAverageBitrate = [coder decodeIntForKey:@"avgbitrate"];
    self.captureVideoMaxKeyframeInterval = [coder decodeIntForKey:@"keyframe"];
    self.captureVideoMaxBitrate = [coder decodeIntForKey:@"maxbitrate"];
    self.videoCaptureFPS = [coder decodeIntForKey:@"videoFPS"];
    self.destinationValue = [coder decodeObjectForKey:@"destination"];
    
    NSString *audioID = [coder decodeObjectForKey:@"audioCaptureID"];
    
    [self selectedAudioCaptureFromID:audioID];
    
    self.audioBitrate = [coder decodeIntForKey:@"audioBitrate"];
    
    
    
    [self initStreamer];
    return self;
}


- (void) encodeWithCoder:(NSCoder *) coder
{
	[super encodeWithCoder:coder];
	
    [coder encodeInt:self.captureHeight forKey:@"height"];
    [coder encodeInt:self.captureWidth forKey:@"width"];
    [coder encodeInt:self.captureVideoAverageBitrate forKey:@"avgbitrate"];
    [coder encodeInt:self.captureVideoMaxKeyframeInterval forKey:@"keyframe"];
    [coder encodeInt:self.captureVideoMaxBitrate forKey:@"maxbitrate"];
    [coder encodeInt:self.videoCaptureFPS forKey:@"videoFPS"];
    [coder encodeObject:self.destinationValue forKey:@"destination"];
    if (self.selectedAudioCapture)
    {
        [coder encodeObject:self.selectedAudioCapture.uniqueID forKey:@"audioCaptureID"];
    }
    
    [coder encodeInt:self.audioBitrate forKey:@"audioBitrate"];
     
     
    
}


void PixelBufferRelease( void *releaseRefCon, const void *baseAddress )
{
    free((int *)baseAddress);
}



- (void) doit
{
    
    
    
    if (self.connected == NO)
    {
        if (self.streamDestination)
        {
            [self.streamDestination stopProcess];
            [_audio_session stopRunning];
        }
        
        self.streamDestination = nil;
        return;
    } else if (self.connected == YES) {
        if (!self.streamDestination)
        {
            [self connectDestination];
        }
    }
    
    
    
    
    CVImageBufferRef newbuf = NULL;
    
    
    
    int *pdata = malloc(self.captureWidth * self.captureHeight * 4);
    
    [[self context] fetchOpenGLPixels:pdata rowBytes:self.captureWidth * 4];
    
    
    CVPixelBufferCreateWithBytes(NULL, self.captureWidth, self.captureHeight,
                                 kCVPixelFormatType_32ARGB,pdata, self.captureWidth * 4, PixelBufferRelease, NULL, NULL, &newbuf);
    
    
    
    
    
    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    
    CMTime pts = CMTimeMake(currentTime*1000, 1000);
    
    CMTime duration = CMTimeMake(1, self.videoCaptureFPS);
    
    
    VTCompressionSessionEncodeFrame(_compression_session, newbuf, pts, duration, NULL, newbuf, NULL);
}



- (bool)setupAudioCapture
{
    if (!_audio_session)
    {
        _audio_session = [[AVCaptureSession alloc] init];
        
    }
    
    if (_audio_session && self.selectedAudioCapture)
    {
        AVCaptureDeviceInput *audio_capture_input = [AVCaptureDeviceInput deviceInputWithDevice:self.selectedAudioCapture error:nil];
        
        if ([_audio_session canAddInput:audio_capture_input])
        {
            [_audio_session addInput:audio_capture_input];
        } else {
            return NO;
        }
        
        _audio_capture_output = [[AVCaptureAudioDataOutput alloc] init];
        _audio_capture_output.audioSettings = @{AVFormatIDKey: [NSNumber numberWithInt:kAudioFormatMPEG4AAC],
    AVSampleRateKey: [NSNumber numberWithFloat:44100.0],
    AVEncoderBitRateKey: [NSNumber numberWithInt:self.audioBitrate*1000],
    AVNumberOfChannelsKey: @2 };
        
        if ([_audio_session canAddOutput:_audio_capture_output])
        {
            [_audio_session addOutput:_audio_capture_output];
        } else {
            return NO;
        }
        
    } else {
        return NO;
    }
    
    _audio_capture_queue = dispatch_queue_create("CamTwist ffmpeg audio queue", NULL);
    [_audio_capture_output setSampleBufferDelegate:self queue:_audio_capture_queue];
    [_audio_session startRunning];
    
    return YES;
}


- (bool)setupCompression
{
    OSStatus status;
    NSDictionary *encoder_spec = @{@"EnableHardwareAcceleratedVideoEncoder": @1};
    
    
    if (!self.captureHeight || !self.captureHeight)
    {
        return NO;
        
    }
    
    status = VTCompressionSessionCreate(NULL, self.captureWidth, self.captureHeight, 'avc1', (__bridge CFDictionaryRef)encoder_spec, NULL, NULL, VideoCompressorReceiveFrame,  (__bridge void *)self, &_compression_session);
    
    //If priority isn't set to -20 the framerate in the SPS/VUI section locks to 25. With -20 it takes on the value of
    //whatever ExpectedFrameRate is. I have no idea what the fuck, but it works.
    
    VTSessionSetProperty(_compression_session, (CFStringRef)@"Priority", (__bridge CFTypeRef)(@-20));
    VTSessionSetProperty(_compression_session, kVTCompressionPropertyKey_AllowFrameReordering, kCFBooleanFalse);
    
    
    if (self.captureVideoMaxKeyframeInterval && self.captureVideoMaxKeyframeInterval > 0)
    {
        VTSessionSetProperty(_compression_session, kVTCompressionPropertyKey_MaxKeyFrameInterval, (__bridge CFTypeRef)(@(self.captureVideoMaxKeyframeInterval)));
    }
    
    if (self.captureVideoMaxBitrate && self.captureVideoMaxBitrate > 0)
    {
        
        int real_bitrate = self.captureVideoMaxBitrate*128; // In bytes (1024/8)
        VTSessionSetProperty(_compression_session, kVTCompressionPropertyKey_DataRateLimits, (__bridge CFTypeRef)(@[@(real_bitrate), @1.0]));
        
    }
    
    
    if (self.captureVideoAverageBitrate > 0)
    {
        int real_bitrate = self.captureVideoAverageBitrate*1024;
        
        NSLog(@"Setting bitrate to %d", real_bitrate);
        
        VTSessionSetProperty(_compression_session, kVTCompressionPropertyKey_AverageBitRate, CFNumberCreate(NULL, kCFNumberIntType, &real_bitrate));
        
    }
    
    if (self.videoCaptureFPS && self.videoCaptureFPS > 0)
    {
        
        VTSessionSetProperty(_compression_session, kVTCompressionPropertyKey_ExpectedFrameRate, (__bridge CFTypeRef)(@(self.videoCaptureFPS)));
        
    }
    
    return YES;
    
}


void VideoCompressorReceiveFrame(void *VTref, void *VTFrameRef, OSStatus status, VTEncodeInfoFlags infoFlags, CMSampleBufferRef sampleBuffer)
{
    if (VTFrameRef)
    {
        CVPixelBufferRelease(VTFrameRef);
    }
    
    @autoreleasepool {
        
        
        
        if(!sampleBuffer)
            return;
        
        
        
        CFRetain(sampleBuffer);
        
        streamOutput *selfobj = (__bridge streamOutput *)VTref;
        
        
        [selfobj.streamDestination writeVideoSampleBuffer:sampleBuffer];
        
        CFRelease(sampleBuffer);
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{

    CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
    CMTime pts = CMTimeMake(currentTime*1000, 1000);
    CMSampleBufferSetOutputPresentationTimeStamp(sampleBuffer, pts);
    [self.streamDestination writeAudioSampleBuffer:sampleBuffer presentationTimeStamp:pts];

}


@end
