//
//  CDASyncExecutor.m
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import "CDASyncExecutor.h"
#import "CDASyncServiceProtocol.h"

@interface CDASyncExecutor()<CDASyncServiceDelegate>
@property (nonatomic, copy) NSArray<CDASyncModel> *syncModels;
@property (nonatomic, strong) NSMutableDictionary *runningSyncServices;
@property (nonatomic) NSInteger syncBatch;
@end

@implementation CDASyncExecutor
@synthesize delegate = _delegate;

#pragma mark - initializers
- (instancetype)initWithSyncModels:(NSArray<CDASyncModel> *)syncs{
    if(!(self = [super init]))return nil;
    self.syncModels = syncs;
    self.syncBatch = 0;
    return self;
}

#pragma mark - CDASyncExecutorProtocol
- (BOOL) isAnySyncServiceRunning{
    return self.runningSyncServices.count > 0;
}
- (void)runSyncWithIds:(NSArray *)ids{
    if (ids.count == 0 ) {
        //TODO not so sure if that is here needed? But what if no sync process is running sync service executer would never stop
        [self checkSyncProcessCompleted];
    }
    self.syncBatch += ids.count;
    for (NSString *serviceId in ids) {
        
        if([self isSyncServiceRunningWithId:serviceId]){
            [self.delegate CDASyncExecutor:self failedSyncWithId:serviceId AndErrorId:CDASyncErrorRunning];
        }else{
            NSObject<CDASyncServiceProtocol> *syncService =[self getServiceById:serviceId];
            if (syncService == nil) {
                NSLog(@"No sync service %@ exists",serviceId);
                return;
            }
            [self.runningSyncServices setObject:syncService forKey:serviceId];
            [syncService start];
        }
    }
}
- (double)progress{
    double progress = 0;
    
    NSObject<CDASyncServiceProtocol> *syncService;
    // we want to avoid exception of "was mutated while being enumerated"
    NSMutableDictionary *runningServices = [self.runningSyncServices copy];
    for (NSString *syncServiceKey in runningServices) {
        syncService = [self.runningSyncServices objectForKey:syncServiceKey];
        progress += [syncService progress];
    }
    NSInteger finishedServices = self.syncBatch - self.runningSyncServices.count;
    finishedServices = finishedServices < 0 ? 0 : finishedServices;
    return self.syncBatch > 0 ? (finishedServices + progress)/(double)self.syncBatch : 0;
}
- (NSDictionary *)progressBySync{
    NSObject<CDASyncServiceProtocol> *syncService;
    NSMutableDictionary *servicesProgress = [NSMutableDictionary new];
    
    // we want to avoid exception of "was mutated while being enumerated"
    NSMutableDictionary *runningServices = [self.runningSyncServices copy];
    for (NSString *syncServiceKey in runningServices) {
        syncService = [self.runningSyncServices objectForKey:syncServiceKey];
        [servicesProgress setObject:@([syncService progress]) forKey:syncServiceKey];
    }
    return [NSDictionary dictionaryWithDictionary:servicesProgress];
}
#pragma mark - Lazy getters
- (NSMutableDictionary *)runningSyncServices{
    if(!_runningSyncServices)
    {
        _runningSyncServices = [[NSMutableDictionary alloc] init];
    }
    return _runningSyncServices;
}

#pragma mark - helpers
- (NSObject<CDASyncServiceProtocol> *)getServiceById:(NSString *)syncId{
    
    id<CDASyncModel> model = [[self.syncModels filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"uid = %@",syncId]] firstObject];
    NSObject<CDASyncServiceProtocol> *syncService = [[(Class)model.moduleClass alloc] initWithSyncModel:model];
    syncService.delegate = self;
    return syncService;
}
- (BOOL) isSyncServiceRunningWithId:(NSString *)syncId{
    return [[self.runningSyncServices allKeys] containsObject:syncId];
}
- (void)checkSyncProcessCompleted{
    if (self.runningSyncServices.count == 0) {
        self.syncBatch = 0;
        [self.delegate CDASyncExecutorDidFinishAllSyncServices:self];
    }
}
- (void)stopSyncService:(NSObject<CDASyncServiceProtocol> *)syncService{
    if([self isSyncServiceRunningWithId:[syncService uid]])[self.runningSyncServices removeObjectForKey:[syncService uid]];
}
#pragma mark - CDASyncServiceDelegate
- (void)CDASyncService:(NSObject<CDASyncServiceProtocol> *)syncService DidFinishWithError:(NSError *)error{
    [self.delegate CDASyncExecutor:self failedSyncWithId:[syncService uid] AndErrorId:(int)error.code];
    [self stopSyncService:syncService];
    [self checkSyncProcessCompleted];
}
- (void)CDASyncServiceDidFinishWithSuccess:(NSObject<CDASyncServiceProtocol> *)syncService AndResult:(id)result
{
    [self.delegate CDASyncExecutor:self succeededSyncWithId:[syncService uid]];
    [self stopSyncService:syncService];
    [self checkSyncProcessCompleted];
}
@end
