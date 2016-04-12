//
//  Color+CoreDataProperties.h
//  CDASyncService
//
//  Created by Tamara Bernad on 11/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Color.h"

NS_ASSUME_NONNULL_BEGIN

@interface Color (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *colorName;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) Textile *textile;

@end

NS_ASSUME_NONNULL_END
