//
//  CDASyncDownloadTest.m
//  CDASyncService
//
//  Created by Tamara Bernad on 06/05/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDADownloadableContentAnalyzerModule.h"
#import "CDASyncConfiguration.h"
#import "CDACoreDataStack.h"
@interface CDASyncDownloadTest : XCTestCase

@property (nonatomic, strong)CDADownloadableContentAnalyzerModule *sut;
@property(nonatomic, strong)CDACoreDataStack *stack;
@property (nonatomic, strong)XCTestExpectation *expectation;
@end

@implementation CDASyncDownloadTest

- (void)setUp {
    self.stack = [[CDACoreDataStack alloc] initWithModelName:@"Model"];
    self.expectation = [self expectationWithDescription:NSStringFromClass(self.class)];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    self.sut = [[CDADownloadableContentAnalyzerModule alloc] initWithSyncModel:[CDASyncConfiguration mediaDownoadWithStack:self.stack]];
    
    CDASyncDownloadTest __weak *weakSelf = self;
    [self.sut setCompletionBlock:^{
        id result = [weakSelf.sut result];
        NSError *error = [weakSelf.sut error];
        XCTAssert(result != nil);
        XCTAssert(error == nil);
        [weakSelf.expectation fulfill];
    }];
    [self.sut start];
    
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];

}

@end
