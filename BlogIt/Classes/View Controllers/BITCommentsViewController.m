//
//  BITCommentsViewController.m
//  BlogIt
//
//  Created by Pauli Jokela on 30.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import "BITCommentsViewController.h"

#import "DDWP.h"

#import "BITCommentCell.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import "UIImageView+UIActivityIndicatorForSDWebImage.h"

@interface BITCommentsViewController ()

@end

@implementation BITCommentsViewController

#pragma mark - Initialization

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Remove all extra cell separators
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // If comments exist, show comments normally, otherwise show a "no comments found" view
    if (self.commentsArray != nil && self.commentsArray.count > 0) return 1;
    else
    {
        UILabel *noCommentsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        
        [noCommentsLabel setText:@"No comments yet.\n\nWhy don't you write one?"];
        [noCommentsLabel setTextColor:[UIColor lightGrayColor]];
        [noCommentsLabel setNumberOfLines:0];
        [noCommentsLabel setTextAlignment:NSTextAlignmentCenter];
        [noCommentsLabel setFont:[UIFont fontWithName:@"Avenir-Light" size:14]];
        [noCommentsLabel sizeToFit];
        
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        [self.tableView setBackgroundView:noCommentsLabel];
        
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BITCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BITCommentCell" forIndexPath:indexPath];
    
    // Get the current comment
    DDWPComment *comment = [self.commentsArray objectAtIndex:indexPath.row];
    
    // Set the comment name and content for the cell
    [cell.authorLabel setText:[DDWP stringByStrippingHTML:comment.author]];
    [cell.commentWebView loadHTMLString:comment.content baseURL:nil];
    
    // Parse the date and set it for the cell
    NSString *dateString = [DDWP timeElapsedString:comment.date];
    [cell.postedDateLabel setText:dateString];
    
    // If there's an avatar URL, load it, otherwise show our "anonymous" image
    if (comment.avatarURL) [cell.avatarImageView setImageWithURL:comment.avatarURL placeholderImage:[UIImage imageNamed:@"Anonymous icon"] usingActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    else [cell.avatarImageView setImage:[UIImage imageNamed:@"Anonymous icon"]];
    
    // Scale to fit and create a circular image view
    [cell.avatarImageView setContentMode:UIViewContentModeScaleAspectFit];
    cell.avatarImageView.layer.backgroundColor = [[UIColor clearColor] CGColor];
    cell.avatarImageView.layer.cornerRadius = cell.avatarImageView.frame.size.width / 2;
    cell.avatarImageView.layer.borderWidth = 0;
    cell.avatarImageView.clipsToBounds = YES;
    
    return cell;
}

@end
