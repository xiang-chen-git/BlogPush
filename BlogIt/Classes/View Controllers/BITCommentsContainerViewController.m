//
//  BITCommentsContainerViewController.m
//  BlogIt
//
//  Created by Pauli Jokela on 30.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import "BITCommentsContainerViewController.h"

#import "BITCommentsViewController.h"

#import "DDWP.h"

#import "KLCPopup.h"

#import "BITCommentPopupViewController.h"

@interface BITCommentsContainerViewController () <UITextFieldDelegate>

@property (nonatomic, strong) BITCommentPopupViewController *commentPopupViewController;
@property (nonatomic, strong) KLCPopup *commentPopup;

@end

@implementation BITCommentsContainerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create the comment popup controller just once, so we can resume commenting (as long as we don't close the comment view)
#if BLOGIT_AD_FREE == 0
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_Autolayout" bundle:nil];
#else
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard_Autolayout_NoAds" bundle:nil];
#endif
    self.commentPopupViewController  = [storyboard instantiateViewControllerWithIdentifier:@"BITCommentPopupViewController"];
    self.commentPopupViewController.postID = self.postID;
}

- (IBAction)addNewComment:(id)sender
{
    // Create the actual popup, assign a reference of the popup to the controller, then finally show the popup
    self.commentPopup = [KLCPopup popupWithContentView:self.commentPopupViewController.view showType:KLCPopupShowTypeBounceInFromBottom dismissType:KLCPopupDismissTypeBounceOutToTop maskType:KLCPopupMaskTypeDimmed dismissOnBackgroundTouch:YES dismissOnContentTouch:NO];
    
    self.commentPopupViewController.popupRef = self.commentPopup;
    
    // Fixes an issue with the popup library not finding the correct view controller
    [self.view addSubview:self.commentPopup];
    
    [self.commentPopup showAtCenter:CGPointMake(self.view.center.x, self.commentPopupViewController.view.bounds.size.height / 2 + ((self.view.frame.size.width - self.commentPopupViewController.view.frame.size.width) / 2)) inView:self.view];
    
    // Activate the first field (name) and show the keyboard
    [self.commentPopupViewController.nameTextField becomeFirstResponder];
}

#pragma mark - Storyboard segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"BITEmbedCommentSegue"])
    {
        // Get the single post view controller
        BITCommentsViewController *commentsViewController = segue.destinationViewController;
        
        // Assign our selected post to the single post view controller
        commentsViewController.commentsArray = [self.commentsArray mutableCopy];
    }
}

@end
