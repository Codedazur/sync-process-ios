//
//  CDASyncExecutorProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
@protocol CDASyncServicesExecutorDelegate;

@protocol CDASyncExecutorProtocol <NSObject>
@property(nonatomic, weak) id<CDASyncServicesExecutorDelegate> delegate;
- (void)runcSyncWithIds:(NSArray *)ids;
- (double)progress;
@end

@protocol CDASyncServicesExecutorDelegate <NSObject>

- (void) CDASyncServicesExecutor:(id<CDASyncExecutorProtocol>)executor failedSyncWithId:(NSString *)serviceId AndErrorId:(CDASyncError)errorId;
- (void) CDASyncServicesExecutor:(id<CDASyncExecutorProtocol>)executor succeededSyncWithId:(NSString *)serviceId;
- (void) CDASyncServicesExecutorDidFinishAllSyncServices:(id<CDASyncExecutorProtocol>)executor;
@end