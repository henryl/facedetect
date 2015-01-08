//
//  ORKFace.h
//  FaceDetectionPOC
//
//  Created by Mariano Donati on 22/12/14.
//  Copyright (c) 2014 Orka Pod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@protocol ORKFace <NSObject>

/**
 The bounding box of the face expressed in view coordinates. Our concrete implementation transforms from texture coordinates to view coordinates inside the concrete implementation of the face detector. Note that in order to do that, you face detector will probably need a bounding box property representing the viewport.
 */
@property (nonatomic,assign) CGRect boundingBox;

@end
