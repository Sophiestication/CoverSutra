//
//  NSView+AMViewAnimation.h
//  AMViewAnimation
//
//  Created by Andy Matuschak on 11/6/05.
//  Copyright 2005 Andy Matuschak. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (AMViewAnimation)
- (IBAction)fadeOut:sender;
- (IBAction)fadeIn:sender;
- (void)animateToFrame:(NSRect)rect;
- (void)fadeToFrame:(NSRect)rect; // animates to supplied frame; fades in if view is hidden; fades out if view is visible

+ (void)setDefaultDuration:(NSTimeInterval)duration;
+ (void)setDefaultBlockingMode:(NSAnimationBlockingMode)mode;
+ (void)setDefaultAnimationCurve:(NSAnimationCurve)curve;
@end