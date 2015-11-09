//
//  DDWPComment.h
//  DDWPDemo
//
//  Created by Pauli Jokela on 20.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDWPComment : NSObject

@property (nonatomic) NSUInteger postID;
@property (nonatomic) NSUInteger ID;

@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *date;

@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSURL *avatarURL;

@end
