//
//  CDARelationMapping.h
//  Pods
//
//  Created by Tamara Bernad on 08/04/16.
//
//

#import <Foundation/Foundation.h>
#import "CDAMapper.h"
#import "CDARelationMapping.h"

@interface CDARelationMapping : NSObject
@property (nonatomic, strong) CDAMapper *mapper;
@property (nonatomic, strong) NSString *remoteKey;
@property (nonatomic, strong) NSString *localKey;
@end
