//
//  CDABGDFile+CoreDataProperties.h
//  Pods
//
//  Created by Tamara Bernad on 21/04/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDABGDFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDABGDFile (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *destinationPath;
@property (nullable, nonatomic, retain) NSString *sessionId;
@property (nullable, nonatomic, retain) NSString *taskId;
@property (nullable, nonatomic, retain) NSSet<NSManagedObject *> *realationFiles;

@end

@interface CDABGDFile (CoreDataGeneratedAccessors)

- (void)addRealationFilesObject:(NSManagedObject *)value;
- (void)removeRealationFilesObject:(NSManagedObject *)value;
- (void)addRealationFiles:(NSSet<NSManagedObject *> *)values;
- (void)removeRealationFiles:(NSSet<NSManagedObject *> *)values;

@end

NS_ASSUME_NONNULL_END
