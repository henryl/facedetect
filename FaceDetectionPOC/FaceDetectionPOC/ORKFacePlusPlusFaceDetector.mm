//
//  ORKFacePlusPlusFaceDetetor.m
//  FaceDetectionPOC
//
//  Created by Henry Liu on 1/6/15.
//  Copyright (c) 2015 Orka Pod. All rights reserved.
//

#import "ORKFacePlusPlusFaceDetector.h"
#import "FaceppLocalDetector.h"

#import "ORKConcreteFace.h"

@interface ORKFacePlusPlusFaceDetector() {
    
}

@property (nonatomic,strong) FaceppLocalDetector *detector;

@end

@implementation ORKFacePlusPlusFaceDetector

- (id)initWithVideoCamera:(GPUImageStillCamera *)videoCamera
{
    self = [super init];
    
    if (self)
    {
        self.detector = [FaceppLocalDetector detectorOfOptions:@{
                                                                 FaceppDetectorMinFaceSize: @30,
                                                                 FaceppDetectorAccuracy: FaceppDetectorAccuracyHigh,
                                                                 } andAPIKey:@"aeb6018c0b3e8ebba1cd5e5396ff7498"];
        self.videoCamera = videoCamera;
    }
    
    return self;
}

- (UIImage*)rotateUIImage:(UIImage*)sourceImage clockwise:(BOOL)clockwise
{
    CGSize size = sourceImage.size;
    UIGraphicsBeginImageContext(CGSizeMake(size.height, size.width));
    [[UIImage imageWithCGImage:[sourceImage CGImage] scale:1.0 orientation:clockwise ? UIImageOrientationRight : UIImageOrientationLeft] drawInRect:CGRectMake(0,0,size.height ,size.width)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (void)processFacesFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:nil];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    UIImage *uiImage = [UIImage imageWithCGImage:[context createCGImage:convertedImage fromRect:convertedImage.extent]];
//    uiImage = [self rotateUIImage:uiImage clockwise:NO];
    FaceppLocalResult *faceppResult = [self.detector detectWithImage:uiImage];

    
    NSMutableArray *myFaces = [NSMutableArray new];
    
    
    
    for(FaceppLocalFace *ppface in faceppResult.faces) {
        ORKConcreteFace *orkface = [ORKConcreteFace new];
        
//        CGRectMake(ppface.bounds.origin.y, ppface.bounds.origin.x, ppface.bounds.size.height, ppface.bounds.size.width)
//        orkface.boundingBox = ppface.bounds;
        orkface.boundingBox = CGRectMake(ppface.bounds.origin.y, ppface.bounds.origin.x, ppface.bounds.size.height, ppface.bounds.size.width);
        
        [myFaces addObject:orkface];
    }
    
    self.detectedFaces = myFaces;
    
    if(self.detectedFaces.count == 0) {
        [self.delegate faceDetectorDidNotFindFaces:self];
    } else {
        for(ORKConcreteFace *face in self.detectedFaces) {
            [self.delegate faceDetector:self didFindFace:face];
        }
    }
    
}

@end
