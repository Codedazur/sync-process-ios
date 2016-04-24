//
//  CDADownloadableContentModule.m
//  Pods
//
//  Created by Tamara Bernad on 24/04/16.
//
//

#import "CDADownloadableContentModule.h"
#import "CDASyncConnectorProtocol.h"
#import "CDASyncErrors.h"
#import "CDADownloadableContentMapper.h"
#import "CDACoreDataStackProtocol.h"

@interface CDADownloadableContentModule()
@property (nonatomic, strong)id<CDASyncConnectorProtocol> connector;
@end

@implementation CDADownloadableContentModule
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
    
    CDADownloadableContentModule __weak *weakSelf = self;
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
        entities = [cdStack fetchEntities:NSStringFromClass([mapping destinationClass]) WithSortKey:mapping.localIdentifierKey Ascending:YES WithPredicate:nil InContext:cdContext];
    }];
    
    NSSet *localHashes =[NSSet setWithArray:[entities valueForKeyPath:mapping.localFileHashKey]];
    [remoteHashes minusSet:localHashes];
    
    NSString *predicateString = [NSString stringWithFormat:@"%@ == %@", mapping.remoteFileHashKey, @"%@"];
    NSArray *dataToDownload = [(NSArray *) dataToParse filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:predicateString]];
    
    return [dataToDownload valueForKeyPath:mapping.remoteIdentifierKey];
    
}
@end
