//
//  CDAAppDelegate.m
//  CDASyncService
//
//  Created by tamarabernad on 07/17/2015.
//  Copyright (c) 2015 tamarabernad. All rights reserved.
//

#import "CDAAppDelegate.h"
#import "CDABackgroundDownloadManager.h"
#import "CDACoreDataStack.h"

@interface CDAAppDelegate()
@property (nonatomic, strong)CDACoreDataStack *coreDataStack;
@end
@implementation CDAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    self.coreDataStack = [[CDACoreDataStack alloc] initWithModelName:@"Model"];
    [CDABackgroundDownloadManager sharedInstance] ;
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier: identifier];
    
    
    NSURLSession *backgroundSession = [NSURLSession sessionWithConfiguration: backgroundConfigObject delegate: [CDABackgroundDownloadManager sharedInstance] delegateQueue: [NSOperationQueue mainQueue]];
    
    
    NSLog(@"AppDelegate Background session did download %@\n %@", identifier, backgroundSession);
    
    [[CDABackgroundDownloadManager sharedInstance] addCompletionHandler: completionHandler forSession: identifier];
}
@end
