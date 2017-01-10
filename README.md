本工程为基于高德地图iOS 3D地图SDK和搜索功能、导航SDK进行封装，实现了进行周边餐饮搜索并一键导航的功能。
## 前述 ##
- [高德官网申请Key](http://lbs.amap.com/dev/#/).
- 阅读[开发指南](http://lbs.amap.com/api/ios-navi-sdk/summary/).
- 工程基于iOS 3D地图SDK和搜索功能、导航SDK实现

## 功能描述 ##
通过地图SDK搜索功能进行周边餐饮搜索，可以选择搜索结果POI进行一键导航。

## 核心类/接口 ##
| 类    | 接口  | 说明   | 版本  |
| -----|:-----:|:-----:|:-----:|
| AMapSearchAPI	| - (void)AMapPOIAroundSearch:(AMapPOIAroundSearchRequest *)request; | 用关键字进行周边搜索 | v4.0.0 |
| AMapNaviDriveManager	| - (BOOL)calculateDriveRouteWithStartPoints:(NSArray<AMapNaviPoint *> *)startPoints endPoints:(NSArray<AMapNaviPoint *> *)endPoints wayPoints:(nullable NSArray<AMapNaviPoint *> *)wayPoints drivingStrategy:(AMapNaviDrivingStrategy)strategy; | 带起点的驾车路径规划 | v2.0.0 |

## 核心难点 ##

`Objective-C`
```
/* 根据当前位置进行POI周边餐饮搜索. */
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

/* 根据当前位置和目的地POI的位置进行路径规划. */
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
```

`Swift`
```
/* 根据当前位置进行POI周边餐饮搜索. */
func startPOIAroundSearch() {
    
    guard let curLocation = curLocation else {
        NSLog("未获取到当前位置")
        return
    }
    
    let request = AMapPOIAroundSearchRequest()
    
    request.location = AMapGeoPoint.location(withLatitude: CGFloat(curLocation.location.coordinate.latitude),
                                             longitude: CGFloat(curLocation.location.coordinate.longitude))
    request.keywords = "餐饮"
    request.sortrule = 1
    request.requireExtension = false
    
    search.aMapPOIAroundSearch(request)
}

/* 根据当前位置和目的地POI的位置进行路径规划. */
func routePlanAction() {
    guard let endPoint = endPoint else {
        return
    }
    
    guard let curLocation = curLocation else {
        NSLog("未获取到当前位置")
        return
    }
    
    let startP = AMapNaviPoint.location(withLatitude: CGFloat(curLocation.coordinate.latitude), longitude: CGFloat(curLocation.coordinate.longitude))!
    driveManager.calculateDriveRoute(withStart: [startP], end: [endPoint], wayPoints: nil, drivingStrategy: .singleDefault)
}
```
