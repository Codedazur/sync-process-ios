//
//  CDABackgroundDownloadManager.m
//  Pods
//
//  Created by Tamara Bernad on 12/04/16.
//
//

#import "CDABackgroundDownloadManager.h"
#import "CDACoreDataStack.h"
#import "CDABGDownloadingFile.h"
#import "CDADownloadableEntityProtocol.h"
#import "CDASynConstants.h"
#import "CDASyncFileHelper.h"

@interface CDABackgroundDownloadManager()<NSURLSessionDownloadDelegate>
@property (nonatomic, strong)NSURLSession *backgroundSession;
@property (nonatomic, strong)NSMutableDictionary *completionHandlerDictionary;
@property (nonatomic, strong)id<CDACoreDataStackProtocol> downloadCoreDataStack;
@end
@implementation CDABackgroundDownloadManager

#pragma mark - public
- (void)addDownloadTaskWithUrlString:(NSString *)urlString AndDestinationFilePath:(NSString *)destinationFilePath{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDownloadTask *task = [self.backgroundSession downloadTaskWithURL:url];
    if(self.backgroundSession.configuration.identifier){
        CDABGDownloadingFile *file = (CDABGDownloadingFile *)[self.downloadCoreDataStack createNewEntity:NSStringFromClass([CDABGDownloadingFile class]) inContext:[self.downloadCoreDataStack managedObjectContext]];
        file.sessionId = self.backgroundSession.configuration.identifier;
        file.taskId = [NSString stringWithFormat:@"%i",task.taskIdentifier];
        file.destinationPath = [destinationFilePath stringByDeletingLastPathComponent];
        file.fileName = [destinationFilePath lastPathComponent];
        
        [self.downloadCoreDataStack saveMainContext];
    }
    [task resume];
}
#pragma mark - NSURLSessionDownloadDelegate
-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSLog(@"Background URL session %@ finished events.\n", session);
    
    if (session.configuration.identifier)
        [self callCompletionHandlerForSession: session.configuration.identifier];
}
- (void) addCompletionHandler: (CompletionHandlerType) handler forSession: (NSString *)identifier
{
    if ([ self.completionHandlerDictionary objectForKey: identifier]) {
        NSLog(@"Error: Got multiple handlers for a single session identifier.  This should not happen.\n");
    }
    
    [ self.completionHandlerDictionary setObject:handler forKey: identifier];
}
- (void) callCompletionHandlerForSession: (NSString *)identifier
{
    CompletionHandlerType handler = [self.completionHandlerDictionary objectForKey: identifier];
    
    if (handler) {
        [self.completionHandlerDictionary removeObjectForKey: identifier];
        NSLog(@"Calling completion handler.\n");
        
        handler();
    }
}

#pragma mark - initializers
+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{

    self = [super init];
    if (self) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        self.downloadCoreDataStack = [[CDACoreDataStack alloc] initWithModelName:kSyncConstantBGDownloadDatabaseName AndBundle:bundle];
    
        self.completionHandlerDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        
        NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier: kBackgroundSessionIdentifier];
        backgroundConfigObject.allowsCellularAccess = YES;
        backgroundConfigObject.sessionSendsLaunchEvents = YES;
        self.backgroundSession = [NSURLSession sessionWithConfiguration: backgroundConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    }
    return self;
}

#pragma mark - Delegate methods for download tasks
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    if(session.configuration.identifier){

        if(location.path){
            NSLog(@"did finish downloading task %i on session %@ to path %@", downloadTask.taskIdentifier, session.configuration.identifier,  location.path);
            
            CDABGDownloadingFile *file = [self getFileWithSession:session AndTask:downloadTask];
            NSString *absoluteDestinationFolder = [[CDASyncFileHelper documentsFolderPath] stringByAppendingPathComponent:file.destinationPath];
            NSString *absoluteDestinationPath = [absoluteDestinationFolder stringByAppendingPathComponent:file.fileName];
            
            NSLog(@"moving to path %@", file.destinationPath);
            NSError *error;
            [[NSFileManager defaultManager] createDirectoryAtPath:absoluteDestinationFolder withIntermediateDirectories:YES attributes:nil error:&error];
            
            NSURL *dest = [NSURL fileURLWithPath:absoluteDestinationPath];
            NSURL *orig = [NSURL fileURLWithPath:location.path];
            [[NSFileManager defaultManager] replaceItemAtURL:dest withItemAtURL:orig backupItemName:nil options:0 resultingItemURL:nil error:&error];
            
            if(error){
                NSLog(@"Error moving file from temp %@ to destination %@, %@", location.path, file.destinationPath, error);
            }
            [[self.downloadCoreDataStack managedObjectContext] deleteObject:file];
            [self.downloadCoreDataStack saveMainContext];
        }
        
    }
}
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    NSLog(@"Session %@ download task %@ wrote an additional %lld bytes (total %lld bytes) out of an expected %lld bytes.\n",
          session, downloadTask, bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    NSLog(@"Session %@ download task %@ resumed at offset %lld bytes out of an expected %lld bytes.\n",
          session, downloadTask, fileOffset, expectedTotalBytes);
}
- (CDABGDownloadingFile *) getFileWithSession:(NSURLSession *)session AndTask:(NSURLSessionDownloadTask *)task{
    NSString *sessionId = [session.configuration.identifier copy];
    NSString *taskId = [NSString stringWithFormat:@"%i",task.taskIdentifier];
    CDABGDownloadingFile *file = (CDABGDownloadingFile *)[self.downloadCoreDataStack fetchEntity:NSStringFromClass([CDABGDownloadingFile class]) WithPredicate:[NSPredicate predicateWithFormat:@"sessionId=%@ && taskId=%@",sessionId, taskId] InContext:[self.downloadCoreDataStack managedObjectContext]];
    return file;
}
@end
