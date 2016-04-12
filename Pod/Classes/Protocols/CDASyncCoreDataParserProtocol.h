//
//  CDASyncCoreDataParserProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 11/04/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncParserProtocol.h"
#import "CDAMapper.h"
#import "CDACoreDataStackProtocol.h"

@protocol CDASyncCoreDataParserProtocol <CDASyncParserProtocol>
- (instancetype)initWithMapping:(CDAMapper *)mapping AndCoreDataStack:(id<CDACoreDataStackProtocol>)coreDataStack;
@end
