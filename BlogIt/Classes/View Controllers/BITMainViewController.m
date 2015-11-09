//
//  BITMainViewController.m
//  BlogIt
//
//  Created by Pauli Jokela on 29.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import "BITMainViewController.h"

#import "BITConfig.h"

#import "CDRTranslucentSideBar.h"

#import "BITPostsViewController.h"

#import "BITSinglePostViewController.h"

#import "BITMapViewController.h"

#import "BITPageCell.h"

#import "DDWP.h"

#import "BITViewZoomAnimation.h"

#import "CBZSplashView.h"

#import "JGProgressHUD.h"

@interface BITMainViewController () <CDRTranslucentSideBarDelegate, UITableViewDataSource, UITableViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) BITPostsViewController *postsViewController;

@property (nonatomic, strong) id<BitViewAnimation> animationController;

@property (nonatomic, strong) IBOutlet UIButton *menuButton;
@property (nonatomic, strong) CDRTranslucentSideBar *leftSidebar;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *categoriesArray;
@property (nonatomic, strong) NSMutableArray *pagesArray;

@property (nonatomic, strong) NSString *blogName;

@property (nonatomic, strong) CBZSplashView *splashView;

@end

@implementation BITMainViewController

- (void)awakeFromNib
{
    if (kBIT_ENABLE_LAUNCH_ANIMATION)
    {
        // Setup our splash animation
        self.splashView = [CBZSplashView splashViewWithIcon:[UIImage imageNamed:@"Logo"] backgroundColor:[UIColor blackColor]];
        [self.view addSubview:self.splashView];
    }
    
    // Setup our sidebar
    self.leftSidebar = [[CDRTranslucentSideBar alloc] init];
    self.leftSidebar.delegate = self;
    self.leftSidebar.translucentStyle = UIBarStyleBlack;
    
    // Setup our sidebar's table view
    self.tableView = [[UITableView alloc] init];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerClass:[BITPageCell class] forCellReuseIdentifier:@"BITPageCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.leftSidebar setContentViewInSideBar:self.tableView];
    
    // This globally sets all UIBarButtonItems to use a specific font and size
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]} forState:UIControlStateNormal];
    
    // Get the blog info (title etc.)
    [[DDWP shared] getBlogInfoWithCompletion:^(NSString *blogName, NSString *blogDescription, NSError *error)
    {
        if (!error)
        {
            self.blogName = blogName;
        }
        else
        {
            self.blogName = @"Loading..";
        }
    }];
    
    // Get all the categories and add them to the sidebar
    [[DDWP shared] getCategoriesWithExcludeArray:kBIT_CATEGORY_EXCLUDE completion:^(NSArray *categories, NSError *error)
    {
        if (!error)
        {
            [self setCategoriesArray:[categories mutableCopy]];
            
            // Create a "Latest Posts" dummy category
            DDWPCategory *latestPosts = [[DDWPCategory alloc] init];
            latestPosts.ID = 0;
            latestPosts.name = @"Latest Posts";
            latestPosts.count = 1;
            
            // Make sure it's the first item
            [self.categoriesArray insertObject:latestPosts atIndex:0];
            
            [self.tableView reloadData];
        }
        else NSLog(@"Error: %@", error);
        
        // Get all blog pages and add them to the sidebar
        [[DDWP shared] getPagesWithExcludeArray:kBIT_PAGE_EXCLUDE completion:^(NSArray *pages, NSError *error)
         {
             if (!error)
             {
                 [self setPagesArray:[pages mutableCopy]];
                 [self.tableView reloadData];
             }
             else NSLog(@"Error: %@", error);
             
             if (kBIT_ENABLE_LAUNCH_ANIMATION)
             {
                 // Start the splash animation when we're done loading the pages
                 [self.splashView startAnimation];
             }
         }];
    }];
    
    // Add a pan gesture for both showing and hiding the sidebar
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
    // Creates the "hamburger" menu button, which shows the sidebar
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuButton setImage:[UIImage imageNamed:@"Menu icon"] forState:UIControlStateNormal];
    [self.menuButton setFrame:CGRectMake(10, 0, 44, 44)];
    [self.menuButton addTarget:self.leftSidebar action:@selector(show) forControlEvents:UIControlEventTouchUpInside];
    
    if (kBIT_ENABLE_LAUNCH_ANIMATION) [self.view insertSubview:self.menuButton belowSubview:self.splashView];
    
    // Handles our cell "zoom" animation
    self.animationController = [[BITViewZoomAnimation alloc] init];
}

// Let the sidebar handle the pan gesture
- (void)handlePanGesture:(UIPanGestureRecognizer *)recognizer
{
    self.leftSidebar.isCurrentPanGestureTarget = YES;
    [self.leftSidebar handlePanGestureToShow:recognizer inView:self.view];
}

// Hide the "hamburger" menu button if the sidebar is visible
- (void)sideBar:(CDRTranslucentSideBar *)sideBar willAppear:(BOOL)animated
{
    [self.menuButton setHidden:YES];
}

// Show the "hamburger" menu button if the sidebar is hidden
- (void)sideBar:(CDRTranslucentSideBar *)sideBar willDisappear:(BOOL)animated
{
    [self.menuButton setHidden:NO];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) return self.categoriesArray.count;
    else
    {
        if (kBIT_MAP_ENABLED) return self.pagesArray.count + 1;
        else return self.pagesArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BITPageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BITPageCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0)
    {
        // For the first item, we're statically adding a "Latest Posts" button
        if (indexPath.row == 0)
        {
            [cell.textLabel setText:@"Latest Posts"];
        }
        else
        {
            DDWPCategory *category = [self.categoriesArray objectAtIndex:indexPath.row];
            [cell.textLabel setText:category.name];
        }
    }
    else
    {
        // Last item in the pages array, which is our map view (if enabled)
        if (kBIT_MAP_ENABLED && indexPath.row == self.pagesArray.count)
        {
            [cell.textLabel setText:kBIT_MAP_PAGE_NAME];
        }
        else
        {
            DDWPPost *page = [self.pagesArray objectAtIndex:indexPath.row];
            [cell.textLabel setText:page.title];
        }
    }
    
    // This essentially insets the separator from left and right,
    // just to make it look a bit nicer
    CGFloat top = 0, bottom = 0;
    CGFloat left = 20, right = 20;
    [cell setSeparatorInset:UIEdgeInsetsMake(top, left, bottom, right)];
    
    // This removes the last separator from the last cell
    if (indexPath.row == [self.tableView numberOfRowsInSection:indexPath.section] - 1)
    {
        self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 1)];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.textLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:16]];
    [cell.textLabel setTextAlignment:NSTextAlignmentCenter];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        [self.leftSidebar dismissAnimated:YES];
        
        JGProgressHUD *HUD = [JGProgressHUD progressHUDWithStyle:JGProgressHUDStyleDark];
        [HUD showInView:self.view];
        
        // For the first item, we're statically adding a "Latest Posts" button
        if (indexPath.row == 0)
        {
            [self.postsViewController setCurrentPage:1];
            [self.postsViewController reload];
            
            [HUD dismissAnimated:YES];
            
            [[DDWP shared] getPostsForPage:1 completion:^(NSArray *posts, NSError *error)
            {
                if (!error)
                {
                    [self.postsViewController setCategoryName:@""];
                    [self.postsViewController setCategorySlug:@""];
                    [self.postsViewController setCurrentPage:1];
                    [self.postsViewController setPreviousPage:0];
                    [self.postsViewController setPostsArray:[posts mutableCopy]];
                    [self.postsViewController.tableView reloadData];
                    
                    if (posts != nil && posts.count > 0)
                        [self.postsViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
                
                [HUD dismissAnimated:YES];
            }];
        }
        else
        {
            DDWPCategory *category = [self.categoriesArray objectAtIndex:indexPath.row];
            
            [[DDWP shared] getPostsForPage:1 withCategorySlug:category.slug completion:^(NSArray *posts, NSError *error)
             {
                 if (!error)
                 {
                     [self.postsViewController setCategoryName:category.name];
                     [self.postsViewController setCategorySlug:category.slug];
                     [self.postsViewController setCurrentPage:1];
                     [self.postsViewController setPreviousPage:0];
                     [self.postsViewController setPostsArray:[posts mutableCopy]];
                     [self.postsViewController.tableView reloadData];
                     
                     if (posts != nil && posts.count > 0)
                         [self.postsViewController.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                     
                 }
                 
                 [HUD dismissAnimated:YES];
             }];
        }
    }
    else
    {
        // For pages, we deselect them immediately
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self.leftSidebar dismissAnimated:NO];
        
        // Last item in the pages array, which is our map view (if enabled)
        if (kBIT_MAP_ENABLED && indexPath.row == self.pagesArray.count)
        {
#if BLOGIT_AD_FREE == 0
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_Autolayout" bundle:nil];
#else
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_Autolayout_NoAds" bundle:nil];
#endif
            BITMapViewController *mapController = [storyboard instantiateViewControllerWithIdentifier:@"BITMapViewController"];
            [self presentViewController:mapController animated:YES completion:nil];
        }
        else
        {
            DDWPPost *page = [self.pagesArray objectAtIndex:indexPath.row];
            
#if BLOGIT_AD_FREE == 0
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_Autolayout" bundle:nil];
#else
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_Autolayout_NoAds" bundle:nil];
#endif
            BITSinglePostViewController *pageController = [storyboard instantiateViewControllerWithIdentifier:@"BITSinglePostViewController"];
            
            pageController.transitioningDelegate = self;
            
            [pageController setPost:page];
            
            [self presentViewController:pageController animated:YES completion:nil];
        }
    }
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // For the first section (in the sidebar), show the blog name/title as the header title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 32)];
    [titleLabel setFont:[UIFont fontWithName:@"AvenirNext-DemiBold" size:16]];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setMinimumScaleFactor:0.5];
    [titleLabel setText:self.blogName];
    
    [titleLabel sizeToFit];
    
    // For any other sections, we disable/hide the text
    if (section != 0) [titleLabel setText:@""];
    
    return titleLabel;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark - UIViewController animation delegates

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    self.animationController.isPresenting = YES;
    
    return self.animationController;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    self.animationController.isPresenting = NO;
    
    return self.animationController;
}

#pragma mark - Storyboard segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"BITEmbedPostsSegue"])
    {
        self.postsViewController = segue.destinationViewController;
    }
}

@end
