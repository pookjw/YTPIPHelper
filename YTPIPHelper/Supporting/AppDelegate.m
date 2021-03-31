//
//  AppDelegate.m
//  YTPIPHelper
//
//  Created by Jinwoo Kim on 3/29/21.
//

#import <AVFoundation/AVFoundation.h>
#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback error:nil];
    return YES;
}

@end
