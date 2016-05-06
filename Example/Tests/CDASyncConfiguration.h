//
//  CDASyncConfiguration.h
//  CDASyncService
//
//  Created by Tamara Bernad on 04/05/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CDASyncModel.h"
#import "CDACoreDataStackProtocol.h"
#import "CDASimpleSyncModel.h"

@interface CDASyncConfiguration : NSObject
+ (NSArray<CDASyncModel> *)syncConfig:(id<CDACoreDataStackProtocol>)stack;
+ (CDASimpleSyncModel *)mediaDownoadWithStack:(id<CDACoreDataStackProtocol>)stack;
@end
