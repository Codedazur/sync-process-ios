//
//  CDASyncDownloadTest.m
//  CDASyncService
//
//  Created by Tamara Bernad on 06/05/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDADownloadableContentAnalyzerModule.h"
#import "CDADownloadableContentRetrieverModule.h"
#import "CDASyncConfiguration.h"
#import "CDAAbstractSyncService.h"
#import "CDACoreDataStack.h"
#import "CDASynConstants.h"
#import "CDABGDFile.h"
#import "CDABGDRelationFile.h"
@interface CDASyncDownloadTest : XCTestCase

@property (nonatomic, strong)CDADownloadableContentAnalyzerModule *sutAnalyzer;
@property (nonatomic, strong)CDADownloadableContentRetrieverModule *sutDownloader;
@property (nonatomic, strong)CDAAbstractSyncService *sut;
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
- (void)testDownloading{
    [self deleteall];
    CDASimpleSyncModel *mAnalyze = [CDASyncConfiguration mediaDownloadAnalizerWithStack:self.stack];
    CDASimpleSyncModel *mDownload = [CDASyncConfiguration mediaDownloaderWithStack:self.stack];
    CDASimpleSyncModel *m = [[CDASimpleSyncModel alloc] initWithUid:@"download" moduleClass:nil userInfo:@{} subModuleModels:@[mAnalyze, mDownload] timeInterval:10];
    
    self.sut = [[CDAAbstractSyncService alloc] initWithSyncModel:m];
    CDASyncDownloadTest __weak *weakSelf = self;
    [self.sut setCompletionBlock:^{
        id result = [weakSelf.sut result];
        NSError *error = [weakSelf.sut error];
        XCTAssert(result != nil);
        XCTAssert(error == nil);
        //[weakSelf.expectation fulfill];
    }];
    [self.sut start];
    
    
    [self waitForExpectationsWithTimeout:120.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];

}
- (void)deleteall{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    CDACoreDataStack *stack = [[CDACoreDataStack alloc] initWithModelName:kSyncConstantBGDownloadDatabaseName AndBundle:bundle];
    NSArray *res = [stack fetchEntities:NSStringFromClass([CDABGDRelationFile class]) WithSortKey:nil Ascending:YES WithPredicate:nil InContext:[stack managedObjectContext]];
    
    for (CDABGDRelationFile *f in res) {
        [[stack managedObjectContext] deleteObject:f];
    }
    
    res = [stack fetchEntities:NSStringFromClass([CDABGDFile class]) WithSortKey:nil Ascending:YES WithPredicate:nil InContext:[stack managedObjectContext]];
    
    for (CDABGDFile *f in res) {
        [[stack managedObjectContext] deleteObject:f];
    }
    
    [stack saveMainContext];

}
//- (void)testAnalyzer {
//    self.sutAnalyzer = [[CDADownloadableContentAnalyzerModule alloc] initWithSyncModel:[CDASyncConfiguration mediaDownoadWithStack:self.stack]];
//    
//    CDASyncDownloadTest __weak *weakSelf = self;
//    [self.sutAnalyzer setCompletionBlock:^{
//        id result = [weakSelf.sutAnalyzer result];
//        NSError *error = [weakSelf.sutAnalyzer error];
//        XCTAssert(result != nil);
//        XCTAssert(error == nil);
//        [weakSelf.expectation fulfill];
//    }];
//    [self.sutAnalyzer start];
//    
//    
//    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
//        if (error) {
//            NSLog(@"Timeout Error: %@", error);
//        }
//    }];
//
//}
//- (void)testDownloader{
//    self.sutDownloader = [[CDADownloadableContentRetrieverModule alloc] initWithSyncModel:[CDASyncConfiguration mediaDownloaderWithStack:self.stack]];
//    
//    CDASyncDownloadTest __weak *weakSelf = self;
//    [self.sutDownloader setCompletionBlock:^{
//        id result = [weakSelf.sutDownloader result];
//        NSError *error = [weakSelf.sutDownloader error];
//        XCTAssert(result != nil);
//        XCTAssert(error == nil);
//        [weakSelf.expectation fulfill];
//    }];
//    [self.sutDownloader start];
//    
//    
//    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError *error) {
//        if (error) {
//            NSLog(@"Timeout Error: %@", error);
//        }
//    }];
//    
//
//}
@end
