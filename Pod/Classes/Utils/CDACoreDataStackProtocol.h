//
//  CDACoreDataStackProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 08/04/16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@protocol CDACoreDataStackProtocol <NSObject>
- (NSManagedObjectContext *)mainManagedObjectContext;
- (NSManagedObjectContext *)independentManagedObjectContext;
- (NSManagedObjectModel *) managedObjectModel;

- (NSManagedObject *)fetchEntity:(NSString *)entity WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
- (NSArray *)fetchEntities:(NSString *)entity WithSortKey:(NSString *)sortKey Ascending:(BOOL)ascending WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
@end
