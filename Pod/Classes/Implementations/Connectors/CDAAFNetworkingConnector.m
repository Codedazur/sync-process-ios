//
//  CDAAFNetworkingConnector.m
//  Pods
//
//  Created by Tamara Bernad on 19/04/16.
//
//

#import "CDAAFNetworkingConnector.h"
#import <AFNetworking/AFNetworking.h>

@implementation CDAAFNetworkingConnector
@synthesize baseUrl = _baseUrl, resource = _resource, basicAuthPassword = _basicAuthPassword, basicAuthUser = _basicAuthUser;
- (void)getObjectsWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    [self getObjectsWithParameters:nil WithSuccess:success failure:failure];
}
- (void)getObjectsWithParameters:(NSDictionary *)parameters
                     WithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
    NSString *url = [[self baseUrl] stringByAppendingPathComponent:self.resource];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    if(self.basicAuthUser != nil && self.basicAuthPassword != nil)
        [manager.requestSerializer setAuthorizationHeaderFieldWithUsername:self.basicAuthUser password:self.basicAuthPassword];
        
    [manager GET:url parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        failure(error);
    }];
}
- (void)getObjectWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
}
@end
