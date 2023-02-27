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

#import "StatusItemControl.h"
#import "StatusItemControl+Private.h"

#import "StatusItemCell.h"

#import "CoverSutra.h"
#import "CoverSutra+Menu.h"

#import "Utilities.h"

#import <QuartzCore/QuartzCore.h>

@implementation StatusItemControl

@synthesize statusItem = _statusItem;
@dynamic image;
@dynamic dimmed;
@dynamic alphaValue;
@dynamic scaleFactor;

+ (void)initialize {
	[self setCellClass:[StatusItemCell class]];
}

+ (id)defaultAnimationForKey:(NSString*)key {
	if(EqualStrings(key, @"scaleFactor")) {
		return [CABasicAnimation animation];
	}
	
	if(EqualStrings(key, @"alphaValue")) {
		return [CABasicAnimation animation];
	}

	return [super defaultAnimationForKey:key];
}

- (id)initWithStatusItem:(NSStatusItem*)statusItem {
	if(![super initWithFrame:NSZeroRect]) {
		return nil;
	}
	
	_statusItem = statusItem;
	
	[self sendActionOn:NSLeftMouseDown|NSRightMouseDown];
//	self.wantsLayer = YES;

//	NSImage* statusImage = [NSImage imageNamed:@"statusItemTemplate"];
//	
//	[statusImage setTemplate:YES];
//	[statusImage setSize:NSMakeSize(17.0, 17.0)];
//	
//	[self setImage:statusImage];
	
	return self;
}

- (NSImage*)image {
	return [[self cell] image];
}

- (void)setImage:(NSImage*)image {
	[image setScalesWhenResized:NO];
	[image setCacheMode:NSImageCacheNever];
	[[self cell] setImage:image];
	[self _tile];
	[self setNeedsDisplay:YES];
}

- (BOOL)isDimmed {
	return [[self cell] isDimmed];
}

- (void)setDimmed:(BOOL)dimmed {
	[[self cell] setDimmed:dimmed];
	[self setNeedsDisplay:YES];
}

- (CGFloat)alphaValue {
	return [[self cell] alphaValue];
}

- (void)setAlphaValue:(CGFloat)alphaValue {
	if(alphaValue != [self alphaValue]) {
		[[self cell] setAlphaValue:alphaValue];
		[self setNeedsDisplay:YES];
	}
}

- (CGFloat)scaleFactor {
	return [[self cell] scaleFactor];
}

- (void)setScaleFactor:(CGFloat)scaleFactor {
	if(scaleFactor != [self scaleFactor]) {
		[[self cell] setScaleFactor:scaleFactor];
		[self setNeedsDisplay:YES];
		
		if(scaleFactor <= 0.0) {
			NSSize newFrameSize = [[self cell] cellSize];
			newFrameSize.width = 0.0;
			[self setFrameSize:newFrameSize];
		}
	}
}

- (BOOL)acceptsFirstMouse:(NSEvent*)theEvent {
	return YES;
}

- (void)rightMouseDown:(NSEvent*)theEvent {
	[self mouseDown:theEvent];
}

- (void)otherMouseDown:(NSEvent*)theEvent {
	[self mouseDown:theEvent];
}

- (NSMenu*)menuForEvent:(NSEvent*)theEvent {
	return nil;
}

- (void)_tile {
	NSSize menuCellSize = [[self cell] cellSize];
	float menuBarThickness = [[[self statusItem] statusBar] thickness];
	
	[self setFrameSize:NSMakeSize(menuCellSize.width, menuBarThickness)];
}

@end
