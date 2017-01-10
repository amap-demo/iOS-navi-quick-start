//
//  QuickStartViewController.m
//  AMapNaviKit
//
//  Created by 刘博 on 16/3/9.
//  Copyright © 2016年 AutoNavi. All rights reserved.
//

#import "QuickStartViewController.h"

#import "SpeechSynthesizer.h"
#import "DriveNaviViewController.h"
#import "QuickStartAnnotationView.h"

@interface QuickStartViewController ()<MAMapViewDelegate, AMapSearchDelegate, AMapNaviDriveManagerDelegate, AMapLocationManagerDelegate, DriveNaviViewControllerDelegate>
{
    AMapNaviPoint *_endPoint;
    
    CLLocation *_curLocation;
    
    NSMutableArray *_poiAnnotations;
}

@end

@implementation QuickStartViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"QuickStart";
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    [self initProperties];
    
    [self initMapView];
    
    [self initDriveManager];
    
    [self initSearch];
    
    [self initLocationManater];
    
    [self updateCurrentLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.toolbarHidden = YES;
}

#pragma mark - Initalization

- (void)initProperties
{
    _poiAnnotations = [[NSMutableArray alloc] init];
}

- (void)initMapView
{
    if (self.mapView == nil)
    {
        self.mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
        [self.mapView setDelegate:self];
        
        [self.view addSubview:self.mapView];
    }
}

- (void)initDriveManager
{
    if (self.driveManager == nil)
    {
        self.driveManager = [[AMapNaviDriveManager alloc] init];
        [self.driveManager setDelegate:self];
        
        [self.driveManager setAllowsBackgroundLocationUpdates:YES];
        [self.driveManager setPausesLocationUpdatesAutomatically:NO];
    }
}

- (void)initSearch
{
    if (self.search == nil)
    {
        self.search = [[AMapSearchAPI alloc] init];
        self.search.delegate = self;
    }
}

- (void)initLocationManater
{
    if (self.locationManager == nil)
    {
        self.locationManager = [[AMapLocationManager alloc] init];
        self.locationManager.delegate = self;
        
        [self.locationManager setLocationTimeout:3];
    }
}

#pragma mark - Search

- (void)startPOIAroundSearch
{
    if (_curLocation == nil)
    {
        NSLog(@"未获取到当前位置");
        return;
    }
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc] init];
    
    request.location = [AMapGeoPoint locationWithLatitude:_curLocation.coordinate.latitude
                                                longitude:_curLocation.coordinate.longitude];
    request.keywords            = @"餐饮";
    request.sortrule            = 1;
    request.requireExtension    = NO;
    
    [self.search AMapPOIAroundSearch:request];
}

#pragma mark - Location

- (void)updateCurrentLocation
{
    [self.locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
        
        if (error)
        {
            NSLog(@"error:%@", error);
            return;
        }
        
        _curLocation = location;
        
        CurrentLocationAnnotation *annotation = [[CurrentLocationAnnotation alloc] init];
        annotation.coordinate = _curLocation.coordinate;
        annotation.title = @"当前位置";
        [self.mapView addAnnotation:annotation];
        [self.mapView selectAnnotation:annotation animated:YES];
        
        [self startPOIAroundSearch];
    }];
}

#pragma mark - Actions

- (void)routePlanAction
{
    if (_curLocation == nil)
    {
        NSLog(@"未获取到当前位置");
        return;
    }
    
    AMapNaviPoint *startPoint = [AMapNaviPoint locationWithLatitude:_curLocation.coordinate.latitude
                                                          longitude:_curLocation.coordinate.longitude];
    
    [self.driveManager calculateDriveRouteWithStartPoints:@[startPoint]
                                                endPoints:@[_endPoint]
                                                wayPoints:nil
                                          drivingStrategy:AMapNaviDrivingStrategySingleDefault];
}

#pragma mark - DriveNaviView Delegate

- (void)driveNaviViewCloseButtonClicked
{
    //停止导航
    [self.driveManager stopNavi];
    
    //停止语音
    [[SpeechSynthesizer sharedSpeechSynthesizer] stopSpeak];
    
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - AMapNaviDriveManager Delegate

- (void)driveManager:(AMapNaviDriveManager *)driveManager error:(NSError *)error
{
    NSLog(@"error:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManagerOnCalculateRouteSuccess:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onCalculateRouteSuccess");
    
    DriveNaviViewController *driveVC = [[DriveNaviViewController alloc] init];
    [driveVC setDelegate:self];
    
    //将driveView添加为导航数据的Representative，使其可以接收到导航诱导数据
    [self.driveManager addDataRepresentative:driveVC.driveView];
    
    [self.navigationController pushViewController:driveVC animated:NO];
    [self.driveManager startEmulatorNavi];
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onCalculateRouteFailure:(NSError *)error
{
    NSLog(@"onCalculateRouteFailure:{%ld - %@}", (long)error.code, error.localizedDescription);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager didStartNavi:(AMapNaviMode)naviMode
{
    NSLog(@"didStartNavi");
}

- (void)driveManagerNeedRecalculateRouteForYaw:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForYaw");
}

- (void)driveManagerNeedRecalculateRouteForTrafficJam:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"needRecalculateRouteForTrafficJam");
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager onArrivedWayPoint:(int)wayPointIndex
{
    NSLog(@"onArrivedWayPoint:%d", wayPointIndex);
}

- (void)driveManager:(AMapNaviDriveManager *)driveManager playNaviSoundString:(NSString *)soundString soundStringType:(AMapNaviSoundType)soundStringType
{
    NSLog(@"playNaviSoundString:{%ld:%@}", (long)soundStringType, soundString);
    
    [[SpeechSynthesizer sharedSpeechSynthesizer] speakString:soundString];
}

- (void)driveManagerDidEndEmulatorNavi:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"didEndEmulatorNavi");
}

- (void)driveManagerOnArrivedDestination:(AMapNaviDriveManager *)driveManager
{
    NSLog(@"onArrivedDestination");
}

#pragma mark - Search Delegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error
{
    NSLog(@"SearchError:{%@}", error.localizedDescription);
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response
{
    if (response.pois.count == 0)
    {
        return;
    }
    
    [self.mapView removeAnnotations:_poiAnnotations];
    [_poiAnnotations removeAllObjects];
    
    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
        
        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
        [annotation setCoordinate:CLLocationCoordinate2DMake(obj.location.latitude, obj.location.longitude)];
        [annotation setTitle:[NSString stringWithFormat:@"%@ - %ld米", obj.name, (long)obj.distance]];
        [annotation setSubtitle:obj.address];
        
        [_poiAnnotations addObject:annotation];
    }];
    
    [self showPOIAnnotations];
}

- (void)showPOIAnnotations
{
    [self.mapView addAnnotations:_poiAnnotations];
    
    if (_poiAnnotations.count == 1)
    {
        self.mapView.centerCoordinate = [(MAPointAnnotation *)_poiAnnotations[0] coordinate];
    }
    else
    {
        [self.mapView showAnnotations:_poiAnnotations animated:NO];
    }
}

#pragma mark - MapView Delegate

- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:[MAPointAnnotation class]])
    {
        MAPointAnnotation *annotation = (MAPointAnnotation *)view.annotation;
        
        _endPoint = [AMapNaviPoint locationWithLatitude:annotation.coordinate.latitude
                                              longitude:annotation.coordinate.longitude];
        
        [self routePlanAction];
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[CurrentLocationAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"CurrentLocationAnnotationView";
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                                             reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.pinColor = MAPinAnnotationColorGreen;
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        
        return annotationView;
    }
    else if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndetifier = @"QuickStartAnnotationView";
        QuickStartAnnotationView *annotationView = (QuickStartAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndetifier];
        
        if (annotationView == nil)
        {
            annotationView = [[QuickStartAnnotationView alloc] initWithAnnotation:annotation
                                                                  reuseIdentifier:pointReuseIndetifier];
        }
        
        annotationView.canShowCallout = YES;
        annotationView.draggable = NO;
        
        return annotationView;
    }
    
    return nil;
}

#pragma mark - LocationManager Delegate

- (void)amapLocationManager:(AMapLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

@end
