//
//  CDAAFNetworkingConnector.m
//  Pods
//
//  Created by Tamara Bernad on 19/04/16.
//
//

#import "CDAAFNetworkingConnector.h"
#import <AFNetworking/AFNetworking.h>

@interface CDAAFNetworkingConnector()
@property(nonatomic)double _progress;
@end
@implementation CDAAFNetworkingConnector
@synthesize baseUrl = _baseUrl, resource = _resource, basicAuthPassword = _basicAuthPassword, basicAuthUser = _basicAuthUser, timeoutInterval = _timeoutInterval;
- (double)progress{
    return self._progress;
}
- (void)getObjectsWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    [self getObjectsWithParameters:nil WithSuccess:success failure:failure];
}
- (void)getObjectsWithParameters:(NSDictionary *)parameters
                     WithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
    self._progress = 0.0;
    NSString *url = [[self baseUrl] stringByAppendingPathComponent:self.resource];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if(self.timeoutInterval != nil) [manager.requestSerializer setTimeoutInterval:self.timeoutInterval.doubleValue];
    if(self.basicAuthUser != nil && self.basicAuthPassword != nil)
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.basicAuthUser password:self.basicAuthPassword];
    
    CDAAFNetworkingConnector __weak *weakSelf = self;
    [manager GET:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {;
    } success:^(NSURLSessionTask *task, id responseObject) {
        weakSelf._progress = 1.0;
        success(responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        failure(error);
    }];
}
- (void)createObjectWithParameters:(NSDictionary *)parameters WithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    self._progress = 0.0;
    NSString *url = [[self baseUrl] stringByAppendingPathComponent:self.resource];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    if(self.timeoutInterval != nil) [manager.requestSerializer setTimeoutInterval:self.timeoutInterval.doubleValue];
    if(self.basicAuthUser != nil && self.basicAuthPassword != nil)
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.basicAuthUser password:self.basicAuthPassword];
    
    CDAAFNetworkingConnector __weak *weakSelf = self;
    
    [manager POST:url parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {;
    } success:^(NSURLSessionTask *task, id responseObject) {
        weakSelf._progress = 1.0;
        success(responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        failure(error);
    }];
}
- (void)getObjectWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
}
@end
