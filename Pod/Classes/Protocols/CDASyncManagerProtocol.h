//
//  CDASyncManagerProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncModel.h"

@protocol CDASyncManagerProtocol <NSObject>
//TODO rename this method
- (instancetype)initWithSyncModels:(NSArray<CDASyncModel> *)syncs;
- (void)sync;
- (void)syncForce;
@end
