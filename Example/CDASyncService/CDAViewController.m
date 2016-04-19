//
//  CDAViewController.m
//  CDASyncService
//
//  Created by tamarabernad on 07/17/2015.
//  Copyright (c) 2015 tamarabernad. All rights reserved.
//

#import "CDAViewController.h"
#import "CDABackgroundDownloadManager.h"

@interface CDAViewController ()

@end

@implementation CDAViewController
- (IBAction)onClickDownload:(id)sender {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    [[CDABackgroundDownloadManager sharedInstance] addDownloadTaskWithUrlString:@"http://training-binder.kvadrat.com:8888/test.zip" AndDestinationFilePath:[paths firstObject] AndFileClass:nil AndEntityId:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
