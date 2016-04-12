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
#import "CDAMapper.h"
#import "CDARelationMapping.h"
#import "Color.h"
#import "Textile.h"

#import "CDACoreDataParserSyncModule.h"
#import "CDARestKitCoreDataParser.h"
#import "CoreDataStack.h"

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

- (void)testAbstractCorrectWithRestKit {
    [self deleteAllDataContent];
    NSArray *dataList = [self loadData];
    CDAMapper *mapping = [self mapping];
    
    
    CDASimpleSyncModel *m1 = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDABundleSyncModule class] userInfo:@{@"baseUrl":@"", @"resource":@"test"} timeInterval:0];
    
    CDASimpleSyncModel *m2 = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDACoreDataParserSyncModule class] userInfo:@{@"parserClass":[CDARestKitCoreDataParser class],@"data":dataList, @"coreDataStack":[CoreDataStack coreDataStack], @"mapping":mapping} timeInterval:0];
    
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"CDAAbstractSyncService" moduleClass:[CDAAbstractSyncService class] userInfo:@{} subModuleModels:[NSArray<CDASyncModel> arrayWithObjects:m1,m2, nil] timeInterval:0];
    
    self.sut = [[CDAAbstractSyncService alloc] initWithSyncModel:m];
    
    CDAAbstractSyncServiceTest __weak *weakSelf = self;
    [self.sut setCompletionBlock:^{
        XCTAssert(((NSArray *)weakSelf.sut.result).count == dataList.count);
        
        [weakSelf.expectation fulfill];
    }];
    [self.sut start];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}
- (CDAMapper *)mapping{
    CDAMapper *m = [CDAMapper new];
    m.destinationClass = [Textile class];
    m.attributesMapping = @{
                            @"uid":     @"uid",
                            @"name":     @"name"
                            };
    
    CDAMapper *mC = [CDAMapper new];
    mC.destinationClass = [Color class];
    mC.attributesMapping = @{
                             @"colorway":     @"uid",
                             @"colorName":     @"colorName"
                             };
    
    CDARelationMapping *rm = [CDARelationMapping new];
    rm.mapper = mC;
    rm.remoteKey = @"colours";
    rm.localKey = @"colours";
    
    m.relationsMapping = @[rm];
    return m;
}
- (void)deleteAllDataContent{
    NSArray *colors = [CoreDataStack fetchMainContextEntities:NSStringFromClass([Color class]) WithSortKey:nil Ascending:YES WithPredicate:nil];
    NSArray *textiles = [CoreDataStack fetchMainContextEntities:NSStringFromClass([Textile class]) WithSortKey:nil Ascending:YES WithPredicate:nil];
    
    for (Color *color in colors) {
        [[[CoreDataStack coreDataStack] managedObjectContext] deleteObject:color];
    }
    
    for (Textile *textile in textiles) {
        [[[CoreDataStack coreDataStack] managedObjectContext] deleteObject:textile];
    }
    
    [[CoreDataStack coreDataStack] saveContext];
}
- (NSArray *)loadData{
    NSString * filePath =[[NSBundle mainBundle] pathForResource:@"test" ofType:@"json"];
    NSError * error;
    NSString* fileContents =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    
    if(error)
    {
        NSLog(@"Error reading file: %@",error.localizedDescription);
    }
    
    
    NSArray *dataList = [(NSDictionary *)[NSJSONSerialization
                                          JSONObjectWithData:[fileContents dataUsingEncoding:NSUTF8StringEncoding]
                                          options:0 error:NULL] valueForKey:@"response"];
    return dataList;
}
@end
