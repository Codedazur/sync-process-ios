//
//  CDABackgroundDownloadManager.h
//  Pods
//
//  Created by Tamara Bernad on 12/04/16.
//
//

#import <Foundation/Foundation.h>
static NSString * const kBackgroundSessionIdentifier = @"com.kvadrat.training-binder.download-session";
typedef void (^CompletionHandlerType)();

@interface CDABackgroundDownloadManager : NSObject

+ (instancetype)sharedInstance;

- (void) addCompletionHandler: (CompletionHandlerType) handler forSession: (NSString *)identifier;
- (void) callCompletionHandlerForSession: (NSString *)identifier;

@end
