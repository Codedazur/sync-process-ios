//
//  CDAAbstractSyncService.m
//  Pods
//
//  Created by Tamara Bernad on 25/01/16.
//
//

#import "CDAAbstractSyncService.h"
#import "CDASyncParserProtocol.h"

@interface CDAAbstractSyncService()
@end
@implementation CDAAbstractSyncService
@synthesize delegate = _delegate, running = _running, uid = _uid;

#pragma mark - CDASyncServiceProtocol
- (instancetype)initWithSyncModel:(NSObject<CDASyncModel> *)syncModel{
    if(!(self = [super init]))return self;
    _uid = syncModel.uid;
    return self;
}
- (void)start{
    _running = YES;
    [self retrieveData];
}
- (void)tearDown{
    
}
- (double)progress{
    return ([self.connector progress] + [self.parser progress])/2.0;
}

#pragma mark - helpers
- (void)finish{
    _running = NO;
}
- (void) finishWithErrorId:(CDASyncError)errorId{
    [self finish];
    [self.delegate CDASyncService:self DidFinishWithErrorId:errorId];
}
- (void) finishWithSuccessAndResult:(id)result{
    [self finish];
    [self.delegate CDASyncServiceDidFinishWithSuccess:self AndResult:result];
}
- (void)retrieveData{
    [self.connector getObjectsWithSuccess:^(id responseObject) {
        [self.parser parseData:responseObject AndCompletion:^(id result) {
            [self finishWithSuccessAndResult:result];
        }];
    } failure:^(NSError *error) {
        [self finishWithErrorId:(CDASyncError)error.code];
    }];
}
@end
