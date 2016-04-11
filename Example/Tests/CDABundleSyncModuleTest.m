//
//  CDABundleSyncModuleTest.m
//  CDASyncService
//
//  Created by Tamara Bernad on 11/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDABundleSyncModule.h"
#import "CDASimpleSyncModel.h"

@interface CDABundleSyncModuleTest : XCTestCase
@property (nonatomic, strong)CDABundleSyncModule *sut;
@property (nonatomic, strong)XCTestExpectation *expectation;
@end

@implementation CDABundleSyncModuleTest

- (void)setUp {
    self.expectation = [self expectationWithDescription:NSStringFromClass(self.class)];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.expectation = nil;
    self.sut = nil;
}

- (void)testCorrectJSON {
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDABundleSyncModule class] userInfo:@{@"baseUrl":@"", @"resource":@"test"} timeInterval:0];
    
    self.sut = [[CDABundleSyncModule alloc] initWithSyncModel:m];
    
    CDABundleSyncModuleTest __weak *weakSelf = self;
    [self.sut setCompletionBlock:^{
        id result = [weakSelf.sut result];
        NSError *error = [weakSelf.sut error];
        XCTAssert(result != nil);
        XCTAssert(error == nil);
        [weakSelf.expectation fulfill];
    }];
    [self.sut start];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}
- (void)testICCorrectJSON {
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDABundleSyncModule class] userInfo:@{@"baseUrl":@"", @"resource":@"test-error"} timeInterval:0];
    
    self.sut = [[CDABundleSyncModule alloc] initWithSyncModel:m];
    
    CDABundleSyncModuleTest __weak *weakSelf = self;
    [self.sut setCompletionBlock:^{
        id result = [weakSelf.sut result];
        NSError *error = [weakSelf.sut error];
        XCTAssert(result == nil);
        XCTAssert(error != nil);
        [weakSelf.expectation fulfill];
    }];
    [self.sut start];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}
@end
