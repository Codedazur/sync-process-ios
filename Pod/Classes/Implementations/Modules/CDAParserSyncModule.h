//
//  CDAParserSyncModule.h
//  Pods
//
//  Created by Tamara Bernad on 11/04/16.
//
//

#import <Foundation/Foundation.h>

#import "CDASyncModule.h"
@interface CDAParserSyncModule : NSOperation<CDASyncModule>
@property (nonatomic, strong, readonly)id<CDASyncModel> model;
@end
