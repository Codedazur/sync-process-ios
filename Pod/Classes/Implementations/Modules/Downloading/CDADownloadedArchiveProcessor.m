//
//  CDAArchiveDownloadProcessor.m
//  Pods
//
//  Created by Tamara Bernad on 21/04/16.
//
//

#import "CDADownloadedArchiveProcessor.h"
#import "CDASyncModel.h"
#import "CDASyncModule.h"
#import <SSZipArchive/SSZipArchive.h>

#import "CDACoreDataStack.h"
#import "CDASynConstants.h"
#import "CDABGDFile.h"
#import "CDABGDRelationFile.h"
#import "CDASyncErrors.h"
#import "CDASyncFileHelper.h"

@interface CDADownloadedArchiveProcessor()

@property (nonatomic, strong)id<CDASyncModel> model;
@property (nonatomic, strong)id<CDACoreDataStackProtocol> archiveCoreDataStack;
@property (nonatomic, weak)id<CDACoreDataStackProtocol> appCoreDataStack;
@end
@implementation CDADownloadedArchiveProcessor
@synthesize result = _result, error = _error;

- (id)initWithSyncModel:(id<CDASyncModel>)syncModel{
    if(!(self = [super init]))return self;
    NSAssert([[syncModel userInfo] valueForKey:@"archivesFolder"] != nil, @"CDAArchiveDownloadProcessor archivesFolder must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"archivesProcessingFolder"] != nil, @"CDAArchiveDownloadProcessor archivesProcessingFolder must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"appCoreDataStack"] != nil, @"CDAArchiveDownloadProcessor appCoreDataStack must be specified");
    self.model = syncModel;
    return self;
}
#pragma mark - CDASyncModule
- (double)progress{
    return 0;
}
- (void)main{
    if ([self isCancelled]) {
        return;
    }
    self.appCoreDataStack =[[self.model userInfo] valueForKey:@"appCoreDataStack"];
    NSString *archivesProcessingFolder = [[CDASyncFileHelper documentsFolderPath] stringByAppendingPathComponent:[[self.model userInfo] valueForKey:@"archivesProcessingFolder"]];
    
    NSArray *archives = [self getArchivesFilesToProcess];
    if(archives.count == 0){
        return;
    }
    
    NSError *error;
    NSMutableArray *processedArchiveNames = [NSMutableArray new];
    for (NSString *archive in archives) {
        CDABGDFile *mArchive = (CDABGDFile *)[self.archiveCoreDataStack fetchEntity:NSStringFromClass([CDABGDFile class]) WithPredicate:[NSPredicate predicateWithFormat:@"fileName = %@", archive] InContext:[self.archiveCoreDataStack managedObjectContext]];
        NSString *archiveAbsolutePath = [[[CDASyncFileHelper documentsFolderPath] stringByAppendingPathComponent:mArchive.path] stringByAppendingPathComponent:mArchive.fileName];
        
        NSString *extractFolderName = [[archive componentsSeparatedByString:@"."] firstObject];
        NSString *extractFolderPath = [archivesProcessingFolder stringByAppendingPathComponent:extractFolderName];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:extractFolderPath withIntermediateDirectories:YES attributes:nil error:&error];
        
        if(error){
            [self setErrorToService:error];
            continue;
        }
        
        BOOL unziped = [SSZipArchive unzipFileAtPath:archiveAbsolutePath toDestination: extractFolderPath];
        if(!unziped){
            [self setErrorToService:[NSError errorWithDomain:kSyncServiceDomain code:CDASyncErrorUnarchiving userInfo:nil]];
            continue;
        }
        
        
        NSArray *archiveContentFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:extractFolderPath error:&error];
        
        if(error){
            [self setErrorToService:error];
            continue;
        }
        
        [self processArchiveContentsWithArchiveContentFiles:archiveContentFiles AndArchiveModel:mArchive AndExtractFolderPath:extractFolderPath];
        
        [[NSFileManager defaultManager] removeItemAtPath:archiveAbsolutePath error:&error];
        [self setErrorToService:error];
        [[NSFileManager defaultManager] removeItemAtPath:extractFolderPath error:&error];
        [self setErrorToService:error];
        
        [processedArchiveNames addObject:[mArchive.fileName copy]];
    }
    _result = [NSArray arrayWithArray:processedArchiveNames];
}
- (void)setErrorToService:(NSError *)error{
    //Although the process continues we want to only show the first error
    _error = _error == nil ? error : _error;
}
- (void)processArchiveContentsWithArchiveContentFiles:(NSArray *)archiveContentFiles AndArchiveModel:(CDABGDFile *)mArchive AndExtractFolderPath:(NSString *)extractFolderPath{
    
    NSString *documentsPath = [CDASyncFileHelper documentsFolderPath];
    for (NSString *archiveContentFile in archiveContentFiles) {
        CDABGDRelationFile *relationFile = [self.archiveCoreDataStack fetchEntity:NSStringFromClass([CDABGDRelationFile class]) WithPredicate:[NSPredicate predicateWithFormat:@"archive = %@ && fileName == %@", mArchive, archiveContentFile] InContext:[self.archiveCoreDataStack managedObjectContext]];
        
        NSString *destinationFolder = [documentsPath stringByAppendingPathComponent:relationFile.destinationFolder];
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:destinationFolder withIntermediateDirectories:YES attributes:nil error:&error];
        
        NSURL *dest = [NSURL fileURLWithPath:[destinationFolder stringByAppendingPathComponent:relationFile.fileName]];
        NSURL *orig = [NSURL fileURLWithPath:[extractFolderPath stringByAppendingPathComponent:archiveContentFile]];
        [[NSFileManager defaultManager] replaceItemAtURL:dest withItemAtURL:orig backupItemName:nil options:0 resultingItemURL:nil error:&error];
        
        if(error){
            [self setErrorToService:error];
            continue;
        }
        
        NSString *predicateString = [NSString stringWithFormat:@"%@ == %@", relationFile.entityIdKey, @"%@"];
        NSManagedObject *obj = [self.appCoreDataStack fetchEntity:relationFile.entityClass WithPredicate:[NSPredicate predicateWithFormat:predicateString, relationFile.entityId] InContext:[self.appCoreDataStack managedObjectContext]];
        
        if(obj == nil){
            [self setErrorToService:[NSError errorWithDomain:kSyncServiceDomain code:CDASyncErrorNoRelatedObjectForDownloadedFile userInfo:@{@"message":relationFile.fileName}]];
        }
        [obj setValue:relationFile.fileHash forKey:relationFile.entityHashKey];
        [self.appCoreDataStack saveMainContext];
        
        
    }

}
- (NSArray *)getArchivesFilesToProcess{
    
    self.archiveCoreDataStack = [[CDACoreDataStack alloc] initWithModelName:kSyncConstantBGDownloadDatabaseName AndBundle:[NSBundle mainBundle]];
    NSString *documentsPath = [CDASyncFileHelper documentsFolderPath];
    NSString *archivesFolder = [documentsPath stringByAppendingPathComponent:[[self.model userInfo] valueForKey:@"archivesFolder"]];
    NSError *error;
    NSArray *archives;
    if(!error){
        archives = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:archivesFolder error:&error];
        archives = [archives filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self CONTAINS[cd] %@", @".zip"]];
        archives = [archives sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
    }else{
        NSLog(@"Error:getArchivesFilesToProcess: %@",error);
    }
    return archives;
}
@end
