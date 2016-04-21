//
//  CDABGDownloadingFile+CoreDataProperties.h
//  Pods
//
//  Created by Tamara Bernad on 21/04/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "CDABGDownloadingFile.h"

NS_ASSUME_NONNULL_BEGIN

@interface CDABGDownloadingFile (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *destinationPath;
@property (nullable, nonatomic, retain) NSString *fileName;
@property (nullable, nonatomic, retain) NSString *sessionId;
@property (nullable, nonatomic, retain) NSString *taskId;

@end

NS_ASSUME_NONNULL_END
