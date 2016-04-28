//
//  CDAArchiveProcessorTest.m
//  CDASyncService
//
//  Created by Tamara Bernad on 21/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CDADownloadedArchiveProcessor.h"
#import "CDASynConstants.h"
#import "CDACoreDataStack.h"

#import "CDABGDFile.h"
#import "CDABGDRelationFile.h"

#import "File.h"
#import "CDASimpleSyncModel.h"
#import "CDASyncErrors.h"
@interface CDAArchiveProcessorTest : XCTestCase
@property(nonatomic, strong)CDACoreDataStack *appstack;
@property(nonatomic, strong)CDACoreDataStack *archiveStack;
@property(nonatomic, strong)CDADownloadedArchiveProcessor *sut;
@property (nonatomic, strong)XCTestExpectation *expectation;
@end

@implementation CDAArchiveProcessorTest

- (void)setUp {
    [super setUp];
    
     self.expectation = [self expectationWithDescription:NSStringFromClass(self.class)];
    self.appstack = [[CDACoreDataStack alloc] initWithModelName:@"Model" AndBundle:nil];
    
    NSBundle *bundle = [NSBundle bundleForClass:[CDADownloadedArchiveProcessor class]];
    self.archiveStack = [[CDACoreDataStack alloc] initWithModelName:kSyncConstantBGDownloadDatabaseName
                                                          AndBundle:bundle];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    CDASimpleSyncModel *model = [[CDASimpleSyncModel alloc] initWithUid:@"teste" moduleClass:nil userInfo:@{@"archivesFolder":[[paths firstObject] stringByAppendingPathComponent:kSyncConstantArchivePath], @"archivesProcessingFolder":[[paths firstObject] stringByAppendingPathComponent:kSyncConstantArchiveProcessing], @"appCoreDataStack":self.appstack} timeInterval:0];
    
    self.sut = [[CDADownloadedArchiveProcessor alloc] initWithSyncModel:model];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    self.sut = nil;
    [super tearDown];
    
}

- (void)testAllOk {
    [self deleteAllDataContent];
    
    [self moveZipToDocuments];

    [self precreateFileObjects];
    
    CDAArchiveProcessorTest __weak *weakSelf = self;
    [self.sut setCompletionBlock:^{
        NSError *error = [weakSelf.sut error];
        XCTAssert(error == nil);
        [weakSelf.expectation fulfill];
    }];
    [self.sut start];
    [self waitExpectation];
    
}
- (void)testNoZips {
    [self deleteAllDataContent];
    [self precreateFileObjects];
    CDAArchiveProcessorTest __weak *weakSelf = self;
    [self.sut setCompletionBlock:^{
        NSError *error = [weakSelf.sut error];
        XCTAssert(error == nil);
        [weakSelf.expectation fulfill];
    }];
    [self.sut start];
    [self waitExpectation];

}
- (void)precreateFileObjects{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths firstObject];
    
    CDABGDFile *archive = (CDABGDFile *)[self.archiveStack createNewEntity:NSStringFromClass([CDABGDFile class]) inContext:[self.archiveStack managedObjectContext]];
    archive.fileName = @"archive-test.zip";
    archive.path = [[documentsPath stringByAppendingPathComponent:kSyncConstantArchivePath] stringByAppendingPathComponent:archive.fileName];
    
    CDABGDRelationFile *rel;
    File *file;
    for(int i=1; i<6; i++){
        file = (File *)[self.appstack createNewEntity:NSStringFromClass([File class]) inContext:[self.appstack managedObjectContext]];
        file.uid = [NSString stringWithFormat:@"%i", i];
        
        rel = (CDABGDRelationFile *)[self.archiveStack createNewEntity:NSStringFromClass([CDABGDRelationFile class]) inContext:[self.archiveStack managedObjectContext]];
        rel.destinationFolder = [documentsPath stringByAppendingPathComponent:@"images"];
        rel.entityClass = NSStringFromClass([File class]);
        rel.entityHashKey = @"fileHash";
        rel.entityId = [NSString stringWithFormat:@"%i", i];
        rel.fileHash = [NSString stringWithFormat:@"hash %i", i];
        rel.fileName = [NSString stringWithFormat:@"%i.jpg", i];
        
        [archive addRelationFilesObject:rel];
    }
    [self.archiveStack saveMainContext];
    [self.appstack saveMainContext];

}
- (void)moveZipToDocuments{
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

    NSString *path = [[paths firstObject] stringByAppendingPathComponent:kSyncConstantArchivePath];
    [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
    
    
    NSURL *dest = [NSURL fileURLWithPath:[path stringByAppendingPathComponent:@"archive-test.zip"]];
    NSURL *orig = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"archive-test" ofType:@"zip"]];
    [[NSFileManager defaultManager] replaceItemAtURL:dest withItemAtURL:orig backupItemName:nil options:0 resultingItemURL:nil error:&error];
}
- (void)deleteAllDataContent{
    NSArray *bgfiles = [self.archiveStack fetchEntities:NSStringFromClass([CDABGDFile class]) WithSortKey:nil Ascending:NO WithPredicate:nil InContext:[self.archiveStack managedObjectContext]];
    
    for (CDABGDFile *file in bgfiles) {
        [[self.archiveStack managedObjectContext] deleteObject:file];
    }
    [self.archiveStack saveMainContext];
    
    
    NSArray *files = [self.appstack fetchEntities:NSStringFromClass([File class]) WithSortKey:nil Ascending:NO WithPredicate:nil InContext:[self.appstack managedObjectContext]];
    
    for (File *file in files) {
        [[self.appstack managedObjectContext] deleteObject:file];
    }
    [self.appstack saveMainContext];
}
- (void)waitExpectation{
    [self waitForExpectationsWithTimeout:120.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}
@end
