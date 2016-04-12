//
//  CDAAbstractSyncServiceTest.m
//  CDASyncService
//
//  Created by Tamara Bernad on 11/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDAAbstractSyncService.h"
#import "CDASimpleSyncModel.h"
#import "CDABundleSyncModule.h"
#import "CDAParserSyncModule.h"
#import "CDANoConversionParser.h"

@interface CDAAbstractSyncServiceTest : XCTestCase
@property (nonatomic, strong)CDAAbstractSyncService *sut;
@property (nonatomic, strong)XCTestExpectation *expectation;
@end

@implementation CDAAbstractSyncServiceTest

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

- (void)testAbstractCorrect {
    CDASimpleSyncModel *m1 = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDABundleSyncModule class] userInfo:@{@"baseUrl":@"", @"resource":@"test"} timeInterval:0];
    
    CDASimpleSyncModel *m2 = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDAParserSyncModule class] userInfo:@{@"parserClass":[CDANoConversionParser class]} timeInterval:0];
    
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"CDAAbstractSyncService" moduleClass:[CDAAbstractSyncService class] userInfo:@{} subModuleModels:[NSArray<CDASyncModel> arrayWithObjects:m1,m2, nil] timeInterval:0];
    
    self.sut = [[CDAAbstractSyncService alloc] initWithSyncModel:m];
    
    CDAAbstractSyncServiceTest __weak *weakSelf = self;
    [self.sut setCompletionBlock:^{
        XCTAssert(weakSelf.sut.error == nil);
        [weakSelf.expectation fulfill];
    }];
    [self.sut start];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testAbstractErrorOnFirstStep {
    CDASimpleSyncModel *m1 = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDABundleSyncModule class] userInfo:@{@"baseUrl":@"", @"resource":@"test2"} timeInterval:0];
    
    CDASimpleSyncModel *m2 = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDAParserSyncModule class] userInfo:@{@"parserClass":[CDANoConversionParser class]} timeInterval:0];
    
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"CDAAbstractSyncService" moduleClass:[CDAAbstractSyncService class] userInfo:@{} subModuleModels:[NSArray<CDASyncModel> arrayWithObjects:m1,m2, nil] timeInterval:0];
    
    self.sut = [[CDAAbstractSyncService alloc] initWithSyncModel:m];
    
    CDAAbstractSyncServiceTest __weak *weakSelf = self;
    [self.sut setCompletionBlock:^{
        XCTAssert(weakSelf.sut.error != nil);
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