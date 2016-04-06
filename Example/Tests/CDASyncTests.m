//
//  CDASyncTests.m
//  CDASyncService
//
//  Created by Tamara Bernad on 06/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDASyncManager.h"
#import "CDANSUserDefaultsSyncScheduleManager.h"
#import "CDAReachabilityMock.h"
#import "CDABundleSyncService.h"
#import "CDASyncModelMock.h"
#import "CDABundleSyncService.h"


@interface CDASyncTests : XCTestCase<CDASyncServiceDelegate>
@property (nonatomic, strong)CDABundleSyncService *sut;
@property (nonatomic, strong)XCTestExpectation *expectation;
@end

@implementation CDASyncTests

- (void)setUp {
    [super setUp];
    self.expectation = [self expectationWithDescription:@"CDASyncTests Expectations"];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.expectation = nil;
    self.sut = nil;
}

- (void)testExample {
    CDASyncModelMock *syncModel = [[CDASyncModelMock alloc] initWithUid:@"CDABundleSyncService" BaseUrl:@"" Resource:@"test" SyncClass:[CDABundleSyncService class] timeInterval:10];
    
    self.sut = [[CDABundleSyncService alloc] initWithSyncModel:syncModel];
    self.sut.delegate = self;
    [self.sut start];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}
- (void)CDASyncService:(id<CDASyncServiceProtocol>)syncService DidFinishWithErrorId:(CDASyncError)syncErrorId{
    [self.expectation fulfill];
}
- (void)CDASyncServiceDidFinishWithSuccess:(id<CDASyncServiceProtocol>)syncService AndResult:(id)result{
    XCTAssert(result!=nil);
    [self.expectation fulfill];
}
@end
