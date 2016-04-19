//
//  CDAAFNetworkingConnector.m
//  Pods
//
//  Created by Tamara Bernad on 19/04/16.
//
//

#import "CDAAFNetworkingConnector.h"
#import "AFHTTPRequestOperation.h"

@implementation CDAAFNetworkingConnector
- (void)getObjectsWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[self baseUrl]]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
    }];
}
- (void)getObjectWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
}
@end
