//
//  Textile+CoreDataProperties.h
//  CDASyncService
//
//  Created by Tamara Bernad on 21/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Textile.h"

NS_ASSUME_NONNULL_BEGIN

@interface Textile (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *name;
@property (nullable, nonatomic, retain) NSString *uid;
@property (nullable, nonatomic, retain) NSSet<Color *> *colours;

@end

@interface Textile (CoreDataGeneratedAccessors)

- (void)addColoursObject:(Color *)value;
- (void)removeColoursObject:(Color *)value;
- (void)addColours:(NSSet<Color *> *)values;
- (void)removeColours:(NSSet<Color *> *)values;

@end

NS_ASSUME_NONNULL_END
