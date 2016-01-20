//
//  CDASyncSchedulerProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>

@protocol CDASyncSchedulerDelegate <NSObject>
@property (nonatomic, weak) id<CDASyncSchedulerDelegate> delegate;
- (void)schedule;
- (void)forceAllSyncs;
- (void)finishSyncServiceWithId:(NSString *)syncServiceUid;
- (void)forceSyncWithId:(NSString *)syncId;
- (NSArray *)allSyncServicesIds;
@end

@protocol CDASyncSchedulerDelegate <NSObject>

- (void) CDASyncSchedulerDelegate:(<CDASyncSchedulerProtocol>)scheduler wantsToExecuteServicesWithIds:(NSArray *)serviceIds;

@end