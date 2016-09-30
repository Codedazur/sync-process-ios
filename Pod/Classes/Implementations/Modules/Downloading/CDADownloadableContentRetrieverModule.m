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
#import "CDADownloadableContentMapper.h"

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
    NSAssert([[syncModel userInfo] valueForKey:@"destinationFolder"] != nil, @"CDARestModule downloadPath must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"identifier"] != nil, @"CDARestModule identifier must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"mapping"] != nil, @"CDADownloadableContentModule mapping must be specified");
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
    if ([[self.model userInfo] valueForKey:@"basicAuthUser"] && [[self.model userInfo] valueForKey:@"basicAuthPassword"]) {
        self.connector.basicAuthUser = [[self.model userInfo] valueForKey:@"basicAuthUser"];
        self.connector.basicAuthPassword = [[self.model userInfo] valueForKey:@"basicAuthPassword"];
    }
    
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.downloadCoreDataStack = [[CDACoreDataStack alloc] initWithModelName:kSyncConstantBGDownloadDatabaseName AndBundle:bundle];
    
    NSString *downloadPath = [[self.model userInfo] valueForKey:@"destinationFolder"];
    NSArray *idsToDownload = [[self.model userInfo] valueForKey:@"data"] ? [[self.model userInfo] valueForKey:@"data"]: [((id<CDASyncModule>)[self.dependencies lastObject]) result];
    
    if(idsToDownload.count == 0){
        _result = @[];
        [self completeOperation];
        return;
    }
    
    
    NSString *ids = [idsToDownload componentsJoinedByString:@","];
    
    NSNumber *timeout = [[self.model userInfo] valueForKey:@"timeout"];
    if(timeout != nil){
        self.connector.timeoutInterval = timeout.doubleValue;
    }
    CDADownloadableContentRetrieverModule __weak *weakSelf = self;
    
    [self.connector createObjectWithParameters:@{@"media":ids, @"userId":[[self.model userInfo] valueForKey:@"identifier"]} WithSuccess:^(id responseObject) {
        NSString *downloadUrl = [responseObject valueForKey:@"url"];
        NSString *fileName = [downloadUrl lastPathComponent];
        
        CDABGDFile *file = (CDABGDFile *)[weakSelf.downloadCoreDataStack createNewEntity:NSStringFromClass([CDABGDFile class]) inContext:[weakSelf.downloadCoreDataStack managedObjectContext]];
        file.fileName = [downloadUrl lastPathComponent];
        file.path = downloadPath;
        
        [file addRelationFiles:[weakSelf getDownloadFilesObjectsForIds:idsToDownload]];
        [weakSelf.downloadCoreDataStack saveMainContext];
        
        [[CDABackgroundDownloadManager sharedInstance] addDownloadTaskWithUrlString:downloadUrl AndDestinationFilePath:[downloadPath stringByAppendingPathComponent:fileName]];
        _result = responseObject;
        [weakSelf completeOperation];
    } failure:^(NSError *error) {
        _error = [error copy];
        [weakSelf completeOperation];
    }];
    
}
- (NSSet *)getDownloadFilesObjectsForIds:(NSArray *)ids{
    CDADownloadableContentMapper *mapping = [[self.model userInfo] valueForKey:@"mapping"];
    NSArray *files = [self.downloadCoreDataStack fetchEntities:NSStringFromClass([CDABGDRelationFile class]) WithSortKey:nil Ascending:YES WithPredicate:[NSPredicate predicateWithFormat:@"entityClass == %@ && entityId IN %@",mapping.destinationClassName,ids] InContext:[self.downloadCoreDataStack managedObjectContext]];
    return [NSSet setWithArray:files];
}
@end
