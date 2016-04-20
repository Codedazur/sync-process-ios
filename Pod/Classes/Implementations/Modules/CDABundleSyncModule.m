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
@property (nonatomic, strong)CDABundleConnector *connector;
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
@end
