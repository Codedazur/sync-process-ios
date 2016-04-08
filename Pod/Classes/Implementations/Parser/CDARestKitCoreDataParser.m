//
//  CDARestKitCoreDataParser.m
//  Pods
//
//  Created by Tamara Bernad on 08/04/16.
//
//

#import "CDARestKitCoreDataParser.h"
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>
#import "CDAMapper.h"
#import "CDARelationMapping.h"
#import "CDACoreDataStackProtocol.h"
typedef void(^ParseCompletionBlock)(id result);

@interface CDARestKitCoreDataParser()<RKMapperOperationDelegate>
@property (nonatomic, strong)NSManagedObjectContext *context;
@property (nonatomic, copy) ParseCompletionBlock completion;
@property (nonatomic, strong) RKEntityMapping *mapping;
@property (nonatomic, strong) RKManagedObjectStore *store;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) id data;
@end

@implementation CDARestKitCoreDataParser
@synthesize uid = _uid;
- (NSOperationQueue *)queue
{
    if(!_queue){
        _queue = [NSOperationQueue new];
        _queue.name = [@"Restkit Parser " stringByAppendingString:self.uid];
    }
    return _queue;
}
- (instancetype)initWithMapping:(CDAMapper *)mapping AndCoreDataStack:(id<CDACoreDataStackProtocol>)coreDataStack{
    if(!(self = [super init]))return self;
    self.store = [[RKManagedObjectStore alloc] initWithManagedObjectModel:[coreDataStack managedObjectModel]];
    self.mapping = [self extractMapping:mapping];
    return self;
}
- (double)progress{
    return 0;
}
- (void)parseData:(id)data AndCompletion:(void (^)(id))completion{
    self.completion = completion;
    self.data = data;
    RKManagedObjectMappingOperationDataSource *mappingDataSource = [[RKManagedObjectMappingOperationDataSource alloc] initWithManagedObjectContext:self.context cache:self.store.managedObjectCache];
    RKMapperOperation *mappingOP = [[RKMapperOperation alloc] initWithRepresentation:self.data mappingsDictionary:@{[NSNull null]:self.mapping}];
    mappingOP.delegate = self;
    mappingOP.mappingOperationDataSource = mappingDataSource;
    
    [self.queue addOperation:mappingOP];
    [self.queue waitUntilAllOperationsAreFinished];
}
- (void)mapperDidFinishMapping:(RKMapperOperation *)mapper{
    [self.context performBlockAndWait:^{
        [self.context save:nil];
    }];
    
    self.completion(mapper.mappingResult);
}
#pragma mark - helpers
- (RKEntityMapping *)extractMapping:(CDAMapper *)pMapping{
    RKEntityMapping *mapping =[RKEntityMapping mappingForEntityForName:NSStringFromClass(pMapping.destinationClass) inManagedObjectStore:self.store];
    [mapping addAttributeMappingsFromDictionary:pMapping.attributesMapping];
    mapping.identificationAttributes = @[@"uid"];
    
    if ([pMapping.relationsMapping count] > 0) {
        for (CDARelationMapping *rMapping in pMapping.relationsMapping) {
            RKEntityMapping *cMapping = [self extractMapping:rMapping.mapper];

            [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:rMapping.remoteKey toKeyPath:rMapping.localKey withMapping:cMapping]];
        }
    }
    return mapping;
}
@end
