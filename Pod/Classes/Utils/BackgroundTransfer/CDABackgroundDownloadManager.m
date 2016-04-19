//
//  CDABackgroundDownloadManager.m
//  Pods
//
//  Created by Tamara Bernad on 12/04/16.
//
//

#import "CDABackgroundDownloadManager.h"
#import "CDACoreDataStack.h"
#import "CDABGDFile.h"
#import "CDADownloadableEntityProtocol.h"



@interface CDABackgroundDownloadManager()
@property (nonatomic, strong)NSURLSession *backgroundSession;
@property (nonatomic, strong)NSMutableDictionary *completionHandlerDictionary;
@property (nonatomic, strong)id<CDACoreDataStackProtocol> downloadCoreDataStack;
@end
@implementation CDABackgroundDownloadManager

#pragma mark - public
- (void)addDownloadTaskWithUrlString:(NSString *)urlString AndDestinationFilePath:(NSString *)destinationFilePath AndFileClass:(NSString *)fileClass AndEntityId:(NSString *)entityId{
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLSessionDownloadTask *task = [self.backgroundSession downloadTaskWithURL:url];
    if(self.backgroundSession.configuration.identifier){
        CDABGDFile *file = (CDABGDFile *)[self.downloadCoreDataStack createNewEntity:NSStringFromClass([CDABGDFile class]) inContext:[self.downloadCoreDataStack managedObjectContext]];
        file.sessionId = self.backgroundSession.configuration.identifier;
        file.taskId = [NSString stringWithFormat:@"%i",task.taskIdentifier];
        file.destinationPath = destinationFilePath;
        file.entityClass = fileClass;
        file.entityId = entityId;

        [self.downloadCoreDataStack saveMainContext];
    }
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
//        NSString *bundlePath = [NSBundle bundlefor];
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        self.downloadCoreDataStack = [[CDACoreDataStack alloc] initWithModelName:@"background-download" AndBundle:bundle];
    
        self.completionHandlerDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
        
        NSURLSessionConfiguration *backgroundConfigObject = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier: kBackgroundSessionIdentifier];
        backgroundConfigObject.allowsCellularAccess = NO;
        self.backgroundSession = [NSURLSession sessionWithConfiguration: backgroundConfigObject delegate: self delegateQueue: [NSOperationQueue mainQueue]];
    }
    return self;
}

#pragma mark - Delegate methods for download tasks
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    if(session.configuration.identifier){

        if(location.path){
            CDABGDFile *file = [self getFileWithSession:session AndTask:downloadTask];
            NSError *error;
            [[NSFileManager defaultManager] moveItemAtPath:location.path toPath:file.destinationPath error:&error];
            if(error){
                NSLog(@"Error moving file from temp %@ to destination %@", location.path, file.destinationPath);
            }
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

- (CDABGDFile *) getFileWithSession:(NSURLSession *)session AndTask:(NSURLSessionDownloadTask *)task{
    CDABGDFile *file = (CDABGDFile *)[self.downloadCoreDataStack fetchEntity:NSStringFromClass([CDABGDFile class]) WithPredicate:[NSPredicate predicateWithFormat:@"sessionId=%@ && taskId=%@",session.configuration.identifier, task.taskIdentifier] InContext:[self.downloadCoreDataStack managedObjectContext]];
    return file;
}
@end
