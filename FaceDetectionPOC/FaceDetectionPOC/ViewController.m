//
//  ViewController.m
//  FaceDetectionPOC
//
//  Created by Mariano Donati on 22/12/14.
//  Copyright (c) 2014 Orka Pod. All rights reserved.
//

#import "ViewController.h"
#import "FrameRateCalculator.h"
#import "GPUImage.h"
#import "ORKBlurTool.h"
#import "ORKFaceDetector.h"
#import "ORKFace.h"
#import "ORKConcreteFaceDetector.h"
#import "ORKFacePlusPlusFaceDetector.h"
#import "ORKSCDFaceDetector.h"
#import "ORKBBFFaceDetector.h"


@interface ViewController () <GPUImageVideoCameraDelegate, ORKFaceDetectorDelegate>

@property (nonatomic,strong) GPUImageView *cameraView;
@property (nonatomic,strong) GPUImageStillCamera *videoCamera;
@property (nonatomic,strong) GPUImageFilterPipeline *filterPipeline;
@property (nonatomic,strong) ORKBlurTool *blurTool;
@property (nonatomic,strong) FrameRateCalculator *frameRateCalculator;
@property (nonatomic,strong) UILabel *fpsLabel;
@property (nonatomic,strong) id<ORKFaceDetector> faceDetector;


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupCamera];
    UILabel *label = [UILabel new];
    label.frame = CGRectMake(0, 66, 100, 20);
    label.text = @"";
    label.textColor = [UIColor redColor];
    label.backgroundColor = [UIColor whiteColor];
    
    self.fpsLabel = label;
    [self.view addSubview:self.fpsLabel];
    
    _frameRateCalculator = [[FrameRateCalculator alloc] init];
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateLabel) userInfo:nil repeats:YES];
}
     
- (void)updateLabel
{
    self.fpsLabel.text = [NSString stringWithFormat:@"%.1f fps", _frameRateCalculator.frameRate];
}

- (void)setupCamera
{
    
    self.cameraView = [[GPUImageView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:self.cameraView];
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
//        AVCaptureDevicePosition position = ([GPUImageVideoCamera isFrontFacingCameraPresent]) ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
        
        AVCaptureDevicePosition position = AVCaptureDevicePositionFront;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.videoCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetMedium cameraPosition:position];
            
            [self.videoCamera setOutputImageOrientation:UIInterfaceOrientationPortrait];
            [self.videoCamera setDelegate:self];
            self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
            
            self.filterPipeline = [[GPUImageFilterPipeline alloc] initWithOrderedFilters:@[[GPUImageFilter new]] input:self.videoCamera output:self.cameraView];
            
            self.blurTool = [[ORKBlurTool alloc] initWithPipeline:self.filterPipeline];
            self.blurTool.boundingBox = self.view.bounds;
            
            [self createFaceDetector];

            [self.videoCamera startCameraCapture];
        });
    }];
}

- (void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    static BOOL didStart = NO;
    
    if(!didStart) {
        didStart = YES;
        [_frameRateCalculator reset];
    }
    
    CMTime timestamp = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    
    [self.faceDetector processFacesFromSampleBuffer:sampleBuffer];
    [_frameRateCalculator calculateFramerateAtTimestamp:CMClockGetTime(CMClockGetHostTimeClock())];
}

- (void)faceDetector:(id<ORKFaceDetector>)faceDetector didFindFace:(id<ORKFace>)face
{
    
    NSLog(@"Found face!");
    NSInteger indexOfFace = [faceDetector.detectedFaces indexOfObject:face];
    CGRect frame = face.boundingBox;
    [self.blurTool pixelateAtCenter:CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame)) radius:MAX(CGRectGetWidth(frame), CGRectGetHeight(frame)) / 2 * 1.2 index:indexOfFace groupId:@"faces"];
}

- (void)faceDetectorDidNotFindFaces:(id<ORKFaceDetector>)faceDetector
{
    [self.blurTool removeAllFiltersForGroup:@"faces"];
}

- (void)createFaceDetector
{
//    ORKConcreteFaceDetector *faceDetector = [[ORKConcreteFaceDetector alloc] initWithVideoCamera:self.videoCamera];
//    faceDetector.boundingBox = self.view.bounds;
    
//    ORKOpenCVFaceDetector *faceDetector = [[ORKOpenCVFaceDetector alloc] initWithVideoCamera:self.videoCamera];
    
//    ORKFacePlusPlusFaceDetector *faceDetector = [[ORKFacePlusPlusFaceDetector alloc] initWithVideoCamera:self.videoCamera];
    
    ORKSCDFaceDetector *faceDetector = [[ORKSCDFaceDetector alloc] initWithVideoCamera:self.videoCamera];
//    ORKBBFFaceDetector *faceDetector = [[ORKBBFFaceDetector alloc] initWithVideoCamera:self.videoCamera];
    faceDetector.delegate = self;
    self.faceDetector = faceDetector;
    
    
    //@TODO: Initialize an instance of your own face detector
    //@TODO: Set this view controller as its delegate
}

@end
