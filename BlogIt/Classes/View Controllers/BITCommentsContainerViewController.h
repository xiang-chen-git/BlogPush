//
//  BITCommentsContainerViewController.h
//  BlogIt
//
//  Created by Pauli Jokela on 30.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BITCommentsContainerViewController : UIViewController

@property (nonatomic) NSUInteger postID;
@property (nonatomic, strong) NSMutableArray *commentsArray;

@end
