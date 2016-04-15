//
//  CDACoreDataStack.h
//  Pods
//
//  Created by Tamara Bernad on 12/04/16.
//
//

#import <Foundation/Foundation.h>
#import "CDACoreDataStackProtocol.h"
@interface CDACoreDataStack : NSObject<CDACoreDataStackProtocol>

+ (NSManagedObjectContext *)independentManagedObjectContext;
+ (NSManagedObjectContext *)mainManagedObjectContext;
+ (void)saveMainContext;
+ (NSManagedObject *)fetchEntity:(NSString *)entity WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchEntities:(NSString *)entity WithSortKey:(NSString *)sortKey Ascending:(BOOL)ascending WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
+ (NSArray *)fetchEntities:(NSString *)entity WithSortDescriptors:(NSArray *)sortDescriptors WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
+ (instancetype)sharedInstance;
@end
