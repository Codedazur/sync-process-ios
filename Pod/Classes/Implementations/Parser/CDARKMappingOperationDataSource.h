//
//  CDARKMappingOperationDataSource.h
//  Pods
//
//  Created by Tamara Bernad on 17/05/16.
//
//

#import <Foundation/Foundation.h>
#import <RestKit/CoreData.h>

@interface CDARKMappingOperationDataSource : RKManagedObjectMappingOperationDataSource
- (double) progress;
- (instancetype)initWithManagedObjectContext:(NSManagedObjectContext *)managedObjectContext cache:(id<RKManagedObjectCaching>)managedObjectCache totalItems:(NSInteger)totalItemsToParse firstLevelClassName:(NSString *)firstLevelClassName;
@end
