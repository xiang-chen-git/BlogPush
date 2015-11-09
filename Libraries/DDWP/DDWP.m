//
//  DDWP.m
//  DDWPDemo
//
//  Created by Pauli Jokela on 20.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import "DDWP.h"

#import <CommonCrypto/CommonDigest.h>

@interface DDWP ()

@property (nonatomic, strong, readonly) NSString *baseURL;

@end

@implementation DDWP

#pragma mark - Initialization

// This creates what's called a "singleton",
// meaning that we have a shared object to work with
+ (id)shared
{
    static DDWP *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^
    {
        _sharedInstance = [[DDWP alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - Setup

// Sets the WordPress blog URL, used for all the web requests
- (void)setupWithWordPressURL:(NSString*)url
{
    if (url)
    {
        _baseURL = url;
    }
}

#pragma mark - Fetching Blog info (title, description)

// Gets simple blog information, such as the title and the description
- (void)getBlogInfoWithCompletion:(BlogInfoCompletionBlock)block
{
    [self urlRequestWithEndpoint:@"/" completion:^(NSDictionary *jsonResponse, NSError *error)
     {
         if (error)
         {
             block(nil, nil, error);
         }
         else
         {
             NSString *name = jsonResponse[@"name"];
             NSString *description = jsonResponse[@"description"];
             block(name, description, error);
         }
     }];
}

#pragma mark - Fetching Pages

// Gets all pages
- (void)getPagesWithExcludeArray:(NSArray*)excludeArray completion:(PagesArrayCompletionBlock)block
{
    [self urlRequestWithEndpoint:@"/pages" completion:^(NSDictionary *jsonResponse, NSError *error)
     {
         if (error)
         {
             block(nil, error);
         }
         else
         {
             NSMutableArray *newPagesArray = [[NSMutableArray alloc] init];
             for (NSDictionary *page in (NSArray*)jsonResponse)
             {
                 DDWPPost *newPage = [[DDWPPost alloc] init];
                 newPage.ID = [page[@"ID"] unsignedIntegerValue];
                 newPage.order = [page[@"menu_order"] unsignedIntegerValue];
                 if ([page[@"author"] isKindOfClass:[NSDictionary class]]) newPage.author = page[@"author"][@"nickname"];
                 newPage.title = page[@"title"];
                 newPage.content = [self htmlStringFromString:page[@"content"]];
                 newPage.excerpt = page[@"excerpt"];
                 newPage.date = page[@"date_gmt"];
                 
                 if (page[@"featured_image"] && [page[@"featured_image"] isKindOfClass:[NSDictionary class]]) newPage.featuredImageURL = [NSURL URLWithString:page[@"featured_image"][@"source"]];
                 
                 // This handles excluding specific pages by their slug name
                 BOOL shouldExclude = NO;
                 for (NSString *excludePageName in excludeArray)
                 {
                     if ([excludePageName isEqualToString:page[@"slug"]])
                     {
                         shouldExclude = YES;
                         break;
                     }
                 }
                 
                 if (!shouldExclude) [newPagesArray addObject:newPage];
             }
             
             // Sort by menu order
             NSArray *sortedPagesArray = [newPagesArray sortedArrayUsingComparator:^NSComparisonResult(DDWPPost *p1, DDWPPost *p2)
             {
                 return p1.order > p2.order;
             }];
             
             block([sortedPagesArray copy], error);
         }
     }];
}

#pragma mark - Fetching Posts

// Gets all posts (limited by WordPress)
- (void)getPostsForPage:(NSUInteger)pageNum completion:(PostsArrayCompletionBlock)block
{
    // Create a query string with 10 posts per page for the current page
    NSString *queryString = [NSString stringWithFormat:@"/posts&filter[posts_per_page]=10&page=%lu", (unsigned long)pageNum];
    
    [self urlRequestWithEndpoint:queryString completion:^(NSDictionary *jsonResponse, NSError *error)
    {
        if (error)
        {
            block(nil, error);
        }
        else
        {
            NSMutableArray *newPostsArray = [[NSMutableArray alloc] init];
            for (NSDictionary *post in (NSArray*)jsonResponse)
            {
                DDWPPost *newPost = [[DDWPPost alloc] init];
                newPost.ID = [post[@"ID"] unsignedIntegerValue];
                if ([post[@"author"] isKindOfClass:[NSDictionary class]]) newPost.author = post[@"author"][@"nickname"];
                newPost.title = post[@"title"];
                newPost.content = [self htmlStringFromString:post[@"content"]];
                newPost.excerpt = post[@"excerpt"];
                newPost.date = post[@"date_gmt"];
                newPost.url = post[@"link"];
                
                if (post[@"featured_image"] && [post[@"featured_image"] isKindOfClass:[NSDictionary class]]) newPost.featuredImageURL = [NSURL URLWithString:post[@"featured_image"][@"source"]];
                
                [newPostsArray addObject:newPost];
            }
            block([newPostsArray copy], error);
        }
    }];
}

// Gets all posts in a specific category (limited by WordPress)
- (void)getPostsForPage:(NSUInteger)pageNum withCategorySlug:(NSString*)categorySlug completion:(PostsArrayCompletionBlock)block
{
    // Create a query string with 10 posts per page for the current page
    NSString *queryString = [NSString stringWithFormat:@"/posts&filter[category_name]=%@&filter[posts_per_page]=10&page=%lu", categorySlug
, (unsigned long)pageNum];
            
    [self urlRequestWithEndpoint:queryString completion:^(NSDictionary *jsonResponse, NSError *error)
     {
         if (error)
         {
             block(nil, error);
         }
         else
         {
             NSMutableArray *newPostsArray = [[NSMutableArray alloc] init];
             for (NSDictionary *post in (NSArray*)jsonResponse)
             {
                 DDWPPost *newPost = [[DDWPPost alloc] init];
                 newPost.ID = [post[@"ID"] unsignedIntegerValue];
                 if ([post[@"author"] isKindOfClass:[NSDictionary class]]) newPost.author = post[@"author"][@"nickname"];
                 newPost.title = post[@"title"];
                 newPost.content = [self htmlStringFromString:post[@"content"]];
                 newPost.excerpt = post[@"excerpt"];
                 newPost.date = post[@"date_gmt"];
                 newPost.url = post[@"link"];
                 
                 if (post[@"featured_image"] && [post[@"featured_image"] isKindOfClass:[NSDictionary class]]) newPost.featuredImageURL = [NSURL URLWithString:post[@"featured_image"][@"source"]];
                 
                 [newPostsArray addObject:newPost];
             }
             block([newPostsArray copy], error);
         }
     }];
}

// Gets a specific post, specified by the post ID (identifier)
- (void)getPostWithId:(NSUInteger)postId completion:(PostCompletionBlock)block
{
    [self urlRequestWithEndpoint:[NSString stringWithFormat:@"/posts/%lu", (unsigned long)postId] completion:^(NSDictionary *jsonResponse, NSError *error)
     {
         if (error)
         {
             block(nil, error);
         }
         else
         {
             DDWPPost *newPost = [[DDWPPost alloc] init];
             newPost.ID = [jsonResponse[@"ID"] unsignedIntegerValue];
             if ([jsonResponse[@"author"] isKindOfClass:[NSDictionary class]]) newPost.author = jsonResponse[@"author"][@"nickname"];
             newPost.title = jsonResponse[@"title"];
             newPost.content = [self htmlStringFromString:jsonResponse[@"content"]];
             newPost.excerpt = jsonResponse[@"excerpt"];
             newPost.date = jsonResponse[@"date_gmt"];
             newPost.url = jsonResponse[@"link"];
             
             if (jsonResponse[@"featured_image"] && [jsonResponse[@"featured_image"] isKindOfClass:[NSDictionary class]]) newPost.featuredImageURL = [NSURL URLWithString:jsonResponse[@"featured_image"][@"source"]];
             
             block(newPost, error);
         }
     }];
}

#pragma mark - Fetching categories

// Gets all categories
- (void)getCategoriesWithExcludeArray:(NSArray*)excludeArray completion:(CategoriesArrayCompletionBlock)block
{
    [self urlRequestWithEndpoint:@"/taxonomies/category/terms" completion:^(NSDictionary *jsonResponse, NSError *error)
    {
        if (error)
        {
            block(nil, error);
        }
        else
        {
            NSMutableArray *newCategoriesArray = [[NSMutableArray alloc] init];
            for (NSDictionary *category in (NSArray*)jsonResponse)
            {
                DDWPCategory *newCategory = [[DDWPCategory alloc] init];
                newCategory.ID = [category[@"ID"] unsignedIntegerValue];
                newCategory.name = category[@"name"];
                newCategory.slug = category[@"slug"];
                newCategory.count = [category[@"count"] unsignedIntegerValue];
                                
                // This handles excluding specific category names by their slug name
                BOOL shouldExclude = NO;
                for (NSString *excludeCategoryName in excludeArray)
                {
                    if ([excludeCategoryName isEqualToString:category[@"slug"]])
                    {
                        shouldExclude = YES;
                        break;
                    }
                }
                
                // We only get the category if it has posts in it
                if (newCategory.count > 0 && !shouldExclude)
                {
                    [newCategoriesArray addObject:newCategory];
                }
            }
            
            // Sort by ID (currently not really useful, but flip the '<' around to reverse the order)
            NSArray *sortedCategoriesArray = [newCategoriesArray sortedArrayUsingComparator:^NSComparisonResult(DDWPCategory *c1, DDWPCategory *c2)
            {
                return c1.ID < c2.ID;
            }];
            
            block([sortedCategoriesArray copy], error);
        }
    }];
}

#pragma mark - Fetching comments

// Gets all comments for a specific post, specified by the post ID (identifier)
- (void)getCommentsForPostWithId:(NSUInteger)postId completion:(CommentsArrayCompletionBlock)block
{
    [self urlRequestWithEndpoint:[NSString stringWithFormat:@"/posts/%lu/comments", (unsigned long)postId] completion:^(NSDictionary *jsonResponse, NSError *error)
     {
         if (error)
         {
             block(nil, error);
         }
         else
         {
             NSMutableArray *newCommentsArray = [[NSMutableArray alloc] init];
             for (NSDictionary *post in (NSArray*)jsonResponse)
             {
                 DDWPComment *newComment = [[DDWPComment alloc] init];
                 newComment.ID = [post[@"ID"] unsignedIntegerValue];
                 newComment.content = [self htmlStringFromString:post[@"content"]];
                 newComment.date = post[@"date_gmt"];
                 
                 newComment.author = post[@"author"][@"name"];
                 if (post[@"author"] && [post[@"author"] isKindOfClass:[NSDictionary class]]) newComment.avatarURL = [NSURL URLWithString:post[@"author"][@"avatar"]];
                 
                 [newCommentsArray addObject:newComment];
             }
             block([newCommentsArray copy], error);
         }
     }];
}

#pragma mark - Posting comments

// Posts a comment, pretty self-explanatory
- (void)postComment:(NSString*)comment author:(NSString*)author email:(NSString*)email website:(NSString*)website postId:(NSUInteger)postId completion:(NewPostCompletionBlock)block
{
    NSAssert(_baseURL, @"Base URL is undefined. Please use setupWithWordPressURL to set your blog URL.");
    
    NSString *postString = [NSString stringWithFormat:@"comment_post_ID=%lu&author=%@&email=%@&url=%@&comment=%@", (unsigned long)postId, author, email, website, comment];
    NSData *postData = [postString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/wp-comments-post.php", _baseURL]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"text/html" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    [request setTimeoutInterval:30];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError) block(connectionError);
         else block(nil);
     }];
}

#pragma mark - URL request handling

// Handles most of our URL requests
- (void)urlRequestWithEndpoint:(NSString*)endpoint completion:(JSONResponseCompletionBlock)block
{
    NSAssert(_baseURL, @"Base URL is undefined. Please use setupWithWordPressURL to set your blog URL.");
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/?json_route=%@", _baseURL, endpoint]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:30];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         if (connectionError)
         {
             if (block)
                 block(nil, connectionError);
         }
         else
         {
             NSError *parseError;
             NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&parseError];
             
             if (parseError)
                 block(nil, parseError);
             else if (block && jsonDictionary)
                 block(jsonDictionary, nil);
             else
                 block(nil, nil);
         }
     }];
}

#pragma mark - Utility functions

// Parses JSON to NSDictionary
- (NSDictionary*)parseJsonData:(NSData*)data
{
    NSError *error = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    
    return jsonDictionary;
}

// Generarates and MD5 string/hash from a regular string
- (NSString*)md5ForString:(const char *)c
{
    unsigned char result[16];
    CC_MD5(c, (unsigned int)strlen(c), result);
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x", result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7], result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

// Generates a pre-formatted HTML string for use in
// web views inside of posts, pages and comments
- (NSString*)htmlStringFromString:(NSString*)string
{
    return [NSString stringWithFormat:@"<html><meta name='viewport' content='width=device-width, initial-scale=1'><head><style>body { background: white } p { color: #555555; font-family: 'Avenir-Book'; font-size: 14px }</style></head><body><p>%@<p></body></html>", string];
}

// Formats a date with a suffix, ie. "1st" or "2nd"
+ (NSString*)formattedDateStringFromDateString:(NSString*)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    //[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *monthDayFormatter = [[NSDateFormatter alloc] init];
    [monthDayFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [monthDayFormatter setDateFormat:@"d"];
    int dayOfMonth = [[monthDayFormatter stringFromDate:date] intValue];
    
    NSArray *magicSuffixes = [@"|st|nd|rd|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|th|st|nd|rd|th|th|th|th|th|th|th|st" componentsSeparatedByString: @"|"];
    NSString *magicSuffix = [magicSuffixes objectAtIndex:dayOfMonth];
    
    [dateFormatter setDateFormat:@"MMMM dd'.', YYYY"];
    NSString *formattedDateString = [dateFormatter stringFromDate:date];
    
    formattedDateString = [formattedDateString stringByReplacingOccurrencesOfString:@"." withString:magicSuffix];
    
    return formattedDateString;
}

// Strips HTML/tags from a string
+ (NSString*)stringByStrippingHTML:(NSString*)str
{
    if (!str || [str isKindOfClass:[NSNull class]]) return @"";
    
    NSRange r;
    while ((r = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        if (str.length > 0) str = [str stringByReplacingCharactersInRange:r withString:@""];
        else break;
    }
    
    NSString *convertedString = [self decodeHtmlUnicodeCharactersToString:str];
        
    return convertedString;
}

// Decodes HTML symbols to regular characters, ie. &amp; to & (ampersand)
// Based on code from here: http://stackoverflow.com/questions/1105169/html-character-decoding-in-objective-c-cocoa-touch/1105297#1105297
+ (NSString*)decodeHtmlUnicodeCharactersToString:(NSString*)str
{
    str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSUInteger myLength = [str length];
    NSUInteger ampIndex = [str rangeOfString:@"&" options:NSLiteralSearch].location;
    
    // Short-circuit if there are no ampersands.
    if (ampIndex == NSNotFound)
    {
        return str;
    }
    
    // Make result string with some extra capacity.
    NSMutableString *result = [NSMutableString stringWithCapacity:(myLength * 1.25)];
    
    // First iteration doesn't need to scan to & since we did that already, but for code simplicity's sake we'll do it again with the scanner.
    NSScanner *scanner = [NSScanner scannerWithString:str];
    do
    {
        // Scan up to the next entity or the end of the string.
        NSString *nonEntityString;
        if ([scanner scanUpToString:@"&" intoString:&nonEntityString])
        {
            [result appendString:nonEntityString];
        }
        if ([scanner isAtEnd])
        {
            goto finish;
        }
        
        // Scan either a HTML or numeric character entity reference.
        if ([scanner scanString:@"&amp;" intoString:NULL]) [result appendString:@"&"];
        else if ([scanner scanString:@"&apos;" intoString:NULL]) [result appendString:@"'"];
        else if ([scanner scanString:@"&quot;" intoString:NULL]) [result appendString:@"\""];
        else if ([scanner scanString:@"&#8220;" intoString:NULL]) [result appendString:@"\""];
        else if ([scanner scanString:@"&#8221;" intoString:NULL]) [result appendString:@"\""];
        else if ([scanner scanString:@"&lt;" intoString:NULL]) [result appendString:@"<"];
        else if ([scanner scanString:@"&gt;" intoString:NULL]) [result appendString:@">"];
        else if ([scanner scanString:@"&nbsp;" intoString:NULL]) [result appendString:@" "];
        else if ([scanner scanString:@"&hellip;" intoString:NULL]) [result appendString:@"…"];
        else if ([scanner scanString:@"&#" intoString:NULL])
        {
            BOOL gotNumber;
            unsigned charCode;
            NSString *xForHex = @"";
            
            // Is it hex or decimal?
            if ([scanner scanString:@"x" intoString:&xForHex])
            {
                gotNumber = [scanner scanHexInt:&charCode];
            }
            else
            {
                gotNumber = [scanner scanInt:(int*)&charCode];
            }
            if (gotNumber)
            {
                [result appendFormat:@"%C", (unichar)charCode];
            }
            else
            {
                NSString *unknownEntity = @"";
                [scanner scanUpToString:@";" intoString:&unknownEntity];
                [result appendFormat:@"&#%@%@;", xForHex, unknownEntity];
                NSLog(@"Expected numeric character entity but got &#%@%@;", xForHex, unknownEntity);
            }
            [scanner scanString:@";" intoString:NULL];
        }
        else
        {
            NSString *unknownEntity = @"";
            [scanner scanUpToString:@";" intoString:&unknownEntity];
            NSString *semicolon = @"";
            [scanner scanString:@";" intoString:&semicolon];
            [result appendFormat:@"%@%@", unknownEntity, semicolon];
            NSLog(@"Unsupported XML character entity %@%@", unknownEntity, semicolon);
        }
    }
    while (![scanner isAtEnd]);
    
    finish: return result;
}

// This nifty function generates a "time string" for a specific period of time
// ie. "15 minutes ago" or "2 days ago"
+ (NSString*)timeElapsedString:(NSString*)dateString
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [df setTimeZone:gmt];
    
    [df setFormatterBehavior:NSDateFormatterBehavior10_4];
    [df setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
    
    NSDate *convertedDate = [df dateFromString:dateString];
    NSDate *todayDate = [NSDate date];
    
    double ti = [convertedDate timeIntervalSinceDate:todayDate];
    ti = ti * -1;
    if (ti < 1)
    {
        return @"never";
    }
    else if (ti < 60)
    {
        return @"less than a minute ago";
    }
    else if (ti < 3600)
    {
        int diff = round(ti / 60);
        return [NSString stringWithFormat:@"%d minutes ago", diff];
    }
    else if (ti < 86400)
    {
        int diff = round(ti / 60 / 60);
        return[NSString stringWithFormat:@"%d hours ago", diff];
    }
    else if (ti < 2629743)
    {
        int diff = round(ti / 60 / 60 / 24);
        return[NSString stringWithFormat:@"%d days ago", diff];
    }
    else
    {
        return @"never";
    }	
}

@end