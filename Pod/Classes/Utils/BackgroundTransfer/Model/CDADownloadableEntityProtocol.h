//
//  CDADownloadableEntityProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 13/04/16.
//
//

#import <Foundation/Foundation.h>

@protocol CDADownloadableEntityProtocol <NSObject>
@property (nullable, nonatomic, strong) NSString *uid;
@property (nullable, nonatomic, strong) NSNumber *state;
@end
