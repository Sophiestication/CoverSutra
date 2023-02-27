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

#import "SCBezelImageView.h"
#import "SCBezelImageView+Private.h"

#import "NSString+Additions.h"

#import <QuartzCore/QuartzCore.h>

@implementation SCBezelImageView

@dynamic image;
@dynamic enabled;
@dynamic opacity;

#pragma mark -
#pragma mark Construction & Destruction

- (id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
		[self initIvars];
	}

    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    if(self = [super initWithCoder:coder]) {
		[self initIvars];
	}

    return self;
}

- (void)dealloc {
	self.image = nil;
	
}

#pragma mark -
#pragma mark NSAnimatablePropertyContainer

/*
+ (id)defaultAnimationForKey:(NSString*)key {
	if(SFEqualStrings(key, @"image")) {
		CATransition* transition = [CATransition animation];
		
		transition.type = kCATransitionFade;
		transition.duration = 0.2;
		transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
		
		return transition;
	}

	return [super defaultAnimationForKey:key];
}
*/

#pragma mark -
#pragma mark SCBezelImageView

- (NSImage*)image {
	return _image;
}

- (void)setImage:(NSImage*)image {
	if(self.image != image) {
		_image = image;
		
		[self setNeedsDisplay:YES];
	}
}

- (CGFloat)opacity {
	return _opacity;
}

- (void)setOpacity:(CGFloat)opacity {
	if(self.opacity != opacity) {
		_opacity = opacity;
		[self setNeedsDisplay:YES];
	}
}

- (BOOL)isEnabled {
	return _enabled;
}

- (void)setEnabled:(BOOL)enabled {
	if(self.enabled != enabled) {
		_enabled = enabled;
		[self setNeedsDisplay:YES];
	}
}

#pragma mark -
#pragma mark NSView

+ (NSFocusRingType)defaultFocusRingType { return NSFocusRingTypeNone; }

- (BOOL)isFlipped { return YES; }

- (BOOL)wantsDefaultClipping { return YES; }
- (BOOL)isOpaque { return NO; }

- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];
	
//	print "I Love you"	
	
//	[[NSColor orangeColor] set];
//	NSRectFill(rect);
	
	NSImage* image = self.image;
	
	if(!image) {
		return;
	}
	
	NSRect imageRect = self.bounds;
	
	CGFloat shadowInset = 6.0;
	imageRect.size.width -= shadowInset;
	imageRect.size.height -= shadowInset;
	
	NSDictionary* imageHints = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInt:NSImageInterpolationHigh], NSImageHintInterpolation,
		nil];
	
	// Make a tinted image representation
	NSImage* tintedImage = [[NSImage alloc] initWithSize:imageRect.size];
	
	[tintedImage lockFocus]; {
		
		if(self.enabled) {
			[[NSColor whiteColor] set];
		} else {
			[[NSColor colorWithDeviceWhite:0.0 alpha:0.5] set];
		}
		
		NSRectFill(imageRect);
	
		[image drawInRect:imageRect
			fromRect:NSZeroRect
			operation:NSCompositeDestinationIn
			fraction:1.0
			respectFlipped:YES
			hints:imageHints];
	
	} [tintedImage unlockFocus];
	
//	// Set the context opacity
//	CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
//	CGContextSetAlpha(context, [self opacity]);
	
	// Draw the tinted image (with a drop shadow if needed) into our view
	if(self.enabled) {
		NSShadow* shadow = [[NSShadow alloc] init];
		
		[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
		[shadow setShadowBlurRadius:2.0];
		
		NSColor* shadowColor = [NSColor colorWithDeviceWhite:0.0 alpha:0.6];
		[shadow setShadowColor:shadowColor];
	
		[shadow set];
	}
	
	imageRect = NSOffsetRect(imageRect, 3.0, 2.0); // account in image shadows
	
	[tintedImage drawInRect:imageRect
		fromRect:NSZeroRect
		operation:NSCompositeSourceOver
		fraction:1.0
		respectFlipped:YES
		hints:imageHints];
	
}

#pragma mark -
#pragma mark Private

- (void)initIvars {
	self.image = nil;
	self.enabled = YES;
	self.opacity = 1.0;
}

@end
