//
//  ORKFaceDetector.h
//  FaceDetectionPOC
//
//  Created by Mariano Donati on 22/12/14.
//  Copyright (c) 2014 Orka Pod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@protocol ORKFaceDetectorDelegate;
@protocol ORKFace;

@protocol ORKFaceDetector <NSObject>

@property (nonatomic,weak) id<ORKFaceDetectorDelegate> delegate;

/*
Returns an array of objects implementing the ORKFace protocol detected on the last call to processSampleBuffer
*/
@property (nonatomic,strong) NSArray *detectedFaces;

/**
 Processes a sample buffer and fills in the detected faces array. It should also let the delegate know when it detects a face
 */
- (void)processFacesFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end


@protocol ORKFaceDetectorDelegate

- (void)faceDetector:(id<ORKFaceDetector>)faceDetector didFindFace:(id<ORKFace>)face;
- (void)faceDetectorDidNotFindFaces:(id<ORKFaceDetector>)faceDetector;

@end
