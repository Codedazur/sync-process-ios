//
//  CDASyncManagerProtocol.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>

@protocol CDASyncManagerProtocol <NSObject>
- (void)sync;
- (void)syncForce;
@end
