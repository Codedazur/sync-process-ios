//
//  CDAParserSyncModuleTest.m
//  CDASyncService
//
//  Created by Tamara Bernad on 11/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDASimpleSyncModel.h""
#import "CDAParserSyncModule.h"
#import "CDANoConversionParser.h"

@interface CDAParserSyncModuleTest : XCTestCase
@property (nonatomic, strong)CDAParserSyncModule *sut;
@property (nonatomic, strong)XCTestExpectation *expectation;
@end

@implementation CDAParserSyncModuleTest

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

- (void)testCorrect {
    NSString * filePath =[[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    NSError * error;
    NSString* fileContents =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    
    if(error)
    {
        NSLog(@"Error reading file: %@",error.localizedDescription);
    }
    
    
    NSArray *dataList = (NSArray *)[NSJSONSerialization
                                    JSONObjectWithData:[fileContents dataUsingEncoding:NSUTF8StringEncoding]
                                    options:0 error:NULL];

    
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDAParserSyncModule class] userInfo:@{@"parserClass":[CDANoConversionParser class],@"data":dataList} timeInterval:0];
    
    self.sut = [[CDAParserSyncModule alloc] initWithSyncModel:m];
    
    CDAParserSyncModuleTest __weak *weakSelf = self;
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

- (void)testInCorrect {
    
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDAParserSyncModule class] userInfo:@{@"parserClass":[CDANoConversionParser class]} timeInterval:0];
    
    self.sut = [[CDAParserSyncModule alloc] initWithSyncModel:m];
    
    CDAParserSyncModuleTest __weak *weakSelf = self;
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
- (NSArray *)loadData{
    NSString * filePath =[[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    NSError * error;
    NSString* fileContents =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    
    if(error)
    {
        NSLog(@"Error reading file: %@",error.localizedDescription);
    }
    
    
    NSArray *dataList = (NSArray *)[NSJSONSerialization
                                    JSONObjectWithData:[fileContents dataUsingEncoding:NSUTF8StringEncoding]
                                    options:0 error:NULL];
    return dataList;
}

@end
