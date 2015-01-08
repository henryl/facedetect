//
//  ORKFaceDetectionTool.h
//  Censord
//
//  Created by Mariano Donati on 19/12/14.
//  Copyright (c) 2014 Orka Pod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import "GPUImage.h"

@protocol ORKFaceDetectionToolDelegate;

@interface ORKFaceDetectionTool : NSObject

@property (nonatomic,weak) GPUImageVideoCamera *videoCamera;
@property (nonatomic,weak) id<ORKFaceDetectionToolDelegate> delegate;
@property (nonatomic,assign) CGRect boundingBox;
@property (nonatomic,readonly) NSArray *faces;
@property (nonatomic,assign) BOOL enabled;

- (instancetype)initWithVideoCamera:(GPUImageVideoCamera *)videoCamera;
- (void)processFacesFromSampleBuffer:(CMSampleBufferRef)sample;

@end


@protocol ORKFaceDetectionToolDelegate <NSObject>

- (void)faceDetectionTool:(ORKFaceDetectionTool *)tool didProcessFace:(CIFaceFeature *)feature frame:(CGRect)frame;
- (void)faceDetectionToolDidNotFindFaces:(ORKFaceDetectionTool *)tool;

@end
