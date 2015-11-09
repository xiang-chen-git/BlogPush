//
//  BITCommentCell.h
//  BlogIt
//
//  Created by Pauli Jokela on 30.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BITCommentCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *authorLabel;
@property (nonatomic, strong) IBOutlet UIWebView *commentWebView;
@property (nonatomic, strong) IBOutlet UILabel *postedDateLabel;
@property (nonatomic, strong) IBOutlet UIImageView *avatarImageView;

@end
