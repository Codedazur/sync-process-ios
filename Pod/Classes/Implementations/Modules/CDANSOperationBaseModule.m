//
//  CDANSOperationBaseModule.m
//  Pods
//
//  Created by Tamara Bernad on 19/04/16.
//
//

#import "CDANSOperationBaseModule.h"
@interface CDANSOperationBaseModule()

@property (atomic, assign) BOOL _executing;
@property (atomic, assign) BOOL _finished;
@property (nonatomic, strong)id<CDASyncModel> model;
@end
@implementation CDANSOperationBaseModule
@synthesize result = _result, error = _error;

#pragma mark - CDASyncModule
- (double)progress{
    return 0;
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
- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    self._executing = NO;
    self._finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}
@end
