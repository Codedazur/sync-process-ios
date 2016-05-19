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
#import "CDARKMappingOperationDataSource.h"

typedef void(^ParseCompletionBlock)(id result);

@interface CDARestKitCoreDataParser()<RKMapperOperationDelegate>
@property (nonatomic, strong)NSManagedObjectContext *context;
@property (nonatomic, strong)NSManagedObjectContext *mainContext;
@property (nonatomic, copy) ParseCompletionBlock completion;
@property (nonatomic, strong) RKEntityMapping *mapping;
@property (nonatomic, strong) RKManagedObjectStore *store;
@property (nonatomic, strong) CDARKMappingOperationDataSource *mappingDataSource;
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
    self.context = [coreDataStack independentManagedObjectContext];
    self.mainContext = [coreDataStack managedObjectContext];
    self.store = [[RKManagedObjectStore alloc] initWithManagedObjectModel:[coreDataStack managedObjectModel]];
    self.mapping = [self extractMapping:mapping];
    self.rootKey = mapping.rootKey;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onManagedObjectContextSave:) name:NSManagedObjectContextDidSaveNotification object:self.context];
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.mappingDataSource = nil;
}
- (double)progress{
    return self.mappingDataSource != nil ? [self.mappingDataSource progress] : 0;
}
- (void)parseData:(id)data AndCompletion:(void (^)(id))completion{
    self.completion = completion;
    self.data = data;
    
    NSInteger totalItems = [self.data isKindOfClass:[NSArray class]] ? ((NSArray *)self.data).count : 1;
    
    self.mappingDataSource = [[CDARKMappingOperationDataSource alloc] initWithManagedObjectContext:self.context cache:self.store.managedObjectCache totalItems:totalItems firstLevelClassName:NSStringFromClass(self.mapping.objectClass)];
    
    RKMapperOperation *mappingOP = [[RKMapperOperation alloc] initWithRepresentation:self.data
                                                                  mappingsDictionary:@{(self.rootKey == nil ? [NSNull null] : self.rootKey) :self.mapping}];
    mappingOP.delegate = self;
    mappingOP.mappingOperationDataSource = self.mappingDataSource;
    
    [self.queue addOperation:mappingOP];
    [self.queue waitUntilAllOperationsAreFinished];
}
- (void)mapperDidFinishMapping:(RKMapperOperation *)mapper{
    NSError __block *error=nil;
    [self.context performBlockAndWait:^{
        
        if(![self.context save:&error]){
            NSLog(@"error saving %@", error);
        }
    }];
    
    if(error)self.completion(error);
    else self.completion(mapper.mappingResult.array);
}
#pragma mark - helpers
- (void)onManagedObjectContextSave:(NSNotification *)notification{
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.mainContext mergeChangesFromContextDidSaveNotification:notification];
    });
}
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
