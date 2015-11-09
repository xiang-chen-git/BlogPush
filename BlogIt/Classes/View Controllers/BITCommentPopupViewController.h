//
//  BITCommentPopupViewController.h
//  BlogIt
//
//  Created by Pauli Jokela on 19.1.2015.
//  Copyright (c) 2015 Didstopia. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KLCPopup;

@interface BITCommentPopupViewController : UIViewController

@property (nonatomic) NSUInteger postID;

@property (nonatomic, strong) IBOutlet UITextField *nameTextField;
@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *commentTextField;

@property (nonatomic, strong) KLCPopup *popupRef;

@end
