//
//  CDAParserSyncModule.m
//  Pods
//
//  Created by Tamara Bernad on 11/04/16.
//
//

#import "CDAParserSyncModule.h"
#import "CDASyncParserProtocol.h"
#import "CDASyncErrors.h"

@interface CDAParserSyncModule()
@property (atomic, assign) BOOL _executing;
@property (atomic, assign) BOOL _finished;
@property (nonatomic, strong)id<CDASyncParserProtocol> parser;
@property (nonatomic, strong)id<CDASyncModel> model;
@end
@implementation CDAParserSyncModule
@synthesize result = _result, error = _error;
#pragma mark - CDASyncModule
- (double)progress{
    return [self.parser progress];
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
    self.parser = [[((Class)[[self.model userInfo] valueForKey:@"parserClass"]) alloc] init];
    
    id dataToParse = [[self.model userInfo] valueForKey:@"data"] ? [[self.model userInfo] valueForKey:@"data"]: [((id<CDASyncModule>)[self.dependencies lastObject]) result];
    if(!dataToParse){
        _error = [NSError errorWithDomain:kSyncServiceDomain code:CDASyncErrorParsingResponse userInfo:@{@"message":@"No data available to be parsed"}];
        [self completeOperation];
        return;
    }
    
    CDAParserSyncModule __weak *weakSelf = self;
    [self.parser parseData:dataToParse AndCompletion:^(id result) {
        _result = result;
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
