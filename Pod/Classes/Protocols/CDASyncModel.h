//
//  CDASyncModel.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>

@protocol CDASyncModel <NSObject>

@property (nonatomic, strong, readonly) NSString *uid;
@property (nonatomic, strong, readonly) NSDictionary *userInfo;;
@property (nonatomic, strong, readonly) Class moduleClass;
@property (nonatomic, strong, readonly) NSArray<CDASyncModel> *subModuleModels;
@property (nonatomic, readonly) NSTimeInterval timeInterval;

- (instancetype)initWithUid:(NSString *)uid
                  moduleClass:(Class)moduleClass
                   userInfo:(NSDictionary *)userInfo
               timeInterval:(NSTimeInterval)timeInterval;
@end
