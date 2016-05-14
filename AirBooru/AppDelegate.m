//
//  AppDelegate.m
//  AirBooru
//
//  Created by qii on 4/24/15.
//  Copyright (c) 2015 org.qii.airbooru. All rights reserved.
//


#import "AppDelegate.h"
#import "RootTabViewController.h"
#import "ThemeHelper.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

//sometimes xcode6.2 wont print exception stack
void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"CRASH: %@", exception);
    NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    self.window = [[UIWindow alloc] init];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.rootViewController = [[RootTabViewController alloc] init];
    [self.window makeKeyAndVisible];
    [ThemeHelper styleApp];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}

@end