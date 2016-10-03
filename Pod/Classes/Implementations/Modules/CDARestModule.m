//
//  CDARestModule.m
//  Pods
//
//  Created by Tamara Bernad on 19/04/16.
//
//

#import "CDARestModule.h"
#import "CDASyncConnectorProtocol.h"
@interface CDARestModule()
@property (nonatomic, strong)id<CDASyncConnectorProtocol> connector;
@end
@implementation CDARestModule
@synthesize result = _result, error = _error;

#pragma mark - lazy getters
- (id<CDASyncConnectorProtocol>)connector{
    if(!_connector){
        Class cClass = [[self.model userInfo] valueForKey:@"connectorClass"];
        _connector = [cClass new];
    }
    return _connector;
}
- (instancetype)initWithSyncModel:(id<CDASyncModel>)syncModel{
    NSAssert([[syncModel userInfo] valueForKey:@"connectorClass"] != nil, @"CDARestModule connectorClass must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"baseUrl"] != nil, @"CDARestModule baseUrl must be specified");
    NSAssert([[syncModel userInfo] valueForKey:@"resource"] != nil, @"CDARestModule resource must be specified");
    return [super initWithSyncModel:syncModel];
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
    NSNumber *timeout = [[self.model userInfo] valueForKey:@"timeout"];
    if(timeout != nil){
        self.connector.timeoutInterval = [timeout copy];
    }
    
    if ([[self.model userInfo] valueForKey:@"basicAuthUser"] && [[self.model userInfo] valueForKey:@"basicAuthPassword"]) {
        self.connector.basicAuthUser = [[self.model userInfo] valueForKey:@"basicAuthUser"];
        self.connector.basicAuthPassword = [[self.model userInfo] valueForKey:@"basicAuthPassword"];
    }
    
    CDARestModule __weak *weakSelf = self;
    [self.connector getObjectsWithSuccess:^(id responseObject) {
        _result = responseObject;
        [weakSelf completeOperation];
    } failure:^(NSError *error) {
        _error = [error copy];
        [weakSelf completeOperation];
    }];
    
}

@end
