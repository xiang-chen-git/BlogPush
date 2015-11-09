//
//  BITPageCell.m
//  BlogIt
//
//  Created by Pauli Jokela on 30.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import "BITPageCell.h"

@implementation BITPageCell

// Simply sets the cell labels transparency when selected
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (selected) [self.textLabel setAlpha:1.0];
    else [self.textLabel setAlpha:0.75];
}

@end
