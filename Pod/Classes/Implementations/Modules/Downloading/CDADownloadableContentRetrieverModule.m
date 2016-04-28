//
//  CDADownloadableContentRetrieverModule.m
//  Pods
//
//  Created by Tamara Bernad on 24/04/16.
//
//

#import "CDADownloadableContentRetrieverModule.h"
#import "CDASyncConnectorProtocol.h"
#import "CDASyncModel.h"
#import "CDABackgroundDownloadManager.h"
#import "CDACoreDataStack.h"
#import "CDASynConstants.h"
#import "CDABGDFile.h"
#import "CDABGDRelationFile.h"

@interface CDADownloadableContentRetrieverModule()
@property (nonatomic, strong)id<CDASyncConnectorProtocol> connector;
@property (nonatomic, strong)id<CDACoreDataStackProtocol> downloadCoreDataStack;
@end
@implementation CDADownloadableContentRetrieverModule
@synthesize result = _result, error = _error;

#pragma mark - lazy getters
- (id<CDASyncConnectorProtocol>)connector{
    if(!_connector){
        Class cClass = [[self.model userInfo] valueForKey:@"connectorClass"];
        _connector = [cClass new];
    }
    return _connector;
}
- (instancetype)initWithSyncModel:(id<CDASyncModel>)syncModel{
    NSAssert([[syncModel userInfo] valueForKey:@"connectorClass"] != nil, @"CDARestModule connectorClass must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"baseUrl"] != nil, @"CDARestModule baseUrl must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"resource"] != nil, @"CDARestModule resource must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"paramKey"] != nil, @"CDARestModule paramKey must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"downloadPath"] != nil, @"CDARestModule downloadPath must be specified");
    return [super initWithSyncModel:syncModel];
}
#pragma mark - CDASyncModule
- (double)progress{
    return [self.connector progress];
}
- (void)main{
    if ([self isCancelled]) {
        return;
    }
    self.connector.baseUrl = [[self.model userInfo] valueForKey:@"baseUrl"];
    self.connector.resource = [[self.model userInfo] valueForKey:@"resource"];
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.downloadCoreDataStack = [[CDACoreDataStack alloc] initWithModelName:kSyncConstantBGDownloadDatabaseName AndBundle:bundle];
    
    NSString *downloadPath = [[self.model userInfo] valueForKey:@"downloadPath"];
    NSArray *idsToDownload = [[self.model userInfo] valueForKey:@"data"] ? [[self.model userInfo] valueForKey:@"data"]: [((id<CDASyncModule>)[self.dependencies lastObject]) result];
    

    NSString *paramKey = [[self.model userInfo] valueForKey:@"paramKey"];
    NSDictionary *parameters = @{paramKey : idsToDownload};
    CDADownloadableContentRetrieverModule __weak *weakSelf = self;
    [self.connector getObjectsWithParameters:parameters WithSuccess:^(id responseObject) {
        NSString *downloadUrl = (NSString *)responseObject;
        NSString *fileName = [downloadUrl lastPathComponent];
        
        CDABGDFile *file = [weakSelf.downloadCoreDataStack createNewEntity:NSStringFromClass([CDABGDFile class]) inContext:[weakSelf.downloadCoreDataStack managedObjectContext]];
        [file addRelationFiles:[weakSelf createDownloadFilesObjectsForIds:idsToDownload]];
        [weakSelf.downloadCoreDataStack saveMainContext];
        
        [[CDABackgroundDownloadManager sharedInstance] addDownloadTaskWithUrlString:downloadUrl AndDestinationFilePath:[downloadPath stringByAppendingPathComponent:fileName]];
        _result = responseObject;
        [weakSelf completeOperation];
    } failure:^(NSError *error) {
        _error = [error copy];
        [weakSelf completeOperation];
    }];
    
}
- (NSSet *)createDownloadFilesObjectsForIds:(NSArray *)ids{
    NSMutableArray *files = [NSMutableArray new];
    CDABGDRelationFile *relationFile;
    for (NSString *entityId in ids) {
        relationFile = [self.downloadCoreDataStack createNewEntity:NSStringFromClass([CDABGDRelationFile class]) inContext:[self.downloadCoreDataStack managedObjectContext]];
        relationFile.destinationFolder = @"";
        relationFile.entityClass = @"";
        relationFile.entityHashKey = @"";
        relationFile.entityId = entityId;
        relationFile.fileName = @"";
        relationFile.fileHash = @"";
        [files addObject:relationFile];
    }
    return [NSSet setWithArray:files];
}
@end
