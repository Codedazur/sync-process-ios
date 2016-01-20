//
//  CDASyncServiceProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncError.h"


@protocol CDASyncServiceProtocol <NSObject>
@property (nonatomic, getter = isRunning, readonly) BOOL running;
@property (nonatomic, strong, readonly) NSString *uid;

- (void)start;
- (double)progress;
@end

@protocol CDASyncServiceDelegate <NSObject>

- (void) CDASyncServiceDidFinishWithSuccess:(id<CDASyncServiceProtocol>)syncService;
- (void) CDASyncService:(id<CDASyncServiceProtocol>)syncService DidFinishWithErrorId:(CDASyncError)syncErrorId;
@end