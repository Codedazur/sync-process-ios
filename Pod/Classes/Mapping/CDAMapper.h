//
//  CDAMapper.h
//  Pods
//
//  Created by Tamara Bernad on 08/04/16.
//
//

#import <Foundation/Foundation.h>

@interface CDAMapper : NSObject
@property (nonatomic, strong) Class destinationClass;
@property (nonatomic, strong) NSDictionary *attributesMapping;
@property (nonatomic, strong) NSArray *relationsMapping;
@end
