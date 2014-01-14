//
//  ViewController.m
//  FindAnything
//
//  Created by LiPeng on 13-12-27.
//  Copyright (c) 2013年 LiPeng. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) QuadTreeNode *quadTree;
@property (strong, nonatomic) NSMutableArray *showingShopsArray;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.showingShopsArray = [NSMutableArray arrayWithCapacity:100];
    NSMutableArray *shopArray = [NSMutableArray arrayWithCapacity:100];
    for (int i = 0; i < 100; i++) {
        POI *poi = [[POI alloc] init];
        poi.name = [NSString stringWithFormat:@"shop%d", i ];
        poi.address = [NSString stringWithFormat:@"street %d", i ];
        
        CLLocationDegrees x = (double)(arc4random() % 360) - 180;
        CLLocationDegrees y = (double)(arc4random() % 180) - 90;
        poi.location = [[CLLocation alloc] initWithLatitude:y longitude:x];
        [shopArray addObject:poi];
    }
    
    self.quadTree = [[QuadTreeNode alloc] init];
    for (POI *poi in shopArray) {
        [self addData:poi toQuadTree:_quadTree];
    }
}

- (void)addData:(POI *)poi toQuadTree:(QuadTreeNode *)head
{
    [head addData:poi];
}

- (NSArray *)getDataInMapRect:(MKMapRect)rect
{
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:100];
    [_quadTree getDataInRect:rect resultArray:resultArray];
    return resultArray;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    NSSet *after = [NSSet setWithArray:annotations];
    
    // Annotations to keep in map
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    // Annotations to add to map
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    // Annotations to remove from map
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    // These two methods must be called on the main thread
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    }];
}

#pragma mark -
#pragma mark MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [[NSOperationQueue new] addOperationWithBlock:^{
        double zoomScale = self.mapView.bounds.size.width / self.mapView.visibleMapRect.size.width;
//        NSArray *annotations = [_treeHead clusteredAnnotationsWithinMapRect:mapView.visibleMapRect withZoomScale:zoomScale];
        NSArray *annotations = [self getDataInMapRect:[mapView visibleMapRect]];
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}

@end
