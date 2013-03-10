//
//  streamOutput.h
//  streamOutput
//
//  Created by Zakk on 3/5/13.
//  Copyright (c) 2013 Zakk. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CTEffect.h"
#import "FFMpegTask.h"
#import <VideoToolbox/VideoToolbox.h>
#import <AVFoundation/AVFoundation.h>




void VideoCompressorReceiveFrame(void *, void *, OSStatus , VTEncodeInfoFlags , CMSampleBufferRef );



@interface streamOutput : CTEffect <AVCaptureAudioDataOutputSampleBufferDelegate>
{
    VTCompressionSessionRef _compression_session;
    AVCaptureSession *_audio_session;
    dispatch_queue_t _audio_capture_queue;
    
    AVCaptureAudioDataOutput *_audio_capture_output;
    
    
    
    
}

@property (assign) int captureHeight;
@property (assign) int captureWidth;
@property (assign) int captureVideoMaxKeyframeInterval;
@property (assign) int captureVideoMaxBitrate;
@property (assign) int captureVideoAverageBitrate;
@property (assign) int videoCaptureFPS;
@property (strong) FFMpegTask *streamDestination;
@property (strong) NSViewController *viewController;
@property (strong) NSString *destinationValue;
@property (assign) BOOL connected;
@property (assign) BOOL startEnabled;
@property (strong) AVCaptureDevice *selectedAudioCapture;
@property (weak) NSArray *audioCaptureDevices;
@property (assign) int audioBitrate;





@end
