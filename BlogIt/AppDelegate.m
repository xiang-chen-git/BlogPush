//
//  AppDelegate.m
//  BlogIt
//
//  Created by Pauli Jokela on 20.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import "AppDelegate.h"

#import "DDWP.h"

#import "BITConfig.h"

#import "BITMainViewController.h"

#import <Parse/Parse.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

+ (void)initialize
{
    // We initialize our WordPress helper,
    // which is what will be communicating with WordPress itself
    [[DDWP shared] setupWithWordPressURL:kBIT_BLOG_URL];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // If the Parse flag is set to YES, automatically enable Push Notifications
    if (kBIT_PARSE_PUSH_ENABLED)
    {
        [Parse setApplicationId:kBIT_PARSE_APPLICATION_ID clientKey:kBIT_PARSE_CLIENT_KEY];
        
        // Set up Push Notifications for both iOS 7 and iOS 8
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil]];
            [[UIApplication sharedApplication] registerForRemoteNotifications];
        }
        else
        {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound)];
        }
    }
    
    return YES;
}

#pragma mark - Push Notification delegates

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // We only need to be able to handle Push Notifications if Parse is enabled
    if (kBIT_PARSE_PUSH_ENABLED)
    {
        // Store the deviceToken in the current installation and save it to Parse.
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        [currentInstallation setDeviceTokenFromData:deviceToken];
        currentInstallation.channels = @[ @"global" ];
        [currentInstallation saveInBackground];
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // We only need to be able to handle Push Notifications if Parse is enabled
    if (kBIT_PARSE_PUSH_ENABLED)
    {
        [PFPush handlePush:userInfo];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
