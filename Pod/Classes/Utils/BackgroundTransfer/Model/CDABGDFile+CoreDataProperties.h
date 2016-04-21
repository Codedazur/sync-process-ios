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

@property (nullable, nonatomic, retain) NSString *path;
@property (nullable, nonatomic, retain) NSString *fileName;
@property (nullable, nonatomic, retain) NSSet<CDABGDRelationFile *> *relationFiles;

@end

@interface CDABGDFile (CoreDataGeneratedAccessors)

- (void)addRelationFilesObject:(CDABGDRelationFile *)value;
- (void)removeRelationFilesObject:(CDABGDRelationFile *)value;
- (void)addRelationFiles:(NSSet<CDABGDRelationFile *> *)values;
- (void)removeRelationFiles:(NSSet<CDABGDRelationFile *> *)values;

@end

NS_ASSUME_NONNULL_END
