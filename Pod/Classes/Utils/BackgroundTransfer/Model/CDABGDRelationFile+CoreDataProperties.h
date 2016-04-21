//
//  CDABGDRelationFile+CoreDataProperties.h
//  Pods
//
//  Created by Tamara Bernad on 21/04/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDABGDRelationFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDABGDRelationFile (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *destinationFolder;
@property (nullable, nonatomic, retain) NSString *entityClass;
@property (nullable, nonatomic, retain) NSString *entityHashKey;
@property (nullable, nonatomic, retain) NSString *entityId;
@property (nullable, nonatomic, retain) NSString *fileHash;
@property (nullable, nonatomic, retain) NSString *fileName;
@property (nullable, nonatomic, retain) CDABGDFile *archive;

@end

NS_ASSUME_NONNULL_END
