//
//  CDASyncFileHelper.m
//  Pods
//
//  Created by Tamara Bernad on 09/05/16.
//
//

#import "CDASyncFileHelper.h"

@implementation CDASyncFileHelper
+ (NSString *)documentsFolderPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths firstObject];
}
@end
