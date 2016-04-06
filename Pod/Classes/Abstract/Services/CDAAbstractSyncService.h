//
//  CDAAbstractSyncService.h
//  Pods
//
//  Created by Tamara Bernad on 25/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncServiceProtocol.h"
#import "CDASyncConnectorProtocol.h"
#import "CDASyncParserProtocol.h"

@interface CDAAbstractSyncService : NSObject<CDASyncServiceProtocol>
@property (nonatomic, readonly)id<CDASyncConnectorProtocol> connector;
@property (nonatomic, readonly)id<CDASyncParserProtocol> parser;
@end
