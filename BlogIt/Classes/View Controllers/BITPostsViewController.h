//
//  BITPostsViewController.h
//  BlogIt
//
//  Created by Pauli Jokela on 20.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TTUITableViewZoomController.h"

@interface BITPostsViewController : TTUITableViewZoomController

@property (strong, nonatomic) NSMutableArray *postsArray;
@property (nonatomic) NSString *categoryName;
@property (nonatomic) NSString *categorySlug;
@property (nonatomic) NSUInteger currentPage;
@property (nonatomic) NSUInteger previousPage;

- (void)reload;

@end
