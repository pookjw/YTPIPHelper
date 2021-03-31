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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.systemBackgroundColor;
}

- (void)requestFromVideoID:(NSString *)videoID {
    VideoInfoService *service = [VideoInfoService new];
    [service requestVideoStreamingURLsUsingVideoID:videoID
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
