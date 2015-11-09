//
//  BITPostsViewController.m
//  BlogIt
//
//  Created by Pauli Jokela on 20.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import "BITPostsViewController.h"

#import "BITConfig.h"

#import "DDWP.h"

#import "BITPostCell.h"

#import "BITSinglePostViewController.h"

#import "BITViewZoomAnimation.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

#import "CBStoreHouseRefreshControl.h"

@interface BITPostsViewController () <UIViewControllerTransitioningDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) id<BitViewAnimation> animationController;

@property (nonatomic, strong) CBStoreHouseRefreshControl *customRefreshControl;

@property (nonatomic) BOOL isRefreshing;

@end

@implementation BITPostsViewController

#pragma mark - Initialization

- (void)awakeFromNib
{
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    [self reload];
    
    [super awakeFromNib];
}

// Gets all of our posts and reloads the table/user interface once done
- (void)reload
{
    self.isRefreshing = YES;
    
    // Do we load a category, or latests posts?
    if (self.categoryName.length > 0)
    {
        [[DDWP shared] getPostsForPage:self.currentPage withCategorySlug:self.categorySlug completion:^(NSArray *posts, NSError *error)
         {
             if (posts && !error)
             {
                 if (self.postsArray.count < 1)
                 {
                     self.postsArray = [posts mutableCopy];
                     [self.tableView reloadData];
                 }
                 else if (![self addNewPostsFromArray:posts])
                 {
                     // If we had no new items, move back one page
                     if (self.currentPage > 0) self.currentPage--;
                 }
             }
             else
             {
                 NSLog(@"Error: %@", error);
             }
             
             self.isRefreshing = NO;
             
             // We're delaying this by half a second, to let the "refresh animation" finish
             [self.customRefreshControl performSelector:@selector(finishingLoading) withObject:nil afterDelay:0.5];
         }];
    }
    else
    {
        [[DDWP shared] getPostsForPage:self.currentPage completion:^(NSArray *posts, NSError *error)
         {
             if (posts && !error)
             {
                 if (self.postsArray.count < 1)
                 {
                     self.postsArray = [posts mutableCopy];
                     [self.tableView reloadData];
                 }
                 else if (![self addNewPostsFromArray:posts])
                 {
                     // If we had no new items, move back one page
                     if (self.currentPage > 0) self.currentPage--;
                 }
             }
             else
             {
                 NSLog(@"Error: %@", error);
             }
             
             self.isRefreshing = NO;
             
             // We're delaying this by half a second, to let the "refresh animation" finish
             [self.customRefreshControl performSelector:@selector(finishingLoading) withObject:nil afterDelay:0.5];
         }];
    }
}

- (BOOL)addNewPostsFromArray:(NSArray*)posts
{
    // Only add new posts
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NONE %@.ID == ID", self.postsArray];
    NSArray *resultsArray = [posts filteredArrayUsingPredicate:predicate];
    
    if (resultsArray.count < 1) return NO;
    
    [self.tableView beginUpdates];
    for (DDWPPost *newPost in resultsArray)
    {
        [self.postsArray insertObject:newPost atIndex:self.postsArray.count];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.postsArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
    
    return YES;
}

- (void)viewDidLoad
{
    // This is our custom refresh control that you can see when you pull down
    self.customRefreshControl = [CBStoreHouseRefreshControl attachToScrollView:self.tableView target:self refreshAction:@selector(reload) plist:@"Logo"];
    
    // This handles the custom animation when a cell has been selected
    self.animationController = [[BITViewZoomAnimation alloc] init];
    
    // This sets the cell's "zooming" animation when they come in to view
    self.cellZoomInitialAlpha = [NSNumber numberWithFloat:0.5];
    self.cellZoomAnimationDuration = [NSNumber numberWithFloat:0.4];
    self.cellZoomXScaleFactor = [NSNumber numberWithFloat:0.6];
    self.cellZoomYScaleFactor = [NSNumber numberWithFloat:0.6];
    self.cellZoomXOffset = [NSNumber numberWithFloat:0];
    self.cellZoomYOffset = [NSNumber numberWithFloat:0];
    
    self.currentPage = 1;
    self.previousPage = 1;
    
    [self.tableView setScrollsToTop:YES];
    
    [super viewDidLoad];
}

#pragma mark - Scroll view delegate, used for the custom refresh control

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.customRefreshControl scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.customRefreshControl scrollViewDidEndDragging];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.postsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Initialize our custom cell
    BITPostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BITPostCell" forIndexPath:indexPath];
    
    // Get the current post
    DDWPPost *post = (DDWPPost*)self.postsArray[indexPath.row];
    
    [cell setBackgroundColor:[UIColor blackColor]];
    
    // Set the date, title and excerpt (short content) labels from the current post
    [cell.dateLabel setText:[DDWP formattedDateStringFromDateString:post.date]];
    [cell.titleLabel setText:[DDWP stringByStrippingHTML:post.title]];
    [cell.excerptLabel setText:[DDWP stringByStrippingHTML:post.excerpt]];
    
    // If we have a featured image, start loading it, otherwise show a placeholder image
    if (post.featuredImageURL) [cell.featuredImageView setImageWithURL:post.featuredImageURL placeholderImage:[UIImage imageNamed:@"No image"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    else [cell.featuredImageView setImage:[UIImage imageNamed:@"No image"]];
    
    // Push the featured image to appear behind everything else
    if (cell.featuredImageView) [cell.contentView sendSubviewToBack:cell.featuredImageView];
    
    // This just resets the zoom animation for the cells
    [self resetViewedCells];
    
    // Set the initial transparency to 50%
    [cell.dateLabel setAlpha:0.5];
    [cell.titleLabel setAlpha:0.5];
    [cell.excerptLabel setAlpha:0.5];
    if (cell.featuredImageView) [cell.featuredImageView setAlpha:0.5];
    
    // Animate to 100% transparency, to create a neat little effect
    [UIView beginAnimations:@"BITPostCellFadeIn" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.6];
    [cell.dateLabel setAlpha:1];
    [cell.titleLabel setAlpha:1];
    [cell.excerptLabel setAlpha:1];
    if (cell.featuredImageView) [cell.featuredImageView setAlpha:1];
    [UIView commitAnimations];
    
    // If the current cell is last cell, load more (if we can)
    if (self.postsArray.count > 0 && indexPath.row == (self.postsArray.count - 1))
    {
        if (!self.isRefreshing)
        {
            NSLog(@"Refreshing..");
            
            self.currentPage++;
            
            [self reload];
        }
        else NSLog(@"Already refreshing!");
    }
    
    return cell;
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

#pragma mark - Storyboard/segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"BITSinglePostSegue"])
    {
        // This just resets the zoom animation for the cells
        [self resetViewedCells];
        
        // Get the single post view controller
        BITSinglePostViewController *singlePostViewController = segue.destinationViewController;
        singlePostViewController.transitioningDelegate  = self;
        
        // Get the selected cell
        BITPostCell *cell = (BITPostCell*)sender;
        
        // Get the index path for that cell
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        // Finally we can get the post from that index path
        DDWPPost *post = (DDWPPost*)self.postsArray[indexPath.row];
        
        // Assign our selected post to the single post view controller
        singlePostViewController.post = post;
    }
}

@end
