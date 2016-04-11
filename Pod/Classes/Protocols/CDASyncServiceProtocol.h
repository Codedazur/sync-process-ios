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

#import "CDASyncModule.h"

@protocol CDASyncServiceDelegate;
@protocol CDASyncServiceProtocol <CDASyncModule>
@property (nonatomic, strong, readonly) NSString *uid;

@property (nonatomic, weak) id<CDASyncServiceDelegate> delegate;
- (instancetype) initWithSyncModel:(NSObject<CDASyncModel> *)syncModel;
@end

@protocol CDASyncServiceDelegate <NSObject>

- (void) CDASyncServiceDidFinishWithSuccess:(id<CDASyncServiceProtocol>)syncService AndResult:(id)result;
- (void) CDASyncService:(id<CDASyncServiceProtocol>)syncService DidFinishWithErrorId:(CDASyncError)syncErrorId;
@end