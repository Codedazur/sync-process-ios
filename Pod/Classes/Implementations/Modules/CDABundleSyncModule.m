//
//  CDABundleSyncModule.m
//  Pods
//
//  Created by Tamara Bernad on 11/04/16.
//
//

#import "CDABundleSyncModule.h"
#import "CDABundleConnector.h"
@interface CDABundleSyncModule()

@property (atomic, assign) BOOL _executing;
@property (atomic, assign) BOOL _finished;
@property (nonatomic, strong)CDABundleConnector *connector;
@property (nonatomic, strong)id<CDASyncModel> model;
@end
@implementation CDABundleSyncModule
@synthesize result = _result, error = _error;

#pragma mark - lazy getters
- (CDABundleConnector *)connector{
    if(!_connector){
        _connector = [CDABundleConnector new];
    }
    return _connector;
}
#pragma mark - CDASyncModule
- (double)progress{
    return [self.connector progress];
}
#pragma mark - NSOperation
- (id)initWithSyncModel:(id<CDASyncModel>)syncModel{
    if(!(self = [super init]))return self;
    self._executing = NO;
    self._finished = NO;
    self.model = syncModel;
    return self;
}
- (BOOL)isConcurrent{
    return YES;
}
- (BOOL)isExecuting {
    return self._executing;
}

- (BOOL)isFinished {
    return self._finished;
}

- (void)start{
    if ([self isCancelled])
    {
        // Must move the operation to the finished state if it is canceled.
        [self willChangeValueForKey:@"isFinished"];
        self._finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    [self willChangeValueForKey:@"isExecuting"];
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    self._executing = YES;
    [self didChangeValueForKey:@"isExecuting"];
}
- (void)main{
    if ([self isCancelled]) {
        return;
    }
    self.connector.baseUrl = [[self.model userInfo] valueForKey:@"baseUrl"];
    self.connector.resource = [[self.model userInfo] valueForKey:@"resource"];
    
    CDABundleSyncModule __weak *weakSelf = self;
    [self.connector getObjectsWithSuccess:^(id responseObject) {
        _result = responseObject;
        [weakSelf completeOperation];
    } failure:^(NSError *error) {
        _error = [error copy];
        [weakSelf completeOperation];
    }];

}
- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    self._executing = NO;
    self._finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}
@end
