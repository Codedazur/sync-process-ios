//
//  CDASyncErrors.h
//  Pods
//
//  Created by Tamara Bernad on 20/01/16.
//
//

#import <Foundation/Foundation.h>
#define kSyncServiceDomain @"com.codedazur.syncService"
typedef enum
{
    CDASyncErrorNoError,
    CDASyncErrorRunning,
    CDASyncErrorLogin,
    CDASyncErrorParsingResponse,
    CDASyncErrorDownloadingFile,
    CDASyncErrorHttp,
    CDASyncErrorUnknown,
    CDASyncErrorSuspended,
    CDASyncErrorReadingDownloadArchive
    
}CDASyncError;