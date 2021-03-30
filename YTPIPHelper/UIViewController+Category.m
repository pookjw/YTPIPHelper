//
//  UIViewController+Category.m
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 3/30/21.
//

#import "UIViewController+Category.h"

@implementation UIViewController (Category)

- (void)showErrorAlertWithMessage:(NSString *)message {
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"ERROR!"
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *doneAction = [UIAlertAction actionWithTitle:@"Done"
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * _Nonnull action) { }];
    [alertController addAction:doneAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showErrorAlertWithError:(NSError *)error {
    [self showErrorAlertWithMessage:error.localizedDescription];
}

@end
