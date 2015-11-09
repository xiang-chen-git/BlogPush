//
//  DDWPCategory.h
//  BlogIt
//
//  Created by Pauli Jokela on 26.1.2015.
//  Copyright (c) 2015 Didstopia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDWPCategory : NSObject

@property (nonatomic) NSUInteger ID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *slug;
@property (nonatomic) NSUInteger count;

@end
