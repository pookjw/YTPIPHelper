//
//  UIViewController+Category.h
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 3/30/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (Category)
- (void)showErrorAlertWithMessage:(NSString *)message;
- (void)showErrorAlertWithError:(NSError *)error;
- (void)showSuccessfulAlert;
@end

NS_ASSUME_NONNULL_END
