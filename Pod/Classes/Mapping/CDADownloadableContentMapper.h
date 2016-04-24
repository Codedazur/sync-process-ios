//
//  CDADownloadableContentMapper.h
//  Pods
//
//  Created by Tamara Bernad on 24/04/16.
//
//

#import "CDAMapper.h"

@interface CDADownloadableContentMapper : CDAMapper
@property (nonatomic, strong) NSString *localFileHashKey;
@property (nonatomic, strong) NSString *remoteFileHashKey;
@end
