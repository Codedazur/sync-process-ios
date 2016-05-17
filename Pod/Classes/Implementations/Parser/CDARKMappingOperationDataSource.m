//
//  CDARKMappingOperationDataSource.m
//  Pods
//
//  Created by Tamara Bernad on 17/05/16.
//
//

#import "CDARKMappingOperationDataSource.h"

@interface CDARKMappingOperationDataSource()
@property (nonatomic) double _progress;
@property (nonatomic) double processedItems;
@property (nonatomic) double totalItems;
@property (nonatomic,strong) NSString *firstLevelClassName;
@end
@implementation CDARKMappingOperationDataSource
- (double)progress{
    if(self.totalItems <= 0)return 0;
    return self.processedItems/self.totalItems;
}
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext cache:(id<RKManagedObjectCaching>)managedObjectCache totalItems:(NSInteger)totalItemsToParse firstLevelClassName:(NSString *)firstLevelClassName{
    if(!(self = [super initWithManagedObjectContext:managedObjectContext cache:managedObjectCache]))return nil;
    self.processedItems = 0.0;
    self.totalItems = totalItemsToParse;
    self.firstLevelClassName = firstLevelClassName;
    return self;
}
- (id)mappingOperation:(RKMappingOperation *)mappingOperation targetObjectForRepresentation:(NSDictionary *)representation withMapping:(RKObjectMapping *)mapping inRelationship:(RKRelationshipMapping *)relationship{
    
    if([NSStringFromClass(mapping.objectClass) isEqualToString:self.firstLevelClassName]){
        self.processedItems++;
    }
    return [super mappingOperation:mappingOperation targetObjectForRepresentation:representation withMapping:mapping inRelationship:relationship];
}
@end
