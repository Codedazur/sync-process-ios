//
//  CDASyncChron.h
//  Pods
//
//  Created by Tamara Bernad on 06/05/16.
//
//

#import <Foundation/Foundation.h>

@interface CDASyncChron : NSObject
- (instancetype)initWithInterval:(NSTimeInterval)timeInterval;
- (void)start;
@end
