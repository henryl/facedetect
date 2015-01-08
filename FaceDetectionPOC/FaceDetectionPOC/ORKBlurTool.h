//
//  ORKBlurTool.h
//  Censord
//
//  Created by Mariano Donati on 18/12/14.
//  Copyright (c) 2014 Orka Pod. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImage.h"

@class GPUImageView;
@class GPUImagePixellatePositionFilter;
@class GPUImageFilterPipeline;
@protocol GPUImageInput;

@interface ORKBlurTool : NSObject

@property (nonatomic,assign) CGRect boundingBox;
@property (nonatomic,assign) float blurRadius;
@property (nonatomic,assign) float pixelWidth;

- (id)initWithPipeline:(GPUImageFilterPipeline *)pipeline;
- (void)pixelateAtCenter:(CGPoint)center groupId:(NSString *)groupId;
- (void)pixelateAtCenter:(CGPoint)center index:(NSUInteger)index groupId:(NSString *)groupId;
- (void)pixelateAtCenter:(CGPoint)center radius:(CGFloat)radius index:(NSUInteger)index groupId:(NSString *)groupId;
- (void)removeAllFiltersForGroup:(NSString *)groupId;

@end
