//
//  SceneDelegate.m
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 3/29/21.
//

#import "SceneDelegate.h"
#import "MainViewController.h"

@interface SceneDelegate ()
@property (strong, nonatomic) MainViewController *mainVC;
@end

@implementation SceneDelegate

- (void)dealloc {
    [_mainVC release];
    [_window release];
    [super dealloc];
}

- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    if (windowScene == nil) return;
    
    UIWindow *window = [[UIWindow alloc] initWithWindowScene:windowScene];
    self.window = window;
    [window release];
    
    MainViewController *mainVC = [MainViewController new];
    self.mainVC = mainVC;
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:mainVC];
    self.window.rootViewController = nvc;
    [mainVC release];
    [nvc release];
    [self.window makeKeyAndVisible];
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    NSURL *openedURL = [URLContexts allObjects].firstObject.URL;
    if (openedURL == nil) return;
    [self requestToVCFromURL:openedURL];
}

- (void)requestToVCFromURL:(NSURL *)url {
    NSString *query = [url query];
    NSArray<NSString *> *components = [query componentsSeparatedByString:@"="];
    BOOL foundVideoID = NO;
    NSString * _Nullable videoID = nil;
    for (NSString *component in components) {
        if (foundVideoID) videoID = component;
        if ([component isEqualToString:@"videoID"]) foundVideoID = YES;
    }
    if (videoID == nil) return;
    [self.mainVC requestFromVideoID:videoID];
}

@end
