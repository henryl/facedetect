//
//  ORKConcreteFace.h
//  FaceDetectionPOC
//
//  Created by Mariano Donati on 22/12/14.
//  Copyright (c) 2014 Orka Pod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ORKFace.h"

@interface ORKConcreteFace : NSObject <ORKFace>

@property (nonatomic,assign) CGRect boundingBox;

@end
