//
//  BITPostCell.m
//  BlogIt
//
//  Created by Pauli Jokela on 20.12.2014.
//  Copyright (c) 2014 Didstopia. All rights reserved.
//

#import "BITPostCell.h"

@implementation BITPostCell

// Sets the cell's style
- (void)awakeFromNib
{
    [self setBackgroundColor:[UIColor blackColor]];
    [self.contentView setBackgroundColor:[UIColor blackColor]];
    [self.overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.35]];
}

// Simply sets the cell image's transparency when selected/highlighted
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted)
    {
        if (self.featuredImageView) [self.featuredImageView setAlpha:0.65];
    }
    else
    {
        if (self.featuredImageView) [self.featuredImageView setAlpha:1.0];
    }
}

@end
