//
//  BITViewZoomAnimation.h
//  BlogIt
//
//  Created by Pauli Jokela on 14.1.2015.
//  Copyright (c) 2015 Didstopia. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BITViewAnimation.h"

@interface BITViewZoomAnimation : NSObject <BitViewAnimation>

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext;

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext;

@property (nonatomic, assign) NSTimeInterval presentationDuration;

@property (nonatomic, assign) NSTimeInterval dismissalDuration;

@property (nonatomic, assign) BOOL isPresenting;

@end
