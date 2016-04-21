//
//  CDAArchiveDownloadProcessor.m
//  Pods
//
//  Created by Tamara Bernad on 21/04/16.
//
//

#import "CDAArchiveDownloadProcessor.h"
#import "CDASyncModel.h"
#import "CDASyncModule.h"

@implementation CDAArchiveDownloadProcessor
- (instancetype)initWithSyncModel:(id<CDASyncModel>)syncModel{
    NSAssert([[syncModel userInfo] valueForKey:@"connectorClass"] != nil, @"CDARestModule connectorClass must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"baseUrl"] != nil, @"CDARestModule baseUrl must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"resource"] != nil, @"CDARestModule resource must be specified");
    return [super initWithSyncModel:syncModel];
}
#pragma mark - CDASyncModule
- (double)progress{
    return 0;
}
- (void)main{
    if ([self isCancelled]) {
        return;
    }
    //    self.connector.baseUrl = [[self.model userInfo] valueForKey:@"baseUrl"];
    //    self.connector.resource = [[self.model userInfo] valueForKey:@"resource"];
    //
    //    CDARestModule __weak *weakSelf = self;
    //    [self.connector getObjectsWithSuccess:^(id responseObject) {
    //        _result = responseObject;
    //        [weakSelf completeOperation];
    //    } failure:^(NSError *error) {
    //        _error = [error copy];
    //        [weakSelf completeOperation];
    //    }];
    //    
}
@end
