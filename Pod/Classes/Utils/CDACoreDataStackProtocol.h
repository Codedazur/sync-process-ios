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
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (instancetype)initWithModelName:(NSString *)modelName;
- (void)saveMainContext;
- (NSManagedObject *_Nullable) createNewEntity:(NSString *)entity inContext:(NSManagedObjectContext *)context;

- (NSManagedObjectContext *)independentManagedObjectContext;
- (NSManagedObject *_Nullable)fetchEntity:(NSString *)entity WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context;
- (NSArray * _Nullable)fetchEntities:(NSString *)entity WithSortKey:(NSString * _Nullable)sortKey Ascending:(BOOL)ascending WithPredicate:( NSPredicate * _Nullable )predicate InContext:(NSManagedObjectContext *)context;
@end
