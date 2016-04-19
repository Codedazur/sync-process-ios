//
//  CDANSOperationBaseModule.h
//  Pods
//
//  Created by Tamara Bernad on 19/04/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncModule.h"
#import "CDASyncModel.h"
@interface CDANSOperationBaseModule : NSOperation<CDASyncModule>
- (void)completeOperation;
- (id<CDASyncModel>)model;
@end
