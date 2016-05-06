//
//  CDASyncChron.m
//  Pods
//
//  Created by Tamara Bernad on 06/05/16.
//
//

#import "CDASyncChron.h"
@interface CDASyncChron()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) NSTimeInterval timeInterval;
@end
@implementation CDASyncChron
- (instancetype)initWithInterval:(NSTimeInterval)timeInterval{
    if(!(self = [super init]))return self;
    self.timeInterval = timeInterval;
    return self;
}
- (void)dealloc{
    [self.timer invalidate];
}
- (void)start{
    [self scheduleTimer];
}
- (void)scheduleTimer{
    [self.timer invalidate];
    self.timer= [NSTimer scheduledTimerWithTimeInterval:[self timeInterval]  target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}
- (void) timerFired:(NSTimer *)timer{
    [[NSNotificationCenter defaultCenter] postNotificationName:kSyncChronPull
                                                        object:self
                                                      userInfo:nil];
}

@end
