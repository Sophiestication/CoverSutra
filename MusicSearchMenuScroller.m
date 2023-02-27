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

#import "MusicSearchMenuScroller.h"

#import "MusicSearchMenuView.h"

#import "NSBezierPath+Additions.h"
#import "NSImage+Additions.h"

@interface NSScrollView(SnowLeopard)

- (void)setAutoforwardsScrollWheelEvents:(BOOL)autoforwardsScrollWheelEvents;

@end

@implementation MusicSearchMenuScroller

+ (BOOL)isCompatibleWithOverlayScrollers {
    return self == [MusicSearchMenuScroller class];
}

+ (CGFloat)scrollerWidthForControlSize:(NSControlSize)controlSize {
	return 11.0;
}

- (NSRect)rectForPart:(NSScrollerPart)partCode {
	if(partCode == NSScrollerKnob) {
		NSRect defaultKnobRect = [super rectForPart:partCode];
        NSRect knobRect = self.bounds; //[super rectForPart:partCode];
		
		knobRect.origin.x += 1.0;
		knobRect.size.width = 9.0;
		
		knobRect.origin.y = defaultKnobRect.origin.y;
		knobRect.size.height = defaultKnobRect.size.height;
		
		return knobRect;
    }
    
    if(partCode == NSScrollerKnobSlot) {
		NSRect knobSlotRect = NSMakeRect(
			0.0,
			3.0,
			11.0,
			NSHeight([self bounds]) - 7.0);
		return knobSlotRect;
    }

	// return [super rectForPart:partCode];
	return NSZeroRect;
}

- (BOOL)isOpaque {
	return NO;
}

- (void)drawKnob {
	if([self respondsToSelector:@selector(scrollerStyle)]) {
		[super drawKnob];
		return;
	}
	
	NSRect knobRect = [self rectForPart:NSScrollerKnob];

	NSDrawThreePartImage(
		knobRect,
		[NSImage imageNamed:@"searchMenuScrollerKnobTop"],
		[NSImage imageNamed:@"searchMenuScrollerKnobMiddle"],
		[NSImage imageNamed:@"searchMenuScrollerKnobBottom"],
		YES,
		NSCompositeSourceOver,
		1.0,
		[self isFlipped]);
}

- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)highlight {
	if([self respondsToSelector:@selector(scrollerStyle)]) {
		[super drawKnobSlotInRect:slotRect highlight:highlight];
		return;
	}

	NSDrawThreePartImage(
        slotRect,
        [NSImage imageNamed:@"searchMenuScrollerSlotTop"],
        [NSImage imageNamed:@"searchMenuScrollerSlotMiddle"],
        [NSImage imageNamed:@"searchMenuScrollerSlotBottom"],
        YES,
        NSCompositeSourceOver,
        1.0,
        [self isFlipped]);
}

- (void)drawArrow:(NSScrollerArrow)whichArrow highlight:(BOOL)flag {
	// We ain't need no stinking arrows
}

- (void)drawRect:(NSRect)rect {
//	[[NSColor orangeColor] set];
//	NSRectFill(rect);
	
	if([self respondsToSelector:@selector(scrollerStyle)]) {
		[super drawRect:rect];
		return;
	}
	
	NSRect slotRect = [self rectForPart:NSScrollerKnobSlot];
	
	NSDrawThreePartImage(
		slotRect,
		[NSImage imageNamed:@"searchMenuScrollerSlotTop"],
		[NSImage imageNamed:@"searchMenuScrollerSlotMiddle"],
		[NSImage imageNamed:@"searchMenuScrollerSlotBottom"],
		YES,
		NSCompositeSourceOver,
		1.0,
		[self isFlipped]);

	[self drawKnob];
}

@end

@implementation MusicSearchMenuScrollView

/*
- (void)drawRect:(NSRect)rect {
	[[NSColor orangeColor] set];
	NSRectFill(rect);
}
*/

- (void)awakeFromNib {
	NSView* documentView = [self documentView];
	
	if([self respondsToSelector:@selector(setHorizontalScrollElasticity:)]) {
		[self setHorizontalScrollElasticity:NO];
		
		[self setScrollerStyle:NSScrollerStyleOverlay];
		[self setScrollerKnobStyle:NSScrollerKnobStyleLight];
	}
	
	[self setHasHorizontalScroller:NO];
	[self setDrawsBackground:NO];
	
	NSClipView* newClipView = [[MusicSearchMenuClipView alloc] initWithFrame:NSZeroRect];
	
	[newClipView setDrawsBackground:[self drawsBackground]];
	[newClipView setBackgroundColor:[self backgroundColor]];
	[newClipView setCopiesOnScroll:NO];
	
	[newClipView setDocumentCursor:[NSCursor arrowCursor]];
	
	if([self respondsToSelector:@selector(setAutoforwardsScrollWheelEvents:)]) {
		[self setAutoforwardsScrollWheelEvents:NO];
	}

	[self setContentView:newClipView];

	[self setDocumentView:documentView];
}

- (BOOL)isOpaque {
	return NO;
}

- (void)scrollWheel:(NSEvent*)theEvent {
	MusicSearchMenuView* menuView = (MusicSearchMenuView*)self.documentView;
	menuView.selection = nil;
	menuView.selectedAlbum = nil;
	
//	CGFloat delta = theEvent.deltaY;
//	NSRect documentVisibleRect = self.documentVisibleRect;
	
//	if(delta > 0.0 && NSMinY(documentVisibleRect) <= 0.0) {
//		return;
//	}
	
//	if(delta > 0.0 && NSMaxY(documentVisibleRect) >= NSHeight(documentVisibleRect)) {
//		return;
//	}
	
	[super scrollWheel:theEvent];
}

@end

@implementation MusicSearchMenuClipView

- (NSPoint)constrainScrollPoint:(NSPoint)newOrigin {
	NSRect frame = [(NSView*)[self documentView] frame];
	NSPoint origin = frame.origin;
	
	newOrigin.x = origin.x;
//	newOrigin.y = MIN(newOrigin.y, NSMaxY(frame));
	
	return [super constrainScrollPoint:newOrigin];
}

- (BOOL)isOpaque {
	return NO;
}

@end
