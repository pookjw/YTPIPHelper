//
//  MainViewController.m
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 3/29/21.
//

#import "MainViewController.h"
#import "VideoInfoService.h"
#import "UIViewController+Category.h"

@implementation MainViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
    
    VideoInfoService *service = [VideoInfoService new];
    [service requestVideoStreamingURLsUsingVideoID:@"ffRxVHmUUgY"
                                 completionHandler:^(NSArray<NSDictionary *> * _Nullable formats, NSError * _Nullable error) {
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showErrorAlertWithError:error];
            });
        }
        
        NSLog(@"%@", formats);
        
        [service release];
    }];
}

@end
