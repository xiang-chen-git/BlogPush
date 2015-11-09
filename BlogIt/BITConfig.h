//
//  BITConfig.h
//  BlogIt
//
//  Created by Pauli Jokela on 19.1.2015.
//  Copyright (c) 2015 Didstopia. All rights reserved.
//

/*
 
    This file is used for easy configuration of the app.
 
    For any problems, please contact support@didstopia.com
 
*/

// IMPORTANT: Set this to match your blog website address (URL) without forgetting the "http://"
//            and after you've installed the JSON plugin (check the documentation).
#define kBIT_BLOG_URL @"http://demo-blog.didstopia.com"

// Set this to exclude specific categories from the sidebar, using their SLUG name (ie. "uncategorized").
// To remove all categories from the list, simply enter: @[]
// Each category slug name needs to be added after a comma.
// NOTE: It is very important that you follow the exact example below, separated by commas!
#define kBIT_CATEGORY_EXCLUDE @[ @"exclude-me", @"exclude-me-too" ]

// Set this to exclude specific pages from the sidebar, using their SLUG name (ie. "about-us").
// To remove all pages from the list, simply enter: @[]
// Each page slug name needs to be added after a comma.
// NOTE: It is very important that you follow the exact example below, separated by commas!
#define kBIT_PAGE_EXCLUDE @[ @"exclude-me", @"exclude-me-too" ]

// Set this to YES or NO to control whether the launch animation is enabled or not.
#define kBIT_ENABLE_LAUNCH_ANIMATION YES

// Set to YES or NO to enable or disable the map view
#define kBIT_MAP_ENABLED YES

// Set the map page name here
#define kBIT_MAP_PAGE_NAME @"Custom Map"

// Latitude and longitude for the map view
#define kBIT_MAP_LATITUDE 37.423617
#define kBIT_MAP_LONGITUDE -122.220154

// This defines what kind of ads will be displayed.
// Simply change the text inside the quotes to match one of the values below.
//
// @"IAD"               - Displays iAd banner ads
// @"ADMOB"             - Displays AdMob banner ads
//
// NOTE: This only applies to using the "BlogIt" target,
//       not the "BlogIt (No Ads)" target.
//
#define kBIT_ADS_PROVIDER @"IAD"

// Set this to your AdMob advertisement ID, if you're using AdMob
//
// NOTE: This only applies to using the "BlogIt" target,
//       not the "BlogIt (No Ads)" target.
//
#define kBIT_ADS_ADMOB_ID @"ca-app-pub-your_identifier"

// Set this to YES or NO if you want to enable/disable Parse's Push Notifications.
// NOTE: You need to follow the Parse Push Notification tutorial in our documentation!
#define kBIT_PARSE_PUSH_ENABLED NO

// If you're using Parse Push Notifications, set the keys below to match your app
#define kBIT_PARSE_APPLICATION_ID @"REPLACE_WITH_APP_ID"
#define kBIT_PARSE_CLIENT_KEY @"REPLACE_WITH_CLIENT_KEY"