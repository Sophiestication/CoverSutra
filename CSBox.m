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

#import "CSBox.h"

@implementation CSBox

- (BOOL)isOpaque {
	return NO;
}

- (BOOL)preservesContentDuringLiveResize {
	return YES;
}

- (void)drawRect:(NSRect)rect {
	if(NSHeight([self bounds]) <= 2.0) {
		NSRect topLine = rect;
		topLine.size.height = 1.0;
		topLine.origin.y = 1.0;
		
		[[NSColor colorWithCalibratedWhite:0.75 alpha:0.5] set];
		NSRectFillUsingOperation(topLine, NSCompositeSourceOver);
		
		
		NSRect bottomLine = rect;
		bottomLine.size.height = 1.0;
		bottomLine.origin.y = 0.0;
		
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.6] set];
		NSRectFillUsingOperation(bottomLine, NSCompositeSourceOver);
		
		return;
	}

	NSRect frame = NSInsetRect([self bounds], 0.0, 2.0);
	
	// Top border
	NSRect borderRect = NSMakeRect(
		NSMinX(frame), NSMaxY(frame) - 1.0,
		NSWidth(frame), 1.0);
		
	if(NSIntersectsRect(rect, borderRect)) {
		[[NSColor colorWithCalibratedWhite:0.75 alpha:0.5] set];
		NSRectFillUsingOperation(NSIntersectionRect(frame, borderRect), NSCompositeSourceOver);
	}
	
	borderRect = NSMakeRect(
		NSMinX(frame), NSMaxY(frame) - 2.0,
		NSWidth(frame), 1.0);
		
	if([self needsToDrawRect:borderRect]) {
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.6] set];
		NSRectFillUsingOperation(NSIntersectionRect(frame, borderRect), NSCompositeSourceOver);
	}
	
	// Bottom border
	borderRect = NSMakeRect(
		NSMinX(frame), NSMinY(frame) + 1.0,
		NSWidth(frame), 1.0);
		
	if([self needsToDrawRect:borderRect]) {
		[[NSColor colorWithCalibratedWhite:0.75 alpha:0.5] set];
		NSRectFillUsingOperation(NSIntersectionRect(frame, borderRect), NSCompositeSourceOver);
	}
	
	borderRect = NSMakeRect(
		NSMinX(frame), NSMinY(frame),
		NSWidth(frame), 1.0);
	
	if([self needsToDrawRect:borderRect]) {
		[[NSColor colorWithCalibratedWhite:1.0 alpha:0.9] set];
		NSRectFillUsingOperation(NSIntersectionRect(frame, borderRect), NSCompositeSourceOver);
	}
	
	// Content fill
	if([self needsToDrawRect:frame]) {
		[[NSColor colorWithCalibratedWhite:0.75 alpha:0.2] set];
		NSRectFillUsingOperation(NSIntersectionRect(frame, rect), NSCompositeSourceOver);
	}
}

@end
