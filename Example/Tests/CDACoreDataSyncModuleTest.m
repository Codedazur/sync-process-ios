//
//  CDACoreDataSyncModuleTest.m
//  CDASyncService
//
//  Created by Tamara Bernad on 11/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "CDASimpleSyncModel.h"
#import "CDACoreDataParserSyncModule.h"
#import "CDANoConversionParser.h"
#import "CoreDataStack.h"
#import "CDAMapper.h"
#import "CDARelationMapping.h"
#import "Color.h"
#import "Textile.h"
#import "CDARestKitCoreDataParser.h"
#import "CDABundleSyncModule.h"
#import "CDAAbstractSyncService.h"

@interface CDACoreDataSyncModuleTest : XCTestCase
@property (nonatomic, strong)CDACoreDataParserSyncModule *sut;
@property (nonatomic, strong)XCTestExpectation *expectation;
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation CDACoreDataSyncModuleTest

- (void)setUp {
    self.expectation = [self expectationWithDescription:NSStringFromClass(self.class)];
    [self deleteAllDataContent];
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    self.expectation = nil;
    self.sut = nil;
}

- (void)testMapping{
    
    
    CDAMapper *m = [self mapping];
    NSArray *dataList = [self loadData];
    CDARestKitCoreDataParser  *parser = [[CDARestKitCoreDataParser alloc] initWithMapping:m AndCoreDataStack:[CoreDataStack coreDataStack]];
    CDACoreDataSyncModuleTest __weak *weakSelf = self;
    [parser parseData:dataList AndCompletion:^(id result) {
        XCTAssert(result != nil);
        NSArray *textiles = [CoreDataStack fetchMainContextEntities:NSStringFromClass([Textile class]) WithSortKey:nil Ascending:YES WithPredicate:nil];
        XCTAssert(textiles.count == dataList.count);
        [weakSelf.expectation fulfill];
        [weakSelf.timer invalidate];
    }];
    [self waitExpectation];
}

- (void)testMappingTwice{
    
    CDAMapper *m = [self mapping];
    NSArray *dataList = [self loadData];
    
    CDARestKitCoreDataParser  *parser = [[CDARestKitCoreDataParser alloc] initWithMapping:m
                                                                         AndCoreDataStack:[CoreDataStack coreDataStack]];
    CDACoreDataSyncModuleTest __weak *weakSelf = self;
    [parser parseData:dataList AndCompletion:^(id result) {
        
        CDARestKitCoreDataParser  *parser2 = [[CDARestKitCoreDataParser alloc] initWithMapping:m
                                                                              AndCoreDataStack:[CoreDataStack coreDataStack]];
        [parser2 parseData:dataList AndCompletion:^(id result) {
            XCTAssert(result != nil);
            NSArray *textiles = [CoreDataStack fetchMainContextEntities:NSStringFromClass([Textile class]) WithSortKey:nil Ascending:YES WithPredicate:nil];
            XCTAssert(textiles.count == dataList.count);
            [weakSelf.expectation fulfill];
        }];
    }];
    [self waitExpectation];
}
- (void)testSyncModuleCorrect {
    self.timer= [NSTimer scheduledTimerWithTimeInterval:1  target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    NSArray *dataList = [self loadData];
    CDAMapper *m = [self mapping];
    
    CDASimpleSyncModel *model = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:[CDAParserSyncModule class] userInfo:@{@"parserClass":[CDARestKitCoreDataParser class],@"data":dataList, @"coreDataStack":[CoreDataStack coreDataStack], @"mapping":m} timeInterval:0];
    
    self.sut = [[CDACoreDataParserSyncModule alloc] initWithSyncModel:model];
    
    CDACoreDataSyncModuleTest __weak *weakSelf = self;
    [self.sut setCompletionBlock:^{
        id result = [weakSelf.sut result];
        NSError *error = [weakSelf.sut error];

        XCTAssert(result != nil);
        XCTAssert(((NSArray *)result).count == dataList.count);
        XCTAssert(error == nil);
        [weakSelf.expectation fulfill];
    }];
    [self.sut start];
    [self waitExpectation];
    
}
- (void) timerFired:(NSTimer *)timer{
    NSLog(@"SUT progress %f", [self.sut progress]);
}
- (CDAMapper *)mapping{
    CDAMapper *m = [CDAMapper new];
    m.destinationClassName = NSStringFromClass([Textile class]);
    m.attributesMapping = @{
                            @"uid":     @"uid",
                            @"name":     @"name"
                            };
    m.localIdentifierKey = @"uid";
    
    CDAMapper *mC = [CDAMapper new];
    mC.destinationClassName= NSStringFromClass([Color class]);
    mC.attributesMapping = @{
                             @"colorway":     @"uid",
                             @"colorName":     @"colorName"
                             };
    mC.localIdentifierKey = @"uid";
    
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
- (void)waitExpectation{
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        [self.timer invalidate];
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}
@end

