//
//  CDACoreDataParserSyncModule.m
//  Pods
//
//  Created by Tamara Bernad on 11/04/16.
//
//

#import "CDACoreDataParserSyncModule.h"
#import "CDASyncParserProtocol.h"
#import "CDASyncCoreDataParserProtocol.h"

@implementation CDACoreDataParserSyncModule
- (id<CDASyncCoreDataParserProtocol>)instanciateParser{
    NSDictionary *userInfo = [self.model userInfo];
    NSAssert([userInfo valueForKey:@"coreDataStack"] != nil, @"Value of coreDataStack must be present in userInfo");
    NSAssert([[self.model userInfo] valueForKey:@"mapping"] != nil, @"Value of mapping must be present in userInfo");
    NSAssert([[[self.model userInfo] valueForKey:@"mapping"] isKindOfClass:[CDAMapper class]], [@"mapping must be of type %@" stringByAppendingString:NSStringFromClass([CDAMapper class])]);
    NSAssert([[[self.model userInfo] valueForKey:@"coreDataStack"] conformsToProtocol:@protocol(CDACoreDataStackProtocol)], [@"coreDataStack must conform to %@" stringByAppendingString:NSStringFromProtocol(@protocol(CDACoreDataStackProtocol))]);
    
    return [[((Class)[[self.model userInfo] valueForKey:@"parserClass"]) alloc] initWithMapping:[[self.model userInfo] valueForKey:@"mapping"] AndCoreDataStack:[[self.model userInfo] valueForKey:@"coreDataStack"]];
}
@end
