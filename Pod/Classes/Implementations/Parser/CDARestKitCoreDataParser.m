//
//  CDARestKitCoreDataParser.m
//  Pods
//
//  Created by Tamara Bernad on 08/04/16.
//
//

#import "CDARestKitCoreDataParser.h"
#import <RestKit/CoreData.h>

#import "CDARelationMapping.h"

typedef void(^ParseCompletionBlock)(id result);

@interface CDARestKitCoreDataParser()<RKMapperOperationDelegate>
@property (nonatomic, strong)NSManagedObjectContext *context;
@property (nonatomic, copy) ParseCompletionBlock completion;
@property (nonatomic, strong) RKEntityMapping *mapping;
@property (nonatomic, strong) RKManagedObjectStore *store;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) id data;
@property (nonnull, strong) NSString *rootKey;
@end

@implementation CDARestKitCoreDataParser
@synthesize uid = _uid;
- (NSOperationQueue *)queue
{
    if(!_queue){
        _queue = [NSOperationQueue new];
        _queue.name = @"Restkit Parser";
    }
    return _queue;
}
- (instancetype)initWithMapping:(CDAMapper *)mapping AndCoreDataStack:(id<CDACoreDataStackProtocol>)coreDataStack{
    if(!(self = [super init]))return self;
    self.store = [[RKManagedObjectStore alloc] initWithManagedObjectModel:[coreDataStack managedObjectModel]];
    self.mapping = [self extractMapping:mapping];
    self.rootKey = mapping.rootKey;
    self.context = [coreDataStack independentManagedObjectContext];
    return self;
}
- (double)progress{
    return 0;
}
- (void)parseData:(id)data AndCompletion:(void (^)(id))completion{
    self.completion = completion;
    self.data = data;
    RKManagedObjectMappingOperationDataSource *mappingDataSource = [[RKManagedObjectMappingOperationDataSource alloc] initWithManagedObjectContext:self.context cache:self.store.managedObjectCache];
    RKMapperOperation *mappingOP = [[RKMapperOperation alloc] initWithRepresentation:self.data
                                                                  mappingsDictionary:@{(self.rootKey == nil ? [NSNull null] : self.rootKey) :self.mapping}];
    mappingOP.delegate = self;
    mappingOP.mappingOperationDataSource = mappingDataSource;
    
    [self.queue addOperation:mappingOP];
    [self.queue waitUntilAllOperationsAreFinished];
}
- (void)mapperDidFinishMapping:(RKMapperOperation *)mapper{
    [self.context performBlockAndWait:^{
        [self.context save:nil];
    }];
    
    self.completion(mapper.mappingResult.array);
}
#pragma mark - helpers
- (RKEntityMapping *)extractMapping:(CDAMapper *)pMapping{
    RKEntityMapping *mapping =[RKEntityMapping mappingForEntityForName:pMapping.destinationClassName inManagedObjectStore:self.store];
    [mapping addAttributeMappingsFromDictionary:pMapping.attributesMapping];
    mapping.identificationAttributes = @[pMapping.localIdentifierKey];
    
    if ([pMapping.relationsMapping count] > 0) {
        for (CDARelationMapping *rMapping in pMapping.relationsMapping) {
            RKEntityMapping *cMapping = [self extractMapping:rMapping.mapper];

            [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:rMapping.remoteKey toKeyPath:rMapping.localKey withMapping:cMapping]];
        }
    }
    return mapping;
}
@end
