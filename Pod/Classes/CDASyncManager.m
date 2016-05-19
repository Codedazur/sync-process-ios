//
//  CDASyncManager.m
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import "CDASyncManager.h"
#import "CDASyncScheduler.h"
#import "CDASyncExecutor.h"
#import "CDANSUserDefaultsSyncScheduleManager.h"
#import "CDASyncNotifications.h"
#import "CDAReachabilityManagerProtocol.h"
#import "CDASynConstants.h"

@interface CDASyncManager()<CDASyncSchedulerDelegate, CDASyncExecutorDelegate, CDAReachabilityManagerDelegate>
@property (nonatomic, strong) id<CDASyncSchedulerProtocol> scheduler;
@property (nonatomic, strong) id<CDASyncExecutorProtocol> executor;
@property (nonatomic, copy) NSArray<CDASyncModel> *syncModels;
@property (nonatomic, strong) id<CDAReachabilityManagerProtocol> reachability;
@property (nonatomic, strong) NSTimer *timer;
@property (nonnull, strong) NSMutableSet *erroredSyncs;
@property (nonatomic, strong) Class<CDASyncScheduleMangerProtocol> schedulerManagerClass;
@end
@implementation CDASyncManager

#pragma mark - initializers
- (instancetype)initWithSyncModels:(NSArray<CDASyncModel> *)syncs
                    SchedulerClass:(Class<CDASyncScheduleMangerProtocol>)schedulerClass
               ReachabilityManager:(id<CDAReachabilityManagerProtocol>)reachabilityManager{
    if(!(self = [super init]))return nil;
    self.syncModels = syncs;
    self.reachability = reachabilityManager;
    self.reachability.delegate = self;
    self.schedulerManagerClass = schedulerClass;
    [self setupNotifications];
    return self;
}

#pragma mark - CDASyncManagerProtocol
- (void)sync{
    [self.scheduler schedule];
}
- (void)syncForce{
    [self.scheduler forceAllSyncs];
}

#pragma mark - Lazy getters
- (NSMutableSet *)erroredSyncs{
    if(!_erroredSyncs){
        _erroredSyncs = [NSMutableSet new];
    }
    return _erroredSyncs;
}
- (id<CDASyncSchedulerProtocol>)scheduler{
    if(!_scheduler){
        _scheduler = [[CDASyncScheduler alloc] initWithSyncModels:self.syncModels
                                           AndSyncScheduleManager:[[(Class)self.schedulerManagerClass alloc] init]];
        _scheduler.delegate = self;
    }
    return _scheduler;
}
- (id<CDASyncExecutorProtocol>)executor{
    if(!_executor){
        _executor = [[CDASyncExecutor alloc] initWithSyncModels:self.syncModels];
        _executor.delegate = self;
    }
    return _executor;
}

#pragma mark - CDASyncSchedulerDelegate
- (void)CDASyncScheduler:(id<CDASyncSchedulerProtocol>)scheduler wantsToExecuteServicesWithIds:(NSArray *)serviceIds{
    if(serviceIds.count ==0)return;
    [self checkToSendFirstTimeNotification];
    [self postNotificationOnMainThreadWithName:kSyncNotificationSyncServicesStart Object:self AndUserInfo:@{kSyncMangerId:@"data-sync"}];
    [self.executor runSyncWithIds:serviceIds];
    [self startProgress];
}

#pragma mark - CDASyncExecutorDelegate
- (void)CDASyncExecutor:(id<CDASyncExecutorProtocol>)executor failedSyncWithId:(NSString *)serviceId AndErrorId:(CDASyncError)errorId{
    if (errorId == CDASyncErrorLogin) {
        [self stopProgress];
        //TODO treat login here!
    }else if(errorId == CDASyncErrorRunning){
        // do nothing
    }else if(errorId == CDASyncErrorHttp){
        [self stopProgress];
    }
    [self.erroredSyncs addObject:serviceId];
    [self postNotificationOnMainThreadWithName:kSyncNotificationError Object:self AndUserInfo:@{kSyncKeyErrorId:[NSNumber numberWithInt:errorId]}];
}
- (void)CDASyncExecutor:(id<CDASyncExecutorProtocol>)executor succeededSyncWithId:(NSString *)serviceId{
    [self.scheduler finishedSyncServiceWithId:serviceId];
    [self postNotificationOnMainThreadWithName:kSyncNotificationServiceFinishedSuccess Object:self AndUserInfo:@{kSyncKeySyncId:serviceId}];
}
- (void)CDASyncExecutorDidFinishAllSyncServices:(id<CDASyncExecutorProtocol>)executor{
    [self stopProgress];
    [self postNotificationOnMainThreadWithName:kSyncNotificationAllServicesFinished Object:self AndUserInfo:@{kSyncMangerId:@"data-sync"}];
    if(self.erroredSyncs.count <= self.syncModels.count/2.0){
        [self finishFirstSync];
    }
}

#pragma mark - CDAReachabilityManagerDelegate
- (void)CDAReachabilityManager:(id<CDAReachabilityManagerProtocol>)manager didChangeReachabilityTo:(CDAReachabilityStatus)status{
    if([self.reachability isReachable]){
        [self sync];
    }
}

#pragma mark - helpers
- (void)setupNotifications{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPullFired:) name:kSyncNotificationChronPull object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncForceAll:) name:kSyncNotificationForceAllSyncs object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onSyncForceWithId:) name:kSyncNotificationForceSyncWithId object:nil];
    
}
- (void)removeNotifications{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kSyncNotificationChronPull];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kSyncNotificationForceAllSyncs];
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:kSyncNotificationForceSyncWithId];
}
- (void)stopProgress{
    [self.timer invalidate];
    self.timer = nil;
}
- (void)startProgress{
    if(self.timer != nil)return;
    self.timer= [NSTimer scheduledTimerWithTimeInterval:0.01  target:self selector:@selector(onTimerFired:) userInfo:nil repeats:YES];
}
- (void)finishFirstSync{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:kSyncFinshedFirstSyncKey];
}
- (void)checkToSendFirstTimeNotification{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL hasFinishedFirstSync = [defaults boolForKey:kSyncFinshedFirstSyncKey];
    if(!hasFinishedFirstSync)[self postNotificationOnMainThreadWithName:kSyncNotificationIsFirstSync Object:self AndUserInfo:nil];
}

#pragma mark - actions
- (void)onSyncForceWithId:(NSNotification *)notification{
    NSString *syncId = [[notification userInfo] valueForKey:kSyncKeySyncId];
    if(syncId){
        [self.scheduler forceSyncWithId:syncId];
    }
}
- (void)onSyncForceAll:(NSNotification *)notification{
    [self syncForce];
}
- (void)onNewLogin:(NSNotification *)notification{
    [self sync];
}
- (void)onPullFired:(NSNotification *)notification{
    [self sync];
}
- (void) onTimerFired:(NSTimer *)timer{
    NSDictionary *userInfo = @{kSyncKeyProgress: @([self.executor progress]),kSyncKeyProgressBySyncId:[self.executor progressBySync],kSyncMangerId:@"data-sync", kSyncKeyBatch:@([self.executor syncBatch])};
    [self postNotificationOnMainThreadWithName:kSyncNotificationProgress Object:self AndUserInfo:userInfo];
}

- (void)postNotificationOnMainThreadWithName:(NSString *)name Object:(id)object AndUserInfo:(NSDictionary *)userInfo{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:name
                                                            object:object
                                                          userInfo:userInfo];
    });
}
@end
