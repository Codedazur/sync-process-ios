//
//  File+CoreDataProperties.h
//  CDASyncService
//
//  Created by Tamara Bernad on 15/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "File.h"

NS_ASSUME_NONNULL_BEGIN

@interface File (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSNumber *state;

@end

NS_ASSUME_NONNULL_END
