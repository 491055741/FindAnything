//
//  QuadTreeNode.m
//  FindAnything
//
//  Created by LiPeng on 13-12-27.
//  Copyright (c) 2013年 LiPeng. All rights reserved.
//

//self.northWestPosition = CLLocationCoordinate2DMake(90, -180);
//self.southEastPosition = CLLocationCoordinate2DMake(-90, 180);


#import "QuadTreeNode.h"

@implementation POI

- (NSString *)title
{
    return self.name;
}

- (NSString *)subtitle
{
    return self.address;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.location.coordinate;
}

- (MKMapPoint)mapPoint
{
    MKMapPoint point = MKMapPointForCoordinate(self.location.coordinate);
    return point;
}
@end

@implementation QuadTreeNode

- (id)init
{
    if ([super init]) {
        CLLocationCoordinate2D coordinate = {-90, 180};
        MKMapPoint point = MKMapPointForCoordinate(coordinate);
        self.bounds = MKMapRectMake(0, 0, point.x, point.y);
        self.poiArray = [NSMutableArray arrayWithCapacity:kBucketCapacity];
    }
    return self;
}

- (void)subdivide
{
    double width = MKMapRectGetWidth(_bounds)/2;
    double height = MKMapRectGetHeight(_bounds)/2;
    // left up
    self.northWestNode = [[QuadTreeNode alloc] init];
    _northWestNode.bounds = MKMapRectMake(MKMapRectGetMinX(_bounds),
                                          MKMapRectGetMinY(_bounds),
                                          width,
                                          height);

    // right up
    self.northEastNode = [[QuadTreeNode alloc] init];
    _northEastNode.bounds = MKMapRectMake(MKMapRectGetMidX(_bounds),
                                          MKMapRectGetMinY(_bounds),
                                          width,
                                          height);
   
    // left down
    self.southWestNode = [[QuadTreeNode alloc] init];
    _southWestNode.bounds = MKMapRectMake(MKMapRectGetMinX(_bounds),
                                          MKMapRectGetMidY(_bounds),
                                          width,
                                          height);
    
    // right down
    self.southEastNode = [[QuadTreeNode alloc] init];
    _southWestNode.bounds = MKMapRectMake(MKMapRectGetMidX(_bounds),
                                          MKMapRectGetMidY(_bounds),
                                          width,
                                          height);

}
/*
- (void)dump
{
    if (self.northEastNode == nil) {
        [self split];
    }

//    NSLog(@"%s [%.2f,%.2f-%.2f,%.2f] [%.2f,%.2f-%.2f,%.2f] [%.2f,%.2f-%.2f,%.2f] [%.2f,%.2f-%.2f,%.2f] [%.2f,%.2f-%.2f,%.2f]", __func__,
//          self.boundingBox.northWestPosition.latitude,
//          self.boundingBox.northWestPosition.longitude,
//          self.boundingBox.southEastPosition.latitude,
//          self.boundingBox.southEastPosition.longitude,
//
//          self.northWestNode.boundingBox.northWestPosition.latitude,
//          self.northWestNode.boundingBox.northWestPosition.longitude,
//          self.northWestNode.boundingBox.southEastPosition.latitude,
//          self.northWestNode.boundingBox.southEastPosition.longitude,
//
//          self.northEastNode.boundingBox.northWestPosition.latitude,
//          self.northEastNode.boundingBox.northWestPosition.longitude,
//          self.northEastNode.boundingBox.southEastPosition.latitude,
//          self.northEastNode.boundingBox.southEastPosition.longitude,
//          
//          self.southWestNode.boundingBox.northWestPosition.latitude,
//          self.southWestNode.boundingBox.northWestPosition.longitude,
//          self.southWestNode.boundingBox.southEastPosition.latitude,
//          self.southWestNode.boundingBox.southEastPosition.longitude,
//
//          self.southEastNode.boundingBox.northWestPosition.latitude,
//          self.southEastNode.boundingBox.northWestPosition.longitude,
//          self.southEastNode.boundingBox.southEastPosition.latitude,
//          self.southEastNode.boundingBox.southEastPosition.longitude
//          );
}
*/
- (BOOL)addData:(POI *)poi
{
    MKMapPoint point = [poi mapPoint];
    if (!MKMapRectContainsPoint(_bounds, point)) {
        return NO;
    }
    
    if ([_poiArray count] < 4) {
        [_poiArray addObject:poi];
        return YES;
    }

    if (self.northEastNode == nil) {
        [self subdivide];
    }

    if ([_northWestNode addData:poi]) {
        return YES;
    } else if ([_northEastNode addData:poi]) {
        return YES;
    } else if ([_southWestNode addData:poi]) {
        return YES;
    } else if ([_southEastNode addData:poi]) {
        return YES;
    }

    return NO;
}

- (void)getDataInRect:(MKMapRect)bounds resultArray:(NSMutableArray *)resultArray
{
    if (MKMapRectIsNull(MKMapRectIntersection(_bounds, bounds))) {
        return;
    }
    
    for (POI *poi in _poiArray) {
        if (MKMapRectContainsPoint(bounds, [poi mapPoint])) {
            [resultArray addObject:poi];
//            NSLog(@"%s got a result: %@", __FUNCTION__, poi.name);
        }
    }
    
    if (self.northEastNode == nil) {
        return;
    }
    [_northWestNode getDataInRect:bounds resultArray:resultArray];
    [_northEastNode getDataInRect:bounds resultArray:resultArray];
    [_southWestNode getDataInRect:bounds resultArray:resultArray];
    [_southEastNode getDataInRect:bounds resultArray:resultArray];
    return;
}
/*
- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale
{
    double TBCellSize = TBCellSizeForZoomScale(zoomScale);
    double scaleFactor = zoomScale / TBCellSize;
    
    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);
    
    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            
            __block double totalX = 0;
            __block double totalY = 0;
            __block int count = 0;
            
            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) {
                totalX += data.x;
                totalY += data.y;
                count++;
            });
            
            if (count >= 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate count:count];
                [clusteredAnnotations addObject:annotation];
            }
        }
    }
    
    return [NSArray arrayWithArray:clusteredAnnotations];
}
*/
@end
