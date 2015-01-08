//
//  ORKBlurTool.m
//  Censord
//
//  Created by Mariano Donati on 18/12/14.
//  Copyright (c) 2014 Orka Pod. All rights reserved.
//

#import "ORKBlurTool.h"
#import "GPUImage.h"

@interface ORKBlurTool ()

@property (nonatomic,strong) GPUImageFilterPipeline *pipeline;
@property (nonatomic,strong) NSMutableDictionary *pixelateFilters;

@end

@implementation ORKBlurTool

- (id)initWithPipeline:(GPUImageFilterPipeline *)pipeline
{
    self = [super init];
    
    if (self)
    {
        self.pipeline = pipeline;
        self.pixelateFilters = [NSMutableDictionary new];
        self.pixelWidth = 0.075f;
        self.blurRadius = 50.;
    }
    
    return self;
}

- (void)pixelateAtCenter:(CGPoint)center groupId:(NSString *)groupId
{
    [self pixelateAtCenter:center index:0 groupId:groupId];
}

- (void)pixelateAtCenter:(CGPoint)center index:(NSUInteger)index groupId:(NSString *)groupId
{
    CGPoint actualCenter = CGPointMake(center.x - self.blurRadius / 2, center.y - self.blurRadius / 2);
    [self pixelateAtCenter:actualCenter radius:self.blurRadius index:index groupId:groupId];
}

- (void)pixelateAtCenter:(CGPoint)center radius:(CGFloat)radius index:(NSUInteger)index groupId:(NSString *)groupId
{
    GPUImagePixellatePositionFilter *filter = [self filterForIndex:index groupId:groupId];
    filter.radius = [self normalizeRadius:radius];
    filter.center = [self normalizePoint:center];
}

- (GPUImagePixellatePositionFilter *)filterForIndex:(NSInteger)index groupId:(NSString *)groupId
{
    NSMutableArray *pixelateFilters = [self.pixelateFilters objectForKey:groupId];
    
    if (pixelateFilters == nil)
    {
        pixelateFilters = [NSMutableArray new];
        [self.pixelateFilters setObject:pixelateFilters forKey:groupId];
    }
    
    if (index > (NSInteger)pixelateFilters.count - 1)
    {
        GPUImagePixellatePositionFilter *filter = [GPUImagePixellatePositionFilter new];
        filter.fractionalWidthOfAPixel = self.pixelWidth;
        [pixelateFilters addObject:filter];
        [self.pixelateFilters setObject:pixelateFilters forKey:groupId];
        [self.pipeline addFilter:filter];
    }
    
    return [pixelateFilters objectAtIndex:index];
}

- (void)removeAllFiltersForGroup:(NSString *)groupId
{
    NSMutableArray *filters = [self.pixelateFilters objectForKey:groupId];
    if (filters)
    {
        for (GPUImagePixellatePositionFilter *filter in [filters copy])
        {
            [self.pipeline removeFilter:filter];
            [filters removeObject:filter];
        }
    }
}

- (CGPoint)normalizePoint:(CGPoint)point
{
    return CGPointMake(point.x / self.boundingBox.size.width, point.y / self.boundingBox.size.height);
}

- (float)normalizeRadius:(float)radius
{
    return radius / self.boundingBox.size.width;
}

@end
