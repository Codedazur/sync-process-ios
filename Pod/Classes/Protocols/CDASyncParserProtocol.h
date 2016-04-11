//
//  CDASyncParserProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
@protocol CDASyncParserProtocol
@property (nonatomic, strong) NSString *uid;

- (double)progress;
- (void)parseData:(id)data AndCompletion:(void (^)(id result))completion;
@end