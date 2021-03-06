//
//  CDANetworkSyncModuleTest.m
//  CDASyncService
//
//  Created by Tamara Bernad on 19/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDARestModule.h"
#import "CDASimpleSyncModel.h"
#import "CDAAFNetworkingConnector.h"

@interface CDANetworkSyncModuleTest : XCTestCase
@property (nonatomic, strong)CDARestModule *sut;
@property (nonatomic, strong)XCTestExpectation *expectation;
@end

@implementation CDANetworkSyncModuleTest

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
    
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:nil userInfo:@{@"baseUrl":@"http://data.soft-cells.com/api/v1", @"resource":@"product-performance/ipad/textiles",@"connectorClass":[CDAAFNetworkingConnector class]} timeInterval:0];
    
    self.sut = [[CDARestModule alloc] initWithSyncModel:m];
    
    CDANetworkSyncModuleTest __weak *weakSelf = self;
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
- (void)testBaseAuth {
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:nil userInfo:@{@"baseUrl":@"http://staging.trainingbinder.kvadrat.dk/api", @"resource":@"media",@"connectorClass":[CDAAFNetworkingConnector class], @"basicAuthUser":@"ktb_@&3App", @"basicAuthPassword":@"8mGpzDNR52KQJt5VwQeUqpMJztML6X9j"} timeInterval:0];
    
    self.sut = [[CDARestModule alloc] initWithSyncModel:m];
    
    CDANetworkSyncModuleTest __weak *weakSelf = self;
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
- (void)testWrongJSON {
    
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:nil userInfo:@{@"baseUrl":@"http://data.soft-cells.com/api/v1", @"resource":@"product-performance",@"connectorClass":[CDAAFNetworkingConnector class]} timeInterval:0];
    
    self.sut = [[CDARestModule alloc] initWithSyncModel:m];
    
    CDANetworkSyncModuleTest __weak *weakSelf = self;
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
