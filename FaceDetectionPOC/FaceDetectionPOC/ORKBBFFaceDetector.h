//
//  ORKBBFFaceDetector.h
//  FaceDetectionPOC
//
//  Created by Henry Liu on 1/7/15.
//  Copyright (c) 2015 Orka Pod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORKFaceDetector.h"
#import "GPUImage.h"

@interface ORKBBFFaceDetector : NSObject<ORKFaceDetector>
@property (nonatomic,weak) id<ORKFaceDetectorDelegate> delegate;

/*
 Returns an array of objects implementing the ORKFace protocol detected on the last call to processSampleBuffer
 */
@property (nonatomic,strong) NSArray *detectedFaces;

@property (nonatomic,weak) GPUImageStillCamera *videoCamera;
@property (nonatomic,assign) CGRect boundingBox;

- (id)initWithVideoCamera:(GPUImageStillCamera *)videoCamera;

@end
