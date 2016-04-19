//
//  CDACoreDataStack.h
//  Pods
//
//  Created by Tamara Bernad on 12/04/16.
//
//

#import <Foundation/Foundation.h>
#import "CDACoreDataStackProtocol.h"
@interface CDACoreDataStack : NSObject<CDACoreDataStackProtocol>
- (instancetype)initWithModelName:(NSString *)modelName AndBundle:(NSBundle *)bundle;
@end
