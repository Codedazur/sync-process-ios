//
//  CDASyncParserProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>

@protocol CDASyncParserProtocol <NSObject>
@property (nonatomic, strong) NSString *uid;
- (void)parseData:(id)data AndCompletion:(void (^)(id result))completion;
- (double)progress;

@optional
- (void)decodeData:(id)data AndCompletion:(void (^)(id result))completion;
@end
