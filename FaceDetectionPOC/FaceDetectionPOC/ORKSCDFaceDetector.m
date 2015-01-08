//
//  ORKSCDFaceDetector.m
//  FaceDetectionPOC
//
//  Created by Henry Liu on 1/6/15.
//  Copyright (c) 2015 Orka Pod. All rights reserved.
//

#import "ORKSCDFaceDetector.h"
#import "ORKConcreteFace.h"
#import "ccv.h"

#define SCALE 0.75

static inline CGImageRef getCGImageRotated(CGImageRef originalCGImage, double radians)
{
    CGSize imageSize = CGSizeMake(CGImageGetWidth(originalCGImage), CGImageGetHeight(originalCGImage));
    CGSize rotatedSize;
    if (radians == M_PI_2 || radians == -M_PI_2) {
        rotatedSize = CGSizeMake(imageSize.height, imageSize.width);
    } else {
        rotatedSize = imageSize;
    }
    
    double rotatedCenterX = rotatedSize.width / 2.f;
    double rotatedCenterY = rotatedSize.height / 2.f;
    
    UIGraphicsBeginImageContextWithOptions(rotatedSize, NO, SCALE);
    CGContextRef rotatedContext = UIGraphicsGetCurrentContext();
    if (radians == 0.f || radians == M_PI) { // 0 or 180 degrees
        CGContextTranslateCTM(rotatedContext, rotatedCenterX, rotatedCenterY);
        if (radians == 0.0f) {
            CGContextScaleCTM(rotatedContext, 1.f, -1.f);
        } else {
            CGContextScaleCTM(rotatedContext, -1.f, 1.f);
        }
        CGContextTranslateCTM(rotatedContext, -rotatedCenterX, -rotatedCenterY);
    } else if (radians == M_PI_2 || radians == -M_PI_2) { // +/- 90 degrees
        CGContextTranslateCTM(rotatedContext, rotatedCenterX, rotatedCenterY);
        CGContextRotateCTM(rotatedContext, radians);
        CGContextScaleCTM(rotatedContext, 1.f, -1.f);
        CGContextTranslateCTM(rotatedContext, -rotatedCenterY, -rotatedCenterX);
    }
    
    
    CGRect drawingRect = CGRectMake(0.f, 0.f, imageSize.width * SCALE, imageSize.height * SCALE);
    CGContextDrawImage(rotatedContext, drawingRect, originalCGImage);
    CGImageRef rotatedCGImage = CGBitmapContextCreateImage(rotatedContext);
    
    UIGraphicsEndImageContext();
    CFAutorelease((CFTypeRef)rotatedCGImage);
    
    return rotatedCGImage;
}

static inline ccv_dense_matrix_t *get_ccv_dense_matrix_t(CGImageRef image)
{
    int width = CGImageGetWidth(image);
    int height = CGImageGetHeight(image);
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(0, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    uint8_t *data = (uint8_t *)CGBitmapContextGetData(context);
    ccv_dense_matrix_t *a = 0;
    
    ccv_read(data, &a, CCV_IO_RGBA_RAW | CCV_IO_GRAY, height, width, width * 4);
    CGContextRelease(context);
    
    return a;
}

@interface ORKSCDFaceDetector()
{
    ccv_scd_classifier_cascade_t *detector;
}

@end

@implementation ORKSCDFaceDetector

- (id)initWithVideoCamera:(GPUImageStillCamera *)videoCamera
{
    self = [super init];
    
    if (self)
    {
        self.videoCamera = videoCamera;
        
        NSString *dbPath = [[NSBundle mainBundle ] pathForResource: @"face" ofType: @"sqlite3"];
        
        detector = ccv_scd_classifier_cascade_read([dbPath UTF8String]);
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
    static BOOL isProcessing = NO;
    
    if(isProcessing) {
        return;
    }
    
    isProcessing = YES;
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    //    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *convertedImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:nil];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    
    CGImageRef cgImage = getCGImageRotated([context createCGImage:convertedImage fromRect:convertedImage.extent], M_PI_2);
    

//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    
//        ccv_dense_matrix_t *ccvImg = 0;
//        int width = CVPixelBufferGetWidth(pixelBuffer);
//        int height = CVPixelBufferGetHeight(pixelBuffer);
//        unsigned char *data = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
//        ccv_read(data, &ccvImg, CCV_IO_RGBA_RAW | CCV_IO_GRAY, height, width, width * 4);
//        
        ccv_dense_matrix_t *ccvImg = get_ccv_dense_matrix_t(cgImage);
        
        ccv_scd_param_t scd_params = {
            .interval = 2,
            .min_neighbors = 3,
            .step_through = (int)(4 * SCALE),
            .size = {
                .width = (int)(44 * SCALE),
                .height = (int)(44 * SCALE),
            },
        };
        
        NSMutableArray *myFaces = [NSMutableArray new];
    
    
    
        ccv_array_t *seq = ccv_scd_detect_objects(ccvImg, &detector, 1, scd_params);
        
        if(seq->rnum) {
            NSLog(@"rnum :%d", seq->rnum);
        }
        
        for (int i = 0; i < seq->rnum; i++)
        {
            ccv_comp_t* comp = (ccv_comp_t*)ccv_array_get(seq, i);
            ORKConcreteFace *orkface = [ORKConcreteFace new];
//            orkface.boundingBox = CGRectMake((CGFloat)(comp->rect.height - comp->rect.y), (CGFloat)(comp->rect.x), (CGFloat)comp->rect.height, (CGFloat)comp->rect.width);
            orkface.boundingBox = CGRectMake((CGFloat)(comp->rect.width - comp->rect.x) / SCALE, (CGFloat)(comp->rect.y) / SCALE, (CGFloat)comp->rect.width  / SCALE, (CGFloat)comp->rect.height / SCALE);
            [myFaces addObject:orkface];
        }
    
        ccv_array_free(seq);
    
        ccv_matrix_free(ccvImg);
    
        
        self.detectedFaces = myFaces;
        
//        dispatch_async(dispatch_get_main_queue(), ^{
            if(self.detectedFaces.count == 0) {
                [self.delegate faceDetectorDidNotFindFaces:self];
            } else {
                NSLog(@"detected: %d faces", self.detectedFaces.count);
                for(ORKConcreteFace *face in self.detectedFaces) {
                    [self.delegate faceDetector:self didFindFace:face];
                }
            }
//        });
        isProcessing = NO;
//    });
    

    
}


@end
