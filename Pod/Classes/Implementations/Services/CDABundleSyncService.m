//
//  CDABundleSyncService.m
//  Pods
//
//  Created by Tamara Bernad on 06/04/16.
//
//

#import "CDABundleSyncService.h"
#import "CDABundleConnector.h"
#import "CDANoConversionParser.h"

@implementation CDABundleSyncService
- (instancetype)initWithSyncModel:(NSObject<CDASyncModel> *)syncModel{
    NSMutableArray *arr = [NSMutableArray new];
    
    if(!(self = [super initWithSyncModel:syncModel]))return self;
    return self;
}
@end
