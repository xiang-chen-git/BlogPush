//
//  BITSinglePostViewController.m
//  BlogIt
//
//  Created by Pauli Jokela on 29.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import "BITSinglePostViewController.h"

#import "BITConfig.h"

#import "DDWPPost.h"

#import "DDWP.h"

#import "BITCommentsContainerViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

#if BLOGIT_AD_FREE == 0
#import <iAd/iAd.h>
@import GoogleMobileAds;
#endif

// A simple macro for checking the current iOS version
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#if BLOGIT_AD_FREE == 0
@interface BITSinglePostViewController () <UIWebViewDelegate, ADBannerViewDelegate, GADBannerViewDelegate>

@property (nonatomic, strong) IBOutlet ADBannerView *adBannerIAD;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *iAdTopConstraint;

@property (nonatomic, strong) IBOutlet GADBannerView *adBannerADMOB;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *adMobTopConstraint;
#else
@interface BITSinglePostViewController () <UIWebViewDelegate>
#endif

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *toolbarBottomConstraint;

#if BLOGIT_AD_FREE == 0
@property (nonatomic) BOOL iAdBannerVisible;
@property (nonatomic) BOOL adMobBannerVisible;
#endif

@property (nonatomic, strong) IBOutlet UIView *overlayView;

@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIWebView *contentWebView;
@property (nonatomic, strong) IBOutlet UIImageView *featuredImageView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem *commentsBarButtonItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *shareBarButtonItem;

@end

@implementation BITSinglePostViewController

- (void)viewWillAppear:(BOOL)animated
{
    // Set the initial transparency to 50%
    if (self.featuredImageView) [self.featuredImageView setAlpha:0.5];
    [self.contentWebView setAlpha:0.5];
    [self.overlayView setAlpha:0.5];
    
    [super viewWillAppear:animated];
    
    // Animate to 100% transparency, to create a neat little effect
    [UIView beginAnimations:@"BITPostCellFadeIn" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.6];
    if (self.featuredImageView) [self.featuredImageView setAlpha:1];
    [self.contentWebView setAlpha:1];
    [self.overlayView setAlpha:1];
    [UIView commitAnimations];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Animate to 50% transparency, to create a neat little effect
    [UIView beginAnimations:@"BITPostCellFadeIn" context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView setAnimationDuration:0.6];
    if (self.featuredImageView) [self.featuredImageView setAlpha:0.5];
    [self.contentWebView setAlpha:0.5];
    [self.overlayView setAlpha:0.5];
    [UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if BLOGIT_AD_FREE == 0
    // Set the ad banners to be hidden by default
    self.iAdTopConstraint.constant = self.adBannerIAD.frame.size.height;
    self.adMobTopConstraint.constant = self.adBannerADMOB.frame.size.height;
#endif
    self.toolbarBottomConstraint.constant = 0;
    [self.view layoutIfNeeded];
    
#if BLOGIT_AD_FREE == 0
    if ([kBIT_ADS_PROVIDER isEqualToString:@"IAD"])
    {
        // Completely remove the AdMob banner
        self.adBannerADMOB.delegate = nil;
        [self.adBannerADMOB removeFromSuperview];
        self.adBannerADMOB = nil;
        self.adMobBannerVisible = NO;
    }
    else if ([kBIT_ADS_PROVIDER isEqualToString:@"ADMOB"])
    {
        // Completely remove the iAd banner
        self.adBannerIAD.delegate = nil;
        [self.adBannerIAD removeFromSuperview];
        self.adBannerIAD = nil;
        self.iAdBannerVisible = NO;
        
        // Setup an AdMob banner ad
        self.adBannerADMOB.adSize = kGADAdSizeSmartBannerPortrait;
        self.adBannerADMOB.delegate = self;
        self.adBannerADMOB.adUnitID = kBIT_ADS_ADMOB_ID;
        self.adBannerADMOB.rootViewController = self;
        
        // Load a new ad
        GADRequest *request = [GADRequest request];
        [self.adBannerADMOB loadRequest:request];
    }
#endif
    
    // Just in case, check if we have a post set
    if (self.post)
    {
        [self.overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35]];
        
        [self.dateLabel setText:[DDWP formattedDateStringFromDateString:self.post.date]];
        [self.titleLabel setText:[DDWP stringByStrippingHTML:self.post.title]];
        [self.contentWebView setDelegate:self];
        [self.contentWebView loadHTMLString:self.post.content baseURL:nil];
        
        if (self.post.featuredImageURL) [self.featuredImageView setImageWithURL:self.post.featuredImageURL placeholderImage:[UIImage imageNamed:@"No image"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        else [self.featuredImageView setImage:[UIImage imageNamed:@"No image"]];
        
        // Start loading comments for a specific post
        [[DDWP shared] getCommentsForPostWithId:self.post.ID completion:^(NSArray *comments, NSError *error)
        {
            self.post.commentsArray = comments;
            
            NSString *commentString = [NSString stringWithFormat:@"%i comments", (int)self.post.commentsArray.count];
            if (self.post.commentsArray.count == 0) commentString = @"No comments";
            else if (self.post.commentsArray.count == 1) commentString = @"1 comment";
            [self.commentsBarButtonItem setTitle:commentString];
        }];
    }
}

#pragma mark - UIWebView delegate

// Handles all web view requests
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType
{
    // Here we override all links and open them in Safari instead
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    else return YES;
}

#pragma mark - Storyboard/segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"BITCommentSegue"])
    {
        // Get the single post view controller
        BITCommentsContainerViewController *containerViewController = segue.destinationViewController;
        
        // Assign our selected post to the single post view controller
        containerViewController.postID = self.post.ID;
        containerViewController.commentsArray = [self.post.commentsArray mutableCopy];
    }
}

// Triggers a post sharing popup
- (IBAction)sharePost:(id)sender
{
    // We create an activity view controller, which let's the user share the post's title, website URL and featured image (if any),
    // using their favorite sharing service (Facebook, Twitter, Email, etc.)
    NSMutableArray *itemsToShare = [[NSMutableArray alloc] init];
    
    // Check if any of the values are null and don't include them if they are
    if (self.post.title != nil) [itemsToShare addObject:self.post.title];
    if (self.post.url != nil) [itemsToShare addObject:self.post.url];
    if (self.featuredImageView.image != nil) [itemsToShare addObject:self.featuredImageView.image];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:[itemsToShare copy] applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeCopyToPasteboard,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    activityVC.excludedActivityTypes = excludeActivities;
    
    // In iPads case, we need to show the share sheet from the share buttons view, but only on iOS 8+
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad && SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) activityVC.popoverPresentationController.sourceView = [self.shareBarButtonItem valueForKey:@"view"];
    
    // Show the activity view controller
    [self presentViewController:activityVC animated:YES completion:nil];
}

// Closes the "single post" view controller
- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Ad management

/*
    These following show/hide methods use Auto Layout
    to automatically manage the visibility of the ad frames.
*/

#if BLOGIT_AD_FREE == 0
- (void)showIAD
{
    if (!self.iAdBannerVisible)
    {
        [UIView animateWithDuration:0.25 animations:^
         {
             self.iAdTopConstraint.constant = 0;
             self.toolbarBottomConstraint.constant = self.adBannerIAD.frame.size.height;
             [self.view layoutIfNeeded];
         } completion:^(BOOL finished)
         {
             self.iAdBannerVisible = YES;
         }];
    }
    else
    {
        self.iAdTopConstraint.constant = 0;
        self.toolbarBottomConstraint.constant = self.adBannerIAD.frame.size.height;
        [self.view layoutIfNeeded];
    }
}
- (void)hideIAD
{
    if (self.iAdBannerVisible)
    {
        [UIView animateWithDuration:0.25 animations:^
         {
             self.iAdTopConstraint.constant = self.adBannerIAD.frame.size.height;
             self.toolbarBottomConstraint.constant = 0;
             [self.view layoutIfNeeded];
         } completion:^(BOOL finished)
         {
             self.iAdBannerVisible = NO;
         }];
    }
    else
    {
        self.iAdTopConstraint.constant = self.adBannerIAD.frame.size.height;
        self.toolbarBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }
}

- (void)showADMOB
{
    if (!self.adMobBannerVisible)
    {
        [UIView animateWithDuration:0.25 animations:^
         {
             self.adMobTopConstraint.constant = 0;
             self.toolbarBottomConstraint.constant = self.adBannerADMOB.frame.size.height;
             [self.view layoutIfNeeded];
         } completion:^(BOOL finished)
         {
             self.adMobBannerVisible = YES;
         }];
    }
    else
    {
        self.adMobTopConstraint.constant = 0;
        self.toolbarBottomConstraint.constant = self.adBannerADMOB.frame.size.height;
        [self.view layoutIfNeeded];
    }
}
- (void)hideADMOB
{
    if (self.adMobBannerVisible)
    {
        [UIView animateWithDuration:0.25 animations:^
         {
             self.adMobTopConstraint.constant = self.adBannerADMOB.frame.size.height;
             self.toolbarBottomConstraint.constant = 0;
             [self.view layoutIfNeeded];
         } completion:^(BOOL finished)
         {
             self.adMobBannerVisible = NO;
         }];
    }
    else
    {
        self.adMobTopConstraint.constant = self.adBannerADMOB.frame.size.height;
        self.toolbarBottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }
}
#endif

#pragma mark - iAd delegates

#if BLOGIT_AD_FREE == 0
// Called when an iAd ad successfully loaded
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    if ([kBIT_ADS_PROVIDER isEqualToString:@"IAD"])
    {
        // Show our new iAd ad
        [self showIAD];
    }
}

// Called when an iAd ad fails to load
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if ([kBIT_ADS_PROVIDER isEqualToString:@"IAD"])
    {
        // Hide our failed iAd ad
        [self hideIAD];
    }
}
#endif

#pragma mark - AdMob delegates

#if BLOGIT_AD_FREE == 0
// Called when an AdMob ad successfully loaded
- (void)adViewDidReceiveAd:(GADBannerView *)view
{
    if ([kBIT_ADS_PROVIDER isEqualToString:@"ADMOB"])
    {
        // Show our new AdMob ad
        [self showADMOB];
    }
}

// Called when an AdMob ad fails to load
- (void)adView:(GADBannerView *)view didFailToReceiveAdWithError:(GADRequestError *)error
{
    if ([kBIT_ADS_PROVIDER isEqualToString:@"ADMOB"])
    {
        // Hide our failed AdMob ad
        [self hideADMOB];
    }
}
#endif

@end
