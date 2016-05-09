//
//  CDADownloadableContentModule.m
//  Pods
//
//  Created by Tamara Bernad on 24/04/16.
//
//

#import "CDADownloadableContentAnalyzerModule.h"
#import "CDASyncConnectorProtocol.h"
#import "CDASyncErrors.h"
#import "CDADownloadableContentMapper.h"
#import "CDACoreDataStackProtocol.h"
#import "CDACoreDataStack.h"
#import "CDASynConstants.h"
#import "CDABGDRelationFile.h"

@interface CDADownloadableContentAnalyzerModule()
@property (nonatomic, strong)id<CDASyncConnectorProtocol> connector;
@property (nonatomic, strong)id<CDACoreDataStackProtocol> downloadCoreDataStack;
@end

@implementation CDADownloadableContentAnalyzerModule
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
    NSAssert([[syncModel userInfo] valueForKey:@"connectorClass"] != nil, @"CDADownloadableContentModule connectorClass must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"baseUrl"] != nil, @"CDADownloadableContentModule baseUrl must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"resource"] != nil, @"CDADownloadableContentModule resource must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"mapping"] != nil, @"CDADownloadableContentModule mapping must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"coreDataStack"] != nil, @"CDADownloadableContentModule coreDataStack must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"destinationFolder"] != nil, @"CDADownloadableContentModule destinationFolder must be specified");
    
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
    
    CDADownloadableContentAnalyzerModule __weak *weakSelf = self;
    [self.connector getObjectsWithSuccess:^(id responseObject) {
        if(!responseObject){
            _error = [NSError errorWithDomain:kSyncServiceDomain code:CDASyncErrorParsingResponse userInfo:@{@"message":@"No data available to be parsed"}];
            [weakSelf completeOperation];
        }else{
            NSArray *idsToDownload = [weakSelf dataIdsToDownloadData:responseObject];
            if(idsToDownload.count == 0){
                [weakSelf completeOperation];
                return;
            }
            _result = idsToDownload;
            [weakSelf completeOperation];
        }
        
    } failure:^(NSError *error) {
        _error = [error copy];
        [weakSelf completeOperation];
    }];
    
}
- (NSArray *)dataIdsToDownloadData:(NSArray *)dataToParse{

    CDADownloadableContentMapper *mapping = [[self.model userInfo] valueForKey:@"mapping"];
    NSMutableSet *remoteHashes = [NSMutableSet setWithArray:[dataToParse valueForKeyPath:mapping.remoteFileHashKey]];
    
    id<CDACoreDataStackProtocol> cdStack = [[self.model userInfo] valueForKey:@"coreDataStack"];
    NSManagedObjectContext *cdContext = [cdStack independentManagedObjectContext];
    NSArray __block *entities;
    [cdContext performBlockAndWait:^{
        entities = [cdStack fetchEntities:[mapping destinationClassName] WithSortKey:mapping.localIdentifierKey Ascending:YES WithPredicate:nil InContext:cdContext];
    }];
    
    NSSet *localHashes =[NSSet setWithArray:[entities valueForKeyPath:mapping.localFileHashKey]];
    [remoteHashes minusSet:localHashes];
    
    NSString *predicateString = [NSString stringWithFormat:@"%@ IN %@", mapping.remoteFileHashKey, @"%@"];
    NSArray *dataToDownload = [(NSArray *) dataToParse filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicateString,remoteHashes]];
    
    NSMutableArray *files = [NSMutableArray new];
    CDABGDRelationFile *relationFile;
    for (NSDictionary *entityToDownload in dataToDownload) {
        relationFile = [self.downloadCoreDataStack createNewEntity:NSStringFromClass([CDABGDRelationFile class]) inContext:[self.downloadCoreDataStack managedObjectContext]];
        relationFile.destinationFolder = [[self.model userInfo] valueForKey:@"destinationFolder"];
        relationFile.entityClass = mapping.destinationClassName;
        relationFile.entityHashKey = mapping.localFileHashKey;
        relationFile.entityIdKey = mapping.localIdentifierKey;
        relationFile.entityId = [[entityToDownload valueForKey:mapping.remoteIdentifierKey] isKindOfClass:[NSString class]] ? [entityToDownload valueForKey:mapping.remoteIdentifierKey] : [[entityToDownload valueForKey:mapping.remoteIdentifierKey] stringValue] ;
        relationFile.fileName = [entityToDownload valueForKey:mapping.remoteFileNameKey];
        relationFile.fileHash = [[entityToDownload valueForKey:mapping.remoteFileHashKey] isKindOfClass:[NSString class]] ? [entityToDownload valueForKey:mapping.remoteFileHashKey] : [[entityToDownload valueForKey:mapping.remoteFileHashKey] stringValue];
        relationFile.id = [[[self.model userInfo] valueForKey:@"resource"] stringByAppendingString:relationFile.entityId];
        
        [files addObject:relationFile];
    }
    [self.downloadCoreDataStack saveMainContext];
    
    return [files valueForKey:@"entityId"];
    
}
@end
