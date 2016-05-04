//
//  CDASyncServiceMangerTest.m
//  CDASyncService
//
//  Created by Tamara Bernad on 04/05/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CDASyncManager.h"
#import "CDANSUserDefaultsSyncScheduleManager.h"
#import "CDAAFNetworkingReachabilityManager.h"
#import "CDASyncConfiguration.h"
#import "CDACoreDataStack.h"

@interface CDASyncServiceMangerTest : XCTestCase
@property(nonatomic, strong)CDACoreDataStack *stack;
@property (nonatomic, strong)  XCTestExpectation *ex;
@end

@implementation CDASyncServiceMangerTest

- (void)setUp {
    
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    self.stack = [[CDACoreDataStack alloc] initWithModelName:@"Model"];
    self.ex = [self expectationWithDescription:@"sync"];
    
    CDASyncManager *m = [[CDASyncManager alloc] initWithSyncModels:[CDASyncConfiguration syncConfig:self.stack] SchedulerClass:CDANSUserDefaultsSyncScheduleManager.class ReachabilityManager:[CDAAFNetworkingReachabilityManager sharedManger]];
    [m sync];
    
    [self performSelector:@selector(fullfill) withObject:nil afterDelay:60];
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        
    }];

}
- (void)fullfill{
    [self.ex fulfill];
}
@end
