//
//  iOS_navi_quick_startUITests.m
//  iOS-navi-quick-startUITests
//
//  Created by liubo on 2017/1/11.
//  Copyright © 2017年 AutoNavi. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface iOS_navi_quick_startUITests : XCTestCase

@end

@implementation iOS_navi_quick_startUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    
    XCUIApplication *app = [[XCUIApplication alloc] init];
    
    XCUIElement *element = [[[[[[[app.otherElements containingType:XCUIElementTypeNavigationBar identifier:@"QuickStart"] childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther].element childrenMatchingType:XCUIElementTypeOther] elementBoundByIndex:1];
    
    //判断搜索结果数量
    XCUIElementQuery *allRedPins = [element.images containingPredicate:[NSPredicate predicateWithFormat:@"%K CONTAINS[cd] %@", @"identifier", @"redPin.png"]];
    NSPredicate *redPinCountPredicate = [NSPredicate predicateWithFormat:@"count > 0"];
    __block XCTestExpectation *expectation = [self expectationForPredicate:redPinCountPredicate evaluatedWithObject:allRedPins handler:nil];
    [self waitForExpectationsWithTimeout:25 handler:^(NSError * _Nullable error) {
        expectation = nil;
        
        if (error)
        {
            XCTAssert(@"expectation error");
        }
    }];
    
    NSInteger redPinCount = allRedPins.count;
    XCUIElement *pinElement1 = [allRedPins elementBoundByIndex:0];
    XCUIElement *pinElement2 = [allRedPins elementBoundByIndex:(redPinCount - 1)];
    
    //选择一个搜索结果
    if (!pinElement1.isHittable)
    {
        [element twoFingerTap];
    }
    [pinElement1 tap];
    
    sleep(2);
    XCUIElement *calloutView1 = [[element descendantsMatchingType:XCUIElementTypeAny] childrenMatchingType:XCUIElementTypeButton].element;
    XCUICoordinate *cooridnate1 = [[calloutView1 coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:CGVectorMake(30, 30)];
    [cooridnate1 tap];
    
    //进行导航
    sleep(5);
    XCUIElement *defaultNaviFooterIconCloseButton = app.buttons[@"default navi footer icon close"];
    [defaultNaviFooterIconCloseButton tap];

    //选择另外一个搜索结果
    if (!pinElement2.isHittable)
    {
        [element twoFingerTap];
    }
    [pinElement2 tap];
    
    sleep(2);
    XCUIElement *calloutView2 = [[element descendantsMatchingType:XCUIElementTypeAny] childrenMatchingType:XCUIElementTypeButton].element;
    XCUICoordinate *cooridnate2 = [[calloutView2 coordinateWithNormalizedOffset:CGVectorMake(0, 0)] coordinateWithOffset:CGVectorMake(30, 30)];
    [cooridnate2 tap];
    
    //进行导航
    sleep(5);
    [defaultNaviFooterIconCloseButton tap];
    
    sleep(1);
}

@end
