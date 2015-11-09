//
//  DDWP.h
//  DDWPDemo
//
//  Created by Pauli Jokela on 20.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "DDWPPost.h"
#import "DDWPComment.h"
#import "DDWPCategory.h"

@interface DDWP : NSObject

typedef void (^BlogInfoCompletionBlock)(NSString *blogName, NSString *blogDescription, NSError *error);

typedef void (^PagesArrayCompletionBlock)(NSArray *pages, NSError *error);
typedef void (^PageCompletionBlock)(DDWPPost *page, NSError *error);

typedef void (^PostsArrayCompletionBlock)(NSArray *posts, NSError *error);
typedef void (^PostCompletionBlock)(DDWPPost *post, NSError *error);

typedef void (^CategoriesArrayCompletionBlock)(NSArray *categories, NSError *error);

typedef void (^CommentsArrayCompletionBlock)(NSArray *comments, NSError *error);

typedef void (^NewPostCompletionBlock)(NSError *error);

typedef void (^JSONResponseCompletionBlock)(NSDictionary *jsonResponse, NSError *error);

+ (id)shared;

- (void)setupWithWordPressURL:(NSString*)url;

- (void)getBlogInfoWithCompletion:(BlogInfoCompletionBlock)block;

- (void)getPagesWithExcludeArray:(NSArray*)excludeArray completion:(PagesArrayCompletionBlock)block;

- (void)getPostsForPage:(NSUInteger)pageNum completion:(PostsArrayCompletionBlock)block;
- (void)getPostsForPage:(NSUInteger)pageNum withCategorySlug:(NSString*)categorySlug completion:(PostsArrayCompletionBlock)block;
- (void)getPostWithId:(NSUInteger)postId completion:(PostCompletionBlock)block;

- (void)getCategoriesWithExcludeArray:(NSArray*)excludeArray completion:(CategoriesArrayCompletionBlock)block;

- (void)getCommentsForPostWithId:(NSUInteger)postId completion:(CommentsArrayCompletionBlock)block;

- (void)postComment:(NSString*)comment author:(NSString*)author email:(NSString*)email website:(NSString*)website postId:(NSUInteger)postId completion:(NewPostCompletionBlock)block;

+ (NSString*)formattedDateStringFromDateString:(NSString*)dateString;
+ (NSString*)stringByStrippingHTML:(NSString*)str;
+ (NSString*)timeElapsedString:(NSString*)dateString;

@end