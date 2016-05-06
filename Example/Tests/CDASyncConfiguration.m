//
//  CDASyncConfiguration.m
//  CDASyncService
//
//  Created by Tamara Bernad on 04/05/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import "CDASyncConfiguration.h"
#import "CDASyncModel.h"
#import "CDASimpleSyncModel.h"
#import "CDAMapper.h"
#import "CDACoreDataStack.h"
#import "CDARestModule.h"
#import "CDAAFNetworkingConnector.h"
#import "CDACoreDataParserSyncModule.h"
#import "CDARestKitCoreDataParser.h"
#import "CDAAbstractSyncService.h"
#import "ContentItem.h"
#import "Language.h"
#import "MediaPage.h"
#import "Media.h"
#import "CDADownloadableContentAnalyzerModule.h"
#import "CDADownloadableContentRetrieverModule.h"
#import "CDADownloadableContentMapper.h"
@implementation CDASyncConfiguration
+ (NSString *)baseUrl{
    return @"http://staging.trainingbinder.kvadrat.dk/api";
}
+ (NSString *)user{
    return  @"ktb_@&3App";
}
+ (NSString *)pass{
    return @"8mGpzDNR52KQJt5VwQeUqpMJztML6X9j";
}
+ (CDASimpleSyncModel *)mediaSyncModelWithStack:(id<CDACoreDataStackProtocol>)stack{
    CDAMapper *m = [CDAMapper new];
    m.attributesMapping = @{@"id":@"id",
                            @"contentItemId":@"contentItemId",
                            @"type":@"type",
                            @"url":@"url",
                            @"languageId":@"languageId",
                            @"pages":@"pages",
                            @"fileName":@"fileName"};
    m.destinationClassName = NSStringFromClass([Media class]);
    m.localIdentifierKey = @"id";
    return [CDASyncConfiguration symModelWithId:@"media" Resource:@"media" Mapper:m AndCoreDataStack:stack];
    
}
+ (CDASimpleSyncModel *)mediaPagesSyncModel:(id<CDACoreDataStackProtocol>)stack{
    CDAMapper *m = [CDAMapper new];
    m.attributesMapping = @{@"id":@"id",
                            @"text":@"text",
                            @"page":@"page",
                            @"mediaId":@"mediaId",
                            @"contentItemId":@"contentItemId"};
    m.destinationClassName = NSStringFromClass([MediaPage class]);
    m.localIdentifierKey = @"id";
    return [CDASyncConfiguration symModelWithId:@"pages" Resource:@"pages" Mapper:m AndCoreDataStack:stack];
    
}
+ (CDASimpleSyncModel *)languagesSyncModel:(id<CDACoreDataStackProtocol>)stack{
    CDAMapper *m = [CDAMapper new];
    m.attributesMapping = @{@"id":@"id",
                            @"name":@"name"};
    m.destinationClassName = NSStringFromClass([Language class]);
    m.localIdentifierKey = @"id";
    return [CDASyncConfiguration symModelWithId:@"languages" Resource:@"languages" Mapper:m AndCoreDataStack:stack];
    
}
+ (CDASimpleSyncModel *)contentItemsSyncModelWithStack:(id<CDACoreDataStackProtocol>)stack{
    CDAMapper *m = [CDAMapper new];
    m.attributesMapping = @{@"id":@"id",
                           @"name":@"name",
                           @"canSend":@"canSend",
                           @"isDefault":@"isDefault",
                           @"order":@"order",
                           @"parentId":@"parentId",
                           @"rootId":@"rootId",
                           @"thumbnailMediaId":@"thumbnailMediaId",
                           @"treePath":@"treePath",
                           @"type":@"type",
                            @"url":@"url"};
    m.destinationClassName = NSStringFromClass([ContentItem class]);
    m.localIdentifierKey = @"id";
    return [CDASyncConfiguration symModelWithId:@"items" Resource:@"items" Mapper:m AndCoreDataStack:stack];
   
}
+ (CDASimpleSyncModel *) symModelWithId:(NSString *)uid Resource:(NSString *)resource Mapper:(CDAMapper *)mapper AndCoreDataStack:(id<CDACoreDataStackProtocol>)coreDataStack{
    
    CDASimpleSyncModel *smConnect = [[CDASimpleSyncModel alloc] initWithUid:[@"retrieve-data-" stringByAppendingString:resource] moduleClass:[CDARestModule class] userInfo:@{@"baseUrl":[CDASyncConfiguration baseUrl],@"resource":resource,@"connectorClass":[CDAAFNetworkingConnector class], @"basicAuthUser":[CDASyncConfiguration user], @"basicAuthPassword":[CDASyncConfiguration pass]} timeInterval:0];
    
    CDASimpleSyncModel *smParse = [[CDASimpleSyncModel alloc] initWithUid:[@"parse-data-" stringByAppendingString:resource] moduleClass:[CDACoreDataParserSyncModule class] userInfo:@{@"parserClass":[CDARestKitCoreDataParser class],@"coreDataStack":coreDataStack,@"mapping":mapper} timeInterval:0];
    
    CDASimpleSyncModel *smService = [[CDASimpleSyncModel alloc] initWithUid:uid moduleClass:[CDAAbstractSyncService class] userInfo:nil subModuleModels:@[smConnect, smParse] timeInterval:60*60*24];
    
    return smService;
}
+ (NSArray<CDASyncModel> *)syncConfig:(id<CDACoreDataStackProtocol>)stack{
    return @[[CDASyncConfiguration contentItemsSyncModelWithStack:stack],[CDASyncConfiguration languagesSyncModel:stack], [CDASyncConfiguration mediaPagesSyncModel:stack],[CDASyncConfiguration mediaSyncModelWithStack:stack]];
    
}
+ (CDASimpleSyncModel *)mediaDownloaderWithStack:(id<CDACoreDataStackProtocol>)stack{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *folder = [[paths firstObject] stringByAppendingPathComponent:@"download-temp"];
    
    NSDictionary *userInfo =@{@"baseUrl":[CDASyncConfiguration baseUrl],
                              @"resource":@"downloads",
                              @"connectorClass":[CDAAFNetworkingConnector class],
                              @"basicAuthUser":[CDASyncConfiguration user],
                              @"basicAuthPassword":[CDASyncConfiguration pass],
                              @"coreDataStack":stack,
                              @"data":@[@1,@2,@3],
                              @"mapping":[CDASyncConfiguration downloadMapper],
                              @"identifier":@"123456",
                              @"destinationFolder":folder};
    
    CDASimpleSyncModel *smAnalyze = [[CDASimpleSyncModel alloc] initWithUid:@"analyze" moduleClass:[CDADownloadableContentAnalyzerModule class] userInfo:userInfo timeInterval:0];
    
    return smAnalyze;

}
+ (CDASimpleSyncModel *)mediaDownoadWithStack:(id<CDACoreDataStackProtocol>)stack{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *folder = [[paths firstObject] stringByAppendingPathComponent:@"media"];
    
    
    NSDictionary *userInfo =@{@"baseUrl":[CDASyncConfiguration baseUrl],
                              @"resource":@"media",
                              @"connectorClass":[CDAAFNetworkingConnector class],
                              @"basicAuthUser":[CDASyncConfiguration user],
                              @"basicAuthPassword":[CDASyncConfiguration pass],
                              @"mapping":[CDASyncConfiguration downloadMapper],
                              @"coreDataStack":stack,
                              @"destinationFolder":folder};
    
    CDASimpleSyncModel *smAnalyze = [[CDASimpleSyncModel alloc] initWithUid:@"analyze" moduleClass:[CDADownloadableContentAnalyzerModule class] userInfo:userInfo timeInterval:0];

    return smAnalyze;
}
+(CDADownloadableContentMapper *)downloadMapper{
    CDADownloadableContentMapper *m = [CDADownloadableContentMapper new];
    
    m.destinationClassName = NSStringFromClass([Media class]);
    m.remoteFileNameKey = @"fileName";
    m.remoteIdentifierKey = @"id";
    m.remoteFileHashKey = @"fileHash";
    m.localFileHashKey = @"fileHash";
    m.localFileNameKey = @"fileName";
    m.localIdentifierKey = @"id";
    return m;
}
@end
