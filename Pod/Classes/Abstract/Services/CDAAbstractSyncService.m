//
//  CDAAbstractSyncService.m
//  Pods
//
//  Created by Tamara Bernad on 25/01/16.
//
//

#import "CDAAbstractSyncService.h"
#import "CDASyncParserProtocol.h"
#import "CDASyncModule.h"

@interface CDAAbstractSyncService()
@property (nonatomic, strong)NSObject<CDASyncModel> *syncModel;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSInvocationOperation *finishOperation;
@property (nonatomic) NSInteger totalOperations;

@property (nonatomic) NSInteger currentStep;
@property (atomic, assign) BOOL _executing;
@property (atomic, assign) BOOL _finished;
@end
@implementation CDAAbstractSyncService
@synthesize delegate = _delegate, uid = _uid, result = _result, error = _error;

#pragma mark - CDASyncServiceProtocol
- (instancetype)initWithSyncModel:(NSObject<CDASyncModel> *)syncModel{
    if(!(self = [super init]))return self;

    self._executing = NO;
    self._finished = NO;
    _syncModel = syncModel;
    _uid = syncModel.uid;
    return self;
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
    
    self.currentStep = 0;
    self.queue = [NSOperationQueue new];
    self.queue.maxConcurrentOperationCount = 1;
    self.queue.suspended = YES;
    
    self.finishOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(finishedQueue:) object:nil];
    
    NSObject<CDASyncModule> *previous;
    NSObject<CDASyncModule> *current;
    int index = 0;
    CDAAbstractSyncService __weak *weakSelf = self;
    for(id<CDASyncModel> model in self.syncModel.subModuleModels){
        
        current = [[model.moduleClass alloc] initWithSyncModel:model];
        if (previous) {
            [current addDependency:previous];
        }
        
        [self.queue addOperation:(NSOperation *)current];
        previous = current;

        [self.finishOperation addDependency:(NSOperation *)current];
        
        id<CDASyncModule> __weak weakCurrent = current;
        [((NSOperation *)current) setCompletionBlock:^{
            
            if (weakSelf.queue.operationCount == 1) {
                [weakSelf _setResult:weakCurrent.result];
                [weakSelf _setError:weakCurrent.error];
            }else if (weakCurrent.error != nil) {
                [weakSelf _setError:weakCurrent.error];
                [weakSelf.queue cancelAllOperations];
                [self finish];
            }
        }];
        
        index++;
    }
    [self.queue addOperation:self.finishOperation];
    self.totalOperations = self.queue.operationCount;
    self.queue.suspended = NO;
}
- (double)progress{
    double total = 0;
    NSOperation<CDASyncModule> *current = [self.queue.operations firstObject];
    double finishedOperations = self.totalOperations - self.queue.operationCount;    
    double p = [current isKindOfClass:[NSInvocationOperation class]] ? 1 : [current progress];
    return (finishedOperations + p)/(double)self.totalOperations;
}

#pragma mark - helpers
- (void)_setResult:(id)result{
    _result =result;
}
- (void)_setError:(id)error{
    _error = error;
}
- (void)finish{
    [self completeOperation];
    if(self.error != nil){
        [self.delegate CDASyncService:self DidFinishWithError:self.error];
    }else{
        [self.delegate CDASyncServiceDidFinishWithSuccess:self AndResult:self.result];
    }
}
- (void)finishedQueue:(NSOperation *)operation{
    [self finish];
}

#pragma mark - NSOperation
- (BOOL)isConcurrent{
    return YES;
}
- (BOOL)isExecuting {
    return self._executing;
}

- (BOOL)isFinished {
    return self._finished;
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
