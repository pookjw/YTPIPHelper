//
//  ShareViewController.m
//  YTPIPHelperShareExtension
//
//  Created by Jinwoo Kim on 3/31/21.
//

#import "ShareViewController.h"

@interface ShareViewController ()

@end

@implementation ShareViewController

- (BOOL)isContentValid {
    return YES;
}

- (void)didSelectPost {
    [self openHostAppWithItem];
}

- (NSArray *)configurationItems {
    return @[];
}

- (void)openHostAppWithItem {
    [self.extensionContext completeRequestReturningItems:@[] completionHandler:nil];
    
    NSExtensionItem *item = self.extensionContext.inputItems.firstObject;
    NSItemProvider *itemProvider = item.attachments.firstObject;
    __weak typeof(self) weakSelf = self;
    NSLog(@"%@", itemProvider.registeredTypeIdentifiers);
    if ([itemProvider hasItemConformingToTypeIdentifier:@"public.url"]) {
        [itemProvider loadItemForTypeIdentifier:@"public.url"
                                        options:nil
                              completionHandler:^(NSURL * _Nullable itemURL, NSError *error) {
            if ((itemURL == nil) || (weakSelf == nil)) return;
            NSString * _Nullable videoID = [weakSelf videoIDFromURL:itemURL];
            if (videoID == nil) return;
            NSURL *urlToOpen = [weakSelf urlToOpenFromVideoID:videoID];
            [weakSelf openURL:urlToOpen
                      options:@{}
            completionHandler:^(BOOL success) { }];
        }];
    } else if ([itemProvider hasItemConformingToTypeIdentifier:@"public.plain-text"]) {
        [itemProvider loadItemForTypeIdentifier:@"public.plain-text"
                                        options:nil
                              completionHandler:^(NSString * _Nullable itemString, NSError *error) {
            if ((itemString == nil) || (weakSelf == nil)) return;
            NSURL *itemURL = [NSURL URLWithString:itemString];
            if (itemURL == nil) return;
            NSString * _Nullable videoID = [weakSelf videoIDFromURL:itemURL];
            if (videoID == nil) return;
            NSURL *urlToOpen = [weakSelf urlToOpenFromVideoID:videoID];
            [weakSelf openURL:urlToOpen
                      options:@{}
            completionHandler:^(BOOL success) { }];
        }];
    }
}

- (NSString * _Nullable)videoIDFromURL:(NSURL *)itemURL {
    NSLog(@"%@", itemURL.host);
    if ([itemURL.host containsString:@"youtube.com"]) {
        if (![itemURL.pathComponents containsObject:@"watch"]) {
            return nil;
        }
        if (![itemURL.query containsString:@"v="]) {
            return nil;
        }
        NSArray<NSString *> *components = [itemURL.query componentsSeparatedByString:@"="];
        BOOL foundVideoID = NO;
        NSString * _Nullable videoID = nil;
        for (NSString *component in components) {
            if (foundVideoID) {
                videoID = [[component componentsSeparatedByString:@"&"] firstObject];
                break;
            }
            if ([component isEqualToString:@"v"]) foundVideoID = YES;
        }
        NSLog(@"%@", videoID);
        return videoID;
    } else if ([itemURL.host containsString:@"youtu.be"]) {
        NSLog(@"%@", itemURL.query);
        return itemURL.query;
    } else {
        return nil;
    }
}

- (NSURL *)urlToOpenFromVideoID:(NSString *)videoID {
    NSURLComponents *urlComponentsToOpen = [[NSURLComponents new] autorelease];
    [urlComponentsToOpen setScheme:@"ytpiphelper"];
    [urlComponentsToOpen setHost:@""];
    NSString *encodedVideoID = [videoID stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLHostAllowedCharacterSet];
    [urlComponentsToOpen setQuery:[NSString stringWithFormat:@"videoID=%@", encodedVideoID]];
    
    return urlComponentsToOpen.URL;
}

- (void)openURL:(NSURL *)url
        options:(NSDictionary<UIApplicationOpenExternalURLOptionsKey, id> *)options
completionHandler:(void (^)(BOOL success))completion
{
    UIApplication *sharedApplication = (UIApplication *)[UIApplication valueForKey:@"sharedApplication"];
    SEL openURLSelector = NSSelectorFromString(@"openURL:options:completionHandler:");
    
    if ([sharedApplication respondsToSelector:openURLSelector]) {
        NSMethodSignature *signature = [sharedApplication methodSignatureForSelector:openURLSelector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:sharedApplication];
        [invocation setSelector:openURLSelector];
        [invocation setArgument:&url atIndex:2];
        [invocation setArgument:&options atIndex:3];
        [invocation setArgument:&completion atIndex:4];
        [invocation invoke];
    }
}

@end
