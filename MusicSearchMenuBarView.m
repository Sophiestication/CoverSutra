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

#import "MusicSearchMenuBarView.h"

#import "NSGradient+Additions.h"

@implementation MusicSearchMenuBarView

- (void)awakeFromNib {
	// Register for control tint changeing notifications
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_controlTintDidChange:)
		name:NSControlTintDidChangeNotification
		object:NSApp];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

- (BOOL)isOpaque {
	return NO;
}

- (void)drawRect:(NSRect)rect {
	[[NSImage imageNamed:@"searchMenuTop"]
		drawAtPoint:NSZeroPoint
		fromRect:NSZeroRect
		operation:NSCompositeSourceOver
		fraction:1.0];
}

- (void)drawRect2:(NSRect)rect {
	[super drawRect:rect];
	
	NSRect frame = self.bounds;
	
	if(!_contentGradient) {
		_contentGradient = [NSGradient selectedMenuItemGradientForHeight:NSHeight(frame)];
	}
	
	CGFloat angle = [self isFlipped] ? 90.0 : -90.0;
	[_contentGradient drawInRect:frame angle:angle];

/*	
	NSRect barFrame = frame;
	barFrame.size.height -= 14.0;
	barFrame.origin.y += 14.0;
	
	CGFloat arrowWidth = 28.0;
	NSBezierPath* arrowPath = [NSBezierPath bezierPath];
	
	[arrowPath moveToPoint:NSMakePoint(
		NSMidX(barFrame) - arrowWidth * 0.5,
		NSMinY(barFrame))];
	[arrowPath lineToPoint:NSMakePoint(
		NSMidX(barFrame),
		NSMinY(frame))];
	[arrowPath lineToPoint:NSMakePoint(
		NSMidX(barFrame) + arrowWidth * 0.5,
		NSMinY(barFrame))];
	[arrowPath lineToPoint:NSMakePoint(
		NSMidX(barFrame) - arrowWidth * 0.5,
		NSMinY(barFrame))];
	
	[arrowPath closePath];
	
	NSBezierPath* searchBarPath = [NSBezierPath bezierPathWithRoundedRect:barFrame
		cornerRadius:8.0
		inCorners:CSBottomLeftCorner|CSBottomRightCorner];

	[searchBarPath appendBezierPath:arrowPath];

	[_searchBarGradient drawInBezierPath:searchBarPath angle:90.0];
*/
}

- (void)_controlTintDidChange:(NSNotification*)notification {
	_contentGradient = nil;
	[self setNeedsDisplay:YES];
}

@end
