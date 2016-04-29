//
//  CDAMapper.h
//  Pods
//
//  Created by Tamara Bernad on 08/04/16.
//
//

#import <Foundation/Foundation.h>

@interface CDAMapper : NSObject
@property (nonatomic, strong) NSString *destinationClassName;
@property (nonatomic, strong) NSDictionary *attributesMapping;
@property (nonatomic, strong) NSArray *relationsMapping;
@property (nonatomic, strong) NSString *rootKey;
@property (nonatomic, strong) NSString *localIdentifierKey;
@property (nonatomic, strong) NSString *remoteIdentifierKey;
@end
