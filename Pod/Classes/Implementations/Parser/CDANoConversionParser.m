//
//  CDANoConversionParser.m
//  Pods
//
//  Created by Tamara Bernad on 06/04/16.
//
//

#import "CDANoConversionParser.h"

@implementation CDANoConversionParser
@synthesize uid = _uid;
- (double)progress{
    return 0;
}
- (void)parseData:(id)data AndCompletion:(void (^)(id))completion{
    completion([data copy]);
}
@end
