//
//  DDWPPost.h
//  DDWPDemo
//
//  Created by Pauli Jokela on 20.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDWPPost : NSObject

@property (nonatomic) NSUInteger ID;
@property (nonatomic) NSUInteger order;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *excerpt;
@property (nonatomic, strong) NSString *date;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSArray *commentsArray;
@property (nonatomic, strong) NSURL *featuredImageURL;

@end
