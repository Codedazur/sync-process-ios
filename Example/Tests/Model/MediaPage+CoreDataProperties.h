//
//  MediaPage+CoreDataProperties.h
//  CDASyncService
//
//  Created by Tamara Bernad on 04/05/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "MediaPage.h"

NS_ASSUME_NONNULL_BEGIN

@interface MediaPage (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *contentItemId;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *mediaId;
@property (nullable, nonatomic, retain) NSNumber *page;
@property (nullable, nonatomic, retain) NSString *text;

@end

NS_ASSUME_NONNULL_END
