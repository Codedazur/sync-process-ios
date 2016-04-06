//
//  CDASyncConnectorProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>

@protocol CDASyncConnectorProtocol <NSObject>
@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *resource;
@optional
- (double)progress;
- (void) getObjectsWithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void) getObjectWithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void) createObject:(id)object WithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void) updateObject:(id)object WithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void) deleteObject:(id)object WithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
