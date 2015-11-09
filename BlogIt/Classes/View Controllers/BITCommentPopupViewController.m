//
//  BITCommentPopupViewController.m
//  BlogIt
//
//  Created by Pauli Jokela on 19.1.2015.
//  Copyright (c) 2015 Didstopia. All rights reserved.
//

#import "BITCommentPopupViewController.h"

#import "DDWP.h"

#import "KLCPopup.h"

@interface BITCommentPopupViewController ()

@end

@implementation BITCommentPopupViewController

- (void)viewDidLoad
{
    // Rounded corners for the view itself
    self.view.layer.cornerRadius = 4;
    self.view.layer.masksToBounds = NO;
    
    // Add a neat drop shadow for the view
    self.view.layer.shadowOffset = CGSizeMake(0, 10);
    self.view.layer.shadowRadius = 4;
    self.view.layer.shadowOpacity = 0.25;
    
    [super viewDidLoad];
}

- (void)submitNewCommentWithEmail:(NSString*)email andAuthor:(NSString*)author andComment:(NSString*)comment
{
    BOOL isValid = YES;
    
    // First we validate the length of all the fields
    if (author.length < 1 || email.length < 1 || comment.length < 1) isValid = NO;
    
    // Then we validate the email address formatting
    if (![self validateEmailAddress:email]) isValid = NO;
    
    [[DDWP shared] postComment:comment author:author email:email website:@"" postId:self.postID completion:^(NSError *error)
     {
         if (!error && isValid)
         {
             UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Your comment has been submitted." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [successAlert show];
             
             // Since there was no error, we'll clear out the text fields
             self.commentTextField.text = @"";
             self.nameTextField.text = @"";
             self.emailTextField.text = @"";
             
             // This gets rid of the popup with a sweet animation
             [self.popupRef dismiss:YES];
         }
         else if (error)
         {
             UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"An error occurred while trying to post your comment: %@", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [errorAlert show];
         }
         else if (!isValid)
         {
             UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please re-check your name, email and comment, then try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [errorAlert show];
         }
     }];
}

#pragma mark - Interface Builder actions

- (IBAction)cancelComment:(id)sender
{
    // This gets rid of the popup with a sweet animation
    [self.popupRef dismiss:YES];
}

- (IBAction)postComment:(id)sender
{
    [self submitNewCommentWithEmail:self.emailTextField.text andAuthor:self.nameTextField.text andComment:self.commentTextField.text];
}

#pragma mark - Utility functions

// A nifty regex (regular expression) function for
// checking if a string is indeed a valid email address
- (BOOL)validateEmailAddress:(NSString*)emailAddress
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:emailAddress];
}

@end
