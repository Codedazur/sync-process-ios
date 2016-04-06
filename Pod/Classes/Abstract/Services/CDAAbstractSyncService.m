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
@property (nonatomic, strong)id<CDASyncConnectorProtocol> connector;
@property (nonatomic, strong)id<CDASyncParserProtocol> parser;
@end
@implementation CDAAbstractSyncService
@synthesize delegate = _delegate, running = _running, uid = _uid;

#pragma mark - CDASyncServiceProtocol
- (instancetype)initWithUid:(NSString *)uid AndSyncModel:(NSObject<CDASyncModel> *)syncModel{
    if(!(self = [super init]))return self;
    _uid = uid;
    self.connector = [syncModel getConnector];
    self.parser = [syncModel getParser];
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
- (void) finishWithSuccess{
    [self finish];
    [self.delegate CDASyncServiceDidFinishWithSuccess:self];
}
- (void)retrieveData{
    [self.connector getObjectsWithSuccess:^(id responseObject) {
        [self.parser parseData:responseObject AndCompletion:^(id result) {
            [self finishWithSuccess];
        }];
    } failure:^(NSError *error) {
        [self finishWithErrorId:(CDASyncError)error.code];
    }];
}
@end
