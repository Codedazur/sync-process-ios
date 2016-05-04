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
@interface CDASyncServiceMangerTest : XCTestCase

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
    CDASyncManager *m = [[CDASyncManager alloc] initWithSyncModels:@[] SchedulerClass:CDANSUserDefaultsSyncScheduleManager.class ReachabilityManager:[CDAAFNetworkingReachabilityManager sharedManger]];
    [m sync];
}

@end
