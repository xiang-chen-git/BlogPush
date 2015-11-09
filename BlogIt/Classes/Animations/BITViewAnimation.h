//
//  BITViewAnimation.h
//  BlogIt
//
//  Created by Pauli Jokela on 14.1.2015.
//  Copyright (c) 2015 Didstopia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BitViewAnimation <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) NSTimeInterval presentationDuration;

@property (nonatomic, assign) NSTimeInterval dismissalDuration;

@property (nonatomic, assign) BOOL isPresenting;

@end
