//
//  CDAAFNetworkingReachabilityManager.m
//  Pods
//
//  Created by Tamara Bernad on 04/05/16.
//
//

#import "CDAAFNetworkingReachabilityManager.h"

#import <AFNetworking/AFNetworking.h>
@implementation CDAAFNetworkingReachabilityManager
@synthesize delegate = _delegate;

- (BOOL)isReachable{
     return [AFNetworkReachabilityManager sharedManager].isReachable;
}
- (BOOL)isReachableViaWWAN{
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
}
- (BOOL)isReachableViaWiFi{
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
}
+ (instancetype)sharedManger{
    static CDAAFNetworkingReachabilityManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}
-(void)setupBlock {
    CDAAFNetworkingReachabilityManager __weak *weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        CDAReachabilityStatus iStatus;
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                iStatus = CDAReachabilityStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                iStatus = CDAReachabilityStatusReachableViaWiFi;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                iStatus = CDAReachabilityStatusReachableViaWWAN;
                break;
            default:
                iStatus = CDAReachabilityStatusUnknown;
                break;
        }
        [weakSelf.delegate CDAReachabilityManager:weakSelf didChangeReachabilityTo:iStatus];
    }];
}
- (void)startMonitoring{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}
@end
