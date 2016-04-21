//
//  CDAArchiveDownloadProcessor.m
//  Pods
//
//  Created by Tamara Bernad on 21/04/16.
//
//

#import "CDAArchiveDownloadProcessor.h"
#import "CDASyncModel.h"
#import "CDASyncModule.h"
#import <SSZipArchive/SSZipArchive.h>

#import "CDACoreDataStack.h"
#import "CDASynConstants.h"
#import "CDABGDFile.h"
#import "CDABGDRelationFile.h"

@interface CDAArchiveDownloadProcessor()

@property (nonatomic, strong)id<CDACoreDataStackProtocol> archiveCoreDataStack;
@property (nonatomic, strong)id<CDACoreDataStackProtocol> destinationCoreDataStack;
@end
@implementation CDAArchiveDownloadProcessor
@synthesize result = _result, error = _error;
- (instancetype)initWithSyncModel:(id<CDASyncModel>)syncModel{
    NSAssert([[syncModel userInfo] valueForKey:@"archivesFolder"] != nil, @"CDAArchiveDownloadProcessor archivesFolder must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"baseUrl"] != nil, @"CDARestModule baseUrl must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"resource"] != nil, @"CDARestModule resource must be specified");
    return [super initWithSyncModel:syncModel];
}
#pragma mark - CDASyncModule
- (double)progress{
    return 0;
}
- (void)main{
    if ([self isCancelled]) {
        return;
    }
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.archiveCoreDataStack = [[CDACoreDataStack alloc] initWithModelName:kSyncConstantBGDownloadDatabaseName AndBundle:bundle];
    
    NSString *archivesFolder = [[self.model userInfo] valueForKey:@"archivesFolder"];
    NSError *error;
    NSArray *archives = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:archivesFolder error:&error];
    archives = [archives filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", @".zip"]];
    if(archives.count == 0 || error){
        _error = error;
        [self completeOperation];
        return;
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *processingFolder = [[paths firstObject] stringByAppendingPathComponent:kSyncConstantArchiveProcessing];
    NSString *uncompressedFolder;
    
    for (NSString *archive in archives) {
        CDABGDFile *mArchive = (CDABGDFile *)[self.archiveCoreDataStack fetchEntity:NSStringFromClass([CDABGDFile class]) WithPredicate:[NSPredicate predicateWithFormat:@"fileName", archive] InContext:[self.archiveCoreDataStack managedObjectContext]];
        
        uncompressedFolder = [processingFolder stringByAppendingPathComponent:archive];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:uncompressedFolder withIntermediateDirectories:YES attributes:nil error:&error];
        
        if(error){
            continue;
        }
        
        [SSZipArchive unzipFileAtPath:mArchive.path toDestination: uncompressedFolder];
        
        NSArray *archiveContentFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:uncompressedFolder error:&error];
        
        if(error){
            continue;
        }
        
        for (NSString *archiveContentFile in archiveContentFiles) {
            CDABGDRelationFile *relationFile = [self.archiveCoreDataStack fetchEntity:NSStringFromClass([CDABGDRelationFile class]) WithPredicate:[NSPredicate predicateWithFormat:@"archive = %@ && fileName == %@", mArchive, archiveContentFile] InContext:[self.archiveCoreDataStack managedObjectContext]];
            
            NSError *error;
            NSURL *dest = [NSURL fileURLWithPath:[relationFile.destinationFolder stringByAppendingPathComponent:relationFile.fileName]];
            NSURL *orig = [NSURL fileURLWithPath:[uncompressedFolder stringByAppendingPathComponent:archiveContentFile]];
            [[NSFileManager defaultManager] replaceItemAtURL:dest withItemAtURL:orig backupItemName:nil options:0 resultingItemURL:nil error:&error];
            
            if(error){
                continue;
            }
            
            NSManagedObject *obj = [self.destinationCoreDataStack fetchEntity:NSStringFromClass(relationFile.entityClass) WithPredicate:[NSPredicate predicateWithFormat:@"uid == %@", relationFile.entityId] InContext:[self.destinationCoreDataStack managedObjectContext]];
            
            [obj setValue:relationFile.fileHash forKey:relationFile.entityHashKey];
            [self.destinationCoreDataStack saveMainContext];
        }
        
        [[NSFileManager defaultManager] removeItemAtPath:mArchive.path error:&error];
        [[NSFileManager defaultManager] removeItemAtPath:uncompressedFolder error:&error];
        
        
    }
}
- (NSObject *)archivesToProcess{
    NSString *archivesFolder = [[self.model userInfo] valueForKey:@"archivesFolder"];
    NSError *error = nil;
    NSArray *archives = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:archivesFolder error:&error];
    archives = [archives filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", @".zip"]];
    if(archives.count == 0 || error){
    
        return error;
    }
    
    return archives;
}
@end
