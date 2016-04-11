//
//  CDASimpleSyncModel.m
//  Pods
//
//  Created by Tamara Bernad on 11/04/16.
//
//

#import "CDASimpleSyncModel.h"

@implementation CDASimpleSyncModel
@synthesize userInfo = _userInfo, moduleClass = _moduleClass, timeInterval = _timeInterval, uid = _uid, subModuleModels = _subModuleModels;
- (instancetype)initWithUid:(NSString *)uid moduleClass:(Class)moduleClass userInfo:(NSDictionary *)userInfo timeInterval:(NSTimeInterval)timeInterval{
    if(!(self = [super init]))return self;
    _uid = uid;
    _userInfo = userInfo;
    _moduleClass = moduleClass;
    _timeInterval = timeInterval;
    return self;
}
- (instancetype)initWithUid:(NSString *)uid moduleClass:(Class)moduleClass userInfo:(NSDictionary *)userInfo subModuleModels:(NSArray<CDASyncModel> *)subModuleModels timeInterval:(NSTimeInterval)timeInterval{
    if(!(self = [self initWithUid:uid moduleClass:moduleClass userInfo:userInfo timeInterval:timeInterval]))return self;
    _subModuleModels = subModuleModels;
    return self;
}
@end
