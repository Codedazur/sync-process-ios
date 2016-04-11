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
@property (nonatomic, strong)NSArray<CDASyncModule> *modules;
@property (nonatomic, strong)NSObject<CDASyncModel> *syncModel;
@property (nonatomic, strong) NSOperationQueue *queue;

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
    
    NSObject<CDASyncModule> *previous;
    NSObject<CDASyncModule> *current;
    for(id<CDASyncModel> model in self.syncModel.subModuleModels){
        
        current = [[model.moduleClass alloc] initWithSyncModel:model];
        if (previous) {
            [current addDependency:previous];
        }
        
        [self.queue addOperation:(NSOperation *)current];
        previous = current;
    }
}
- (double)progress{
    double total = 0;
    for (id<CDASyncModule> module in self.modules) {
        total += [module progress];
    }
    return total/(double)[self nSteps];
}

#pragma mark - helpers
- (NSInteger)nSteps{
    return self.modules.count;
}
- (id<CDASyncModule>)currentSyncModule{
    if(self.modules.count == 0)return nil;
    return [self.modules objectAtIndex:self.currentStep];
}
//- (void) finishWithErrorId:(CDASyncError)errorId{
//    [self completeOperation];
//    [self.delegate CDASyncService:self DidFinishWithErrorId:errorId];
//}
//- (void) finishWithSuccessAndResult:(id)result{
//    [self completeOperation];
//    [self.delegate CDASyncServiceDidFinishWithSuccess:self AndResult:result];
//}

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
