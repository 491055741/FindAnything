//
//  QuadTreeNode.h
//  FindAnything
//
//  Created by LiPeng on 13-12-27.
//  Copyright (c) 2013年 LiPeng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mapkit/MKAnnotation.h>
#import <Mapkit/MKGeometry.h>

#define kBucketCapacity 10

// latitude  纬度
// longitude 经度


@interface POI : NSObject <MKAnnotation>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, retain) CLLocation* location;
@end


@interface QuadTreeNode : NSObject

@property (nonatomic, retain) QuadTreeNode *northWestNode;
@property (nonatomic, retain) QuadTreeNode *northEastNode;
@property (nonatomic, retain) QuadTreeNode *southWestNode;
@property (nonatomic, retain) QuadTreeNode *southEastNode;
@property (nonatomic, retain) NSMutableArray *poiArray;
@property (nonatomic, assign) MKMapRect bounds;

- (void)dump;
- (BOOL)addData:(POI *)poi;
- (void)getDataInRect:(MKMapRect)bounds resultArray:(NSMutableArray *)resultArray;
@end
