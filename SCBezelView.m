//
// MIT License
//
// Copyright (c) 2006-2023 Sophiestication Software, Inc.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

#import "SCBezelView.h"
#import "SCBezelView+Private.h"

#import "NSString+Additions.h"

#import <QuartzCore/QuartzCore.h>

@implementation SCBezelView

@synthesize clippingPath = clippingPath_;
@synthesize backgroundColor = backgroundColor_;

#pragma mark -
#pragma mark Construction & Destruction

- (id)initWithFrame:(NSRect)frame {
    if((self = [super initWithFrame:frame])) {
	}

    return self;
}

#pragma mark -
#pragma mark NSAnimatablePropertyContainer

+ (id)defaultAnimationForKey:(NSString*)key {
	if(SFEqualStrings(key, @"subviews") ||
	   SFEqualStrings(key, NSAnimationTriggerOrderIn) ||
	   SFEqualStrings(key, NSAnimationTriggerOrderOut)) {
		CATransition* transition = [CATransition animation];
		
		transition.type = kCATransitionFade;
		transition.duration = 0.2;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		
		return transition;
	}

	return [super defaultAnimationForKey:key];
}

#pragma mark -
#pragma mark NSView

- (BOOL)isFlipped { return NO; }

- (BOOL)wantsDefaultClipping { return YES; }
- (BOOL)isOpaque { return NO; }

- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];

	NSRect bounds = self.bounds;
	[[self clippingPathForBounds:bounds] addClip];
	
	NSColor* backgroundColor = self.backgroundColor;
	
	if(!backgroundColor) {
		backgroundColor = [NSColor colorWithCalibratedWhite:0.0 alpha:0.15];
	}
	
	[backgroundColor set];
	NSRectFill(rect);
}

#pragma mark -
#pragma mark Private

- (NSBezierPath*)clippingPathForBounds:(NSRect)bounds {
	if(NSEqualRects([[self clippingPath] bounds], bounds)) {
		return self.clippingPath;
	}
	
	// Make a new path and cache it
	CGFloat const cornerRadius = 24.0;

	NSBezierPath* path = [NSBezierPath
		bezierPathWithRoundedRect:bounds
		xRadius:cornerRadius
		yRadius:cornerRadius];
		
	self.clippingPath = path;
	
	return path;
}

@end
