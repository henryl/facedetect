//
//  ORKConcreteFaceDetector.h
//  FaceDetectionPOC
//
//  Created by Mariano Donati on 22/12/14.
//  Copyright (c) 2014 Orka Pod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORKFaceDetector.h"
#import "GPUImage.h"

@interface ORKConcreteFaceDetector : NSObject <ORKFaceDetector>

@property (nonatomic,weak) id<ORKFaceDetectorDelegate> delegate;

/*
 Returns an array of objects implementing the ORKFace protocol detected on the last call to processSampleBuffer
 */
@property (nonatomic,strong) NSArray *detectedFaces;

@property (nonatomic,weak) GPUImageStillCamera *videoCamera;
@property (nonatomic,assign) CGRect boundingBox;

- (id)initWithVideoCamera:(GPUImageStillCamera *)videoCamera;

@end
