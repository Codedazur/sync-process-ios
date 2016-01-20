//
//  CDASyncConnectorProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>

@protocol CDASyncConnectorProtocol <NSObject>
@optional
- (void) getObjectsWithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void) getObjectWithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void) createObject:(id)object WithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void) updateObject:(id)object WithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
- (void) deleteObject:(id)object WithSuccess:(void (^)(id responseObject))success failure:(void (^)(NSError *error))failure;
@end
