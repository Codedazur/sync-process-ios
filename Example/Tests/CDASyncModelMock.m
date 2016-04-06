//
//  CDASyncModelMock.m
//  CDASyncService
//
//  Created by Tamara Bernad on 06/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import "CDASyncModelMock.h"

@implementation CDASyncModelMock
@synthesize uid = _uid, baseUrl = _baseUrl, resource = _resource, timeInterval = _timeInterval, syncServiceClass = _syncServiceClass;
- (instancetype)initWithUid:(NSString *)uid
                    BaseUrl:(NSString *)baseUrl
                   Resource:(NSString *)resource
                  SyncClass:(Class)syncServiceClass
               timeInterval:(NSTimeInterval)timeInterval{
    if(!(self = [super init]))return self;
    _uid = uid;
    _baseUrl = baseUrl;
    _timeInterval = timeInterval;
    _resource = resource;
    _syncServiceClass = syncServiceClass;
    
    return self;
}
@end
