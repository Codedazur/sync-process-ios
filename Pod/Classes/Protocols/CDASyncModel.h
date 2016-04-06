//
//  CDASyncModel.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncConnectorProtocol.h"
#import "CDASyncParserProtocol.h"

@protocol CDASyncModel <NSObject>

@property (nonatomic, strong, readonly) NSString *uid;
@property (nonatomic, strong, readonly) Class syncServiceClass;
@property (nonatomic, readonly) NSTimeInterval timeInterval;
- (NSArray<CDASyncParserProtocol> *)getParsers;
- (NSArray<CDASyncConnectorProtocol> *)getConnectors;
- (id<CDASyncParserProtocol> )getParser;
- (id<CDASyncConnectorProtocol> )getConnector;
@end
