//
//  CDARestKitCoreDataParser.h
//  Pods
//
//  Created by Tamara Bernad on 08/04/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncParserProtocol.h"
#import "CDAMapper.h"
#import "CDACoreDataStackProtocol.h"

@interface CDARestKitCoreDataParser : NSObject<CDASyncParserProtocol>
- (instancetype)initWithMapping:(CDAMapper *)mapping AndCoreDataStack:(id<CDACoreDataStackProtocol>)coreDataStack;
@end
