//
//  NSView+AMViewAnimation.m
//  AMViewAnimation
//
//  Created by Andy Matuschak on 11/6/05.
//  Copyright 2005 Andy Matuschak. All rights reserved.
//

#import "NSView+AMViewAnimation.h"

NSTimeInterval AMDefaultAnimationDuration = -1; // -1 makes the system provide a default duration
NSAnimationBlockingMode AMDefaultAnimationBlockingMode = NSAnimationNonblocking;
NSAnimationCurve AMDefaultAnimationCurve = NSAnimationEaseInOut;

@implementation NSView (AMViewAnimation)

- (NSArray *)animationArrayForParameters:(NSDictionary *)params
{
	NSMutableDictionary *animationDetails = [NSMutableDictionary dictionaryWithDictionary:params];
	[animationDetails setObject:self forKey:NSViewAnimationTargetKey];
	return [NSArray arrayWithObject:animationDetails];
}

- (void)playAnimationWithParameters:(NSDictionary *)params
{
	NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations:[self animationArrayForParameters:params]];
	[animation setAnimationBlockingMode:AMDefaultAnimationBlockingMode];
	[animation setDuration:AMDefaultAnimationDuration];
	[animation setAnimationCurve:AMDefaultAnimationCurve];
	[animation setDelegate:self];
	[animation startAnimation];
}

- (void)animationDidEnd:(NSAnimation *)animation
{
	[animation release];
}

- (void)fadeWithEffect:effect
{
	[self playAnimationWithParameters:[NSDictionary dictionaryWithObject:effect forKey:NSViewAnimationEffectKey]];
}

- (IBAction)fadeOut:sender
{
	[self fadeWithEffect:NSViewAnimationFadeOutEffect];
}

- (IBAction)fadeIn:sender
{
	[self fadeWithEffect:NSViewAnimationFadeInEffect];
}

- (void)animateToFrame:(NSRect)newFrame
{
	[self playAnimationWithParameters:[NSDictionary dictionaryWithObject:[NSValue valueWithRect:newFrame] forKey:NSViewAnimationEndFrameKey]];
}

- (void)fadeToFrame:(NSRect)newFrame
{
	[self playAnimationWithParameters:[NSDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithRect:newFrame], NSViewAnimationEndFrameKey, [self isHidden] ? NSViewAnimationFadeInEffect : NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey, nil]];
}

+ (void)setDefaultDuration:(NSTimeInterval)duration
{
	AMDefaultAnimationDuration = duration;
}

+ (void)setDefaultBlockingMode:(NSAnimationBlockingMode)mode
{
	AMDefaultAnimationBlockingMode = mode;
}

+ (void)setDefaultAnimationCurve:(NSAnimationCurve)curve
{
	AMDefaultAnimationCurve = curve;
}

@end