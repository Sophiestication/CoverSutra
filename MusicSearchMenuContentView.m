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

#import "MusicSearchMenuContentView.h"
#import "MusicSearchMenuContentView+Private.h"

#import "CoverSutra.h"

#import "NSBezierPath+Additions.h"

@implementation MusicSearchMenuContentView

@synthesize
	searchResultsShown = _searchResultsShown;

- (void)awakeFromNib {
	_searchResultsShown = NO;
	
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

- (BOOL)isFlipped {
	return NO;
}

- (BOOL)isOpaque {
	return NO;
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

- (BOOL)searchResultsShown {
	return _searchResultsShown;
}

- (void)setSearchResultsShown:(BOOL)searchResultsShown {
	if(_searchResultsShown != searchResultsShown) {
		_searchResultsShown = searchResultsShown;
		[self setNeedsDisplay:YES];
	}
}

- (void)scrollWheel:(NSEvent*)theEvent {
}

- (void)drawRect:(NSRect)rect {
//	[[NSColor yellowColor] set];
//	NSRectFill(rect);
	
	NSRect frame = self.bounds;
	
	BOOL isGraphite = [NSColor currentControlTint] == NSGraphiteControlTint;
	
	if(self.searchResultsShown) {
		NSDrawThreePartImage(
			frame,
			[NSImage imageNamed:isGraphite ?
				@"graphiteSearchMenuTop" :
				@"aquaSearchMenuTop"],
			[NSImage imageNamed:@"searchMenuMiddle"],
			[NSImage imageNamed:@"searchMenuBottom"],
			YES,
			NSCompositeSourceOver,
			1.0,
			[self isFlipped]);
	} else {
		NSImage* image = [NSImage imageNamed:isGraphite ? 
			@"graphiteSearchMenuTopOnly" :
			@"aquaSearchMenuTopOnly"];
		NSPoint imageOrigin = NSMakePoint(
			NSMinX(frame),
			NSMaxY(frame) - image.size.height);
		
		[image
			drawAtPoint:imageOrigin
			fromRect:NSZeroRect
			operation:NSCompositeSourceOver
			fraction:1.0];
	}
	
	// Draw the arrow to the appropiate position
	NSImage* arrowImage = [NSImage imageNamed:isGraphite ? 
		@"graphiteSearchMenuArrow" :
		@"aquaSearchMenuArrow"];
	
	NSRect statusItemWindowFrame = [(NSWindow*)[[CoverSutra self] valueForKeyPath:@"statusItemController.statusItem.view.window"] frame];
	statusItemWindowFrame.origin = [self.window convertScreenToBase:statusItemWindowFrame.origin];
	statusItemWindowFrame = [self convertRectToBase:statusItemWindowFrame];
	
	CGFloat statusItemLocation = NSMaxX(statusItemWindowFrame) - (arrowImage.size.width * 0.5) - 13.0;

	statusItemLocation = MAX(statusItemLocation, NSMinX(frame) + 16.0);
	statusItemLocation = MIN(statusItemLocation, NSMaxX(frame) - 16.0);

	NSRect arrowImageRect = NSMakeRect(
		statusItemLocation, NSMaxY(frame) - arrowImage.size.height,
		arrowImage.size.width, arrowImage.size.height);
	
	[[NSColor clearColor] set];
//	NSRectFill(arrowImageRect);
	
	[arrowImage
		drawInRect:arrowImageRect
		fromRect:NSZeroRect
		operation:NSCompositeSourceOver
		fraction:1.0];
}

- (void)_controlTintDidChange:(NSNotification*)notification {
	[self setNeedsDisplay:YES];
}

@end
