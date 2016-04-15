//
//  File.h
//  CDASyncService
//
//  Created by Tamara Bernad on 15/04/16.
//  Copyright © 2016 tamarabernad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CDADownloadableEntityProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface File : NSManagedObject<CDADownloadableEntityProtocol>

// Insert code here to declare functionality of your managed object subclass

@end

NS_ASSUME_NONNULL_END

#import "File+CoreDataProperties.h"
