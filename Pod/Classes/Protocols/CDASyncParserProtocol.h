//
//  CDASyncParserProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#import "CDASyncModule.h"
@protocol CDASyncParserProtocol <CDASyncModule>
@property (nonatomic, strong) NSString *uid;

- (void)parseData:(id)data AndCompletion:(void (^)(id result))completion;
@end