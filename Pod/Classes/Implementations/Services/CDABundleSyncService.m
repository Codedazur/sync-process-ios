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
@synthesize connector = _connector, parser = _parser;
- (instancetype)initWithSyncModel:(NSObject<CDASyncModel> *)syncModel{
    if(!(self = [super initWithSyncModel:syncModel]))return self;
    _connector = [CDABundleConnector new];
    [_connector setResource:syncModel.resource];
    _parser = [CDANoConversionParser new];
    return self;
}
@end
