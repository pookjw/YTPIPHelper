//
//  SceneDelegate.m
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 3/29/21.
//

#import "SceneDelegate.h"
#import "MainViewController.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    if (windowScene == nil) return;
    
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window = window;
    [window release];
    
    MainViewController * _Nullable vc = [MainViewController new];
    self.window.rootViewController = vc;
    [vc release];
    [self.window makeKeyAndVisible];
}

- (void)dealloc {
    [_window release];
    [super dealloc];
}

@end
