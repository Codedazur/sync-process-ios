//
//  CDABundleConnector.m
//  Pods
//
//  Created by Tamara Bernad on 06/04/16.
//
//

#import "CDABundleConnector.h"

@implementation CDABundleConnector
@synthesize baseUrl = _baseUrl, resource = _resource;

- (void)getObjectsWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    NSString * filePath =[[NSBundle mainBundle] pathForResource:self.resource ofType:@"json"];
    NSError * error;
    NSString* fileContents =[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    
    
    if(error)
    {
        NSLog(@"Error reading file: %@",error.localizedDescription);
        failure([error copy]);
        return;
    }
    
    
    NSArray *dataList = (NSArray *)[NSJSONSerialization
                                JSONObjectWithData:[fileContents dataUsingEncoding:NSUTF8StringEncoding]
                                options:0 error:NULL];
    success(dataList);
}
- (void)getObjectWithSuccess:(void (^)(id))success failure:(void (^)(NSError *))failure{
    
}
@end
