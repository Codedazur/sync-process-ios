//
//  CDASyncModule.h
//  Pods
//
//  Created by Tamara Bernad on 08/04/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncModel.h"

@protocol CDASyncModule <NSObject>
NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, strong, readonly) NSObject *result;
@property (nonatomic, strong, readonly) NSError *error;
NS_ASSUME_NONNULL_END
@property (readonly, getter=isCancelled) BOOL cancelled;
@property (readonly, getter=isExecuting) BOOL executing;
@property (readonly, getter=isFinished) BOOL finished;

- (void)addDependency:(nonnull id<CDASyncModule>)md;
- (void)removeDependency:(nonnull id<CDASyncModule>)md;

- (void)start;
- (void)cancel;
- (double)progress;

@property (nullable, copy) void (^completionBlock)(void);

- (instancetype)initWithSyncModel:(id<CDASyncModel>)syncModel;
@end
