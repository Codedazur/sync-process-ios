//
//  ContentItem+CoreDataProperties.h
//  CDASyncService
//
//  Created by Tamara Bernad on 04/05/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "ContentItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface ContentItem (CoreDataProperties)

@property (nullable, nonatomic, retain) NSNumber *canSend;
@property (nullable, nonatomic, retain) NSNumber *id;
@property (nullable, nonatomic, retain) NSNumber *isDefault;
@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSNumber *parentId;
@property (nullable, nonatomic, retain) NSNumber *rootId;
@property (nullable, nonatomic, retain) NSNumber *thumbnailMediaId;
@property (nullable, nonatomic, retain) NSString *treePath;
@property (nullable, nonatomic, retain) NSString *type;
@property (nullable, nonatomic, retain) NSString *url;

@end

NS_ASSUME_NONNULL_END
