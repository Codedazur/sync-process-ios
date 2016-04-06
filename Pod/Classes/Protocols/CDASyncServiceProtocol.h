//
//  CDASyncServiceProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncErrors.h"
#import "CDASyncModel.h"

@protocol CDASyncServiceDelegate;
@protocol CDASyncServiceProtocol <NSObject>

@property (nonatomic, weak) id<CDASyncServiceDelegate> delegate;
@property (nonatomic, getter = isRunning, readonly) BOOL running;
@property (nonatomic, strong, readonly) NSString *uid;
- (instancetype) initWithSyncModel:(NSObject<CDASyncModel> *)syncModel;
- (void)start;
- (void)tearDown;
- (double)progress;
@end

@protocol CDASyncServiceDelegate <NSObject>

- (void) CDASyncServiceDidFinishWithSuccess:(id<CDASyncServiceProtocol>)syncService AndResult:(id)result;
- (void) CDASyncService:(id<CDASyncServiceProtocol>)syncService DidFinishWithErrorId:(CDASyncError)syncErrorId;
@end