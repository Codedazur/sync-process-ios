//
//  CDACoreDataStack.m
//  Pods
//
//  Created by Tamara Bernad on 12/04/16.
//
//

#import "CDACoreDataStack.h"
static id sharedInstance = nil;
@interface CDACoreDataStack()
@property (nonatomic, strong)NSString *modelName;
@end
@implementation CDACoreDataStack
@synthesize managedObjectContext = _managedObjectContext, managedObjectModel = _managedObjectModel, persistentStoreCoordinator = _persistentStoreCoordinator;

+ (instancetype)initSharedInstanceWithModelName:(NSString *)modelName{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
        ((CDACoreDataStack *)sharedInstance).modelName = modelName;
    });
    return sharedInstance;
}
+ (instancetype)sharedInstance
{
    NSAssert(sharedInstance != nil, @"Initialize the shared instance with initSharedInstanceWithModelName");
    return sharedInstance;
}
#pragma mark - lazy getters
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext == nil)
    {
    
        NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
        if (coordinator != nil)
        {
            _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_managedObjectContext setPersistentStoreCoordinator:coordinator];
            [_managedObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType]];
        }
    }
    return _managedObjectContext;
}
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel == nil)
    {
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    }
    return _managedObjectModel;
}
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator == nil)
    {
    
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self.modelName stringByAppendingString:@".sqlite"]];
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil] error:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
    return _persistentStoreCoordinator;
}
#pragma mark - helpers
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}
#pragma mark - protocol
+ (NSManagedObject *) createNewEntity:(NSString *)entity inContext:(NSManagedObjectContext *)context {
    if (context == nil) context = [[CDACoreDataStack sharedInstance] managedObjectContext];
    
    NSManagedObject *object = [NSEntityDescription insertNewObjectForEntityForName:entity
                                                            inManagedObjectContext:context];
    
    return object;
}
+ (NSManagedObjectContext *)independentManagedObjectContext{
    return [[CDACoreDataStack sharedInstance] independentManagedObjectContext];
}
+ (NSManagedObjectContext *)mainManagedObjectContext{
    return [[CDACoreDataStack sharedInstance] managedObjectContext];
}
- (NSManagedObjectContext *)independentManagedObjectContext
{
    
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
        [managedObjectContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSMergeByPropertyStoreTrumpMergePolicyType]];
        [managedObjectContext setUndoManager:nil];
    }
    return managedObjectContext;
}
- (NSArray *)fetchEntities:(NSString *)entity WithSortKey:(NSString *)sortKey Ascending:(BOOL)ascending WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context{
    return [CDACoreDataStack fetchEntities:entity WithSortKey:sortKey Ascending:ascending WithPredicate:predicate InContext:context];
}
- (NSManagedObject *)fetchEntity:(NSString *)entity WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context{
    return [CDACoreDataStack fetchEntity:entity WithPredicate:predicate InContext:context];
}
#pragma mark - public
+ (void)saveMainContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = [CDACoreDataStack sharedInstance].managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
}
+ (NSManagedObject *)fetchEntity:(NSString *)entity WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context {
    if (context == nil) context = [[CDACoreDataStack sharedInstance] managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entity inManagedObjectContext:context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setFetchLimit:1];
    
    if(predicate){
        [request setPredicate:predicate];
    }
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (array == nil)
    {
        
    }
    return [array firstObject];
}
+ (NSArray *)fetchEntities:(NSString *)entity WithSortKey:(NSString *)sortKey Ascending:(BOOL)ascending WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context {
    NSArray *sortDescriptors = nil;
    if(sortKey){
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
                                            initWithKey:sortKey ascending:ascending];
        sortDescriptors = @[sortDescriptor];
    }
    
    return [CDACoreDataStack fetchEntities:entity WithSortDescriptors:sortDescriptors WithPredicate:predicate InContext:context];
    
}

+ (NSArray *)fetchEntities:(NSString *)entity WithSortDescriptors:(NSArray *)sortDescriptors WithPredicate:(NSPredicate *)predicate InContext:(NSManagedObjectContext *)context {
    if (context == nil) context = [[CDACoreDataStack sharedInstance] managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:entity inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    [request setSortDescriptors:sortDescriptors];
    
    if(predicate){
        [request setPredicate:predicate];
    }
    
    NSError *error;
    NSArray *array = [context executeFetchRequest:request error:&error];
    if (error != nil || array == nil)
    {
        NSLog(@"CoreDataStack::ErrorFeching::Entity %@ With Predicate: %@",entity, predicate);
    }
    return array;
}
@end
