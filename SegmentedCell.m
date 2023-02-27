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

#import "SegmentedCell.h"

#import "NSImage+Additions.h"
#import "NSView+Additions.h"
#import "NSShadow+Additions.h"

#ifndef NSAppKitVersionNumber10_7
#define NSAppKitVersionNumber10_7 1080.0
#endif

@implementation SegmentedCell

@synthesize
	delayedTarget = _delayedTarget,
	delayedAction = _delayedAction;

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	[self setBordered:YES];
	
	return self;
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView*)controlView {
	BOOL result = [super startTrackingAt:startPoint inView:controlView];
	
	// Send the delayed action after a certain amount of time
	if(self.delayedAction && self.delayedTarget) {
		CGFloat delay = 0.5; // TODO Make delay configurable
		
		[[self delayedTarget] performSelector:[self delayedAction]
			withObject:self
			afterDelay:delay 
			inModes:[NSArray arrayWithObjects:NSDefaultRunLoopMode, NSRunLoopCommonModes, NSEventTrackingRunLoopMode, nil]];
	}
	
	return result;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView*)controlView {
	return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView*)controlView mouseIsUp:(BOOL)flag {
	[super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
	
	// Cancel delayed invocation if needed
	id delayedTarget = self.delayedTarget;
	
	if(delayedTarget) {
		[[delayedTarget class] cancelPreviousPerformRequestsWithTarget:delayedTarget
			selector:[self delayedAction]
			object:self];
	}
}

- (NSSize)cellSize {
	NSSize cellSize = [super cellSize];
	
	if(self.controlView.HUDControl) {
		cellSize.height = ceil([[NSImage imageNamed:@"HUDSegmentedControl"] size].height / 3.0);
	}

	return cellSize;
}

- (NSSize)cellSizeForBounds:(NSRect)bounds {
	NSSize cellSize = [super cellSizeForBounds:bounds];
	
	if(self.controlView.HUDControl) {
		cellSize.height = MAX(cellSize.height, ceil([[NSImage imageNamed:@"HUDSegmentedControl"] size].height / 3.0));
	}

	return cellSize;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	// Draw none bordered if needed
	if(![self isBordered]) {
		[self drawInteriorWithFrame:cellFrame inView:controlView];
		return;
	}
 
	// Draw HUD styled if needed
	if(controlView.HUDControl) {
		[self drawHUDWithFrame:cellFrame inView:controlView];
		return;
	}
	
	[super drawWithFrame:cellFrame inView:controlView];
}

- (void)drawSegment:(NSInteger)segment inFrame:(NSRect)frame withView:(NSView*)controlView {
	// Adjust rectangle if we're drawing a HUD control
	if(controlView.HUDControl) {
		frame = NSOffsetRect(frame, 0.0, 1.0);
		
		if([self segmentCount] > 1) {
			if(segment == 0) {
				frame = NSOffsetRect(frame, 3.0, 0.0);
			} else if(segment + 1 == [self segmentCount]) {
				frame = NSOffsetRect(frame, -3.0, 0.0);
			}
		}
		
//		if(NSAppKitVersionNumber < NSAppKitVersionNumber10_7) {
//			[[NSShadow HUDImageShadow] set];
//		}
	}
	
	// Draw with shadow if we are in a navigation bar
	if(controlView.navigationBarControl) {
		if(![self isHighlighted]) { // && NSAppKitVersionNumber < NSAppKitVersionNumber10_7) {
			[[NSShadow navigationBarImageShadow] set];
		}
		
		if(NSAppKitVersionNumber >= NSAppKitVersionNumber10_7) {
			frame = NSOffsetRect(frame, 0.0, -2.0);
		}
	}

	[super drawSegment:segment inFrame:frame withView:controlView];
}

- (NSBackgroundStyle)backgroundStyle {
	if(self.controlView.HUDControl) {
		return NSBackgroundStyleDark|NSBackgroundStyleLowered;
	}
	
	if(self.controlView.navigationBarControl) {
		return NSBackgroundStyleDark; // return NSBackgroundStyleDark|NSBackgroundStyleRaised;
	}
	
	return [super backgroundStyle];
}

- (NSBackgroundStyle)interiorBackgroundStyleForSegment:(NSInteger)segment {
	if(self.controlView.HUDControl) {
		return NSBackgroundStyleDark|NSBackgroundStyleLowered;
	}
	
	if(self.controlView.navigationBarControl) {
		if([self isHighlighted]) {
			return NSBackgroundStyleRaised;
		}
		
		return NSBackgroundStyleDark; // return NSBackgroundStyleLowered;
	}
	
	return [super interiorBackgroundStyleForSegment:segment];
}

// HUD style interface

- (void)drawHUDWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSInteger numberOfSegments = [self segmentCount];
	NSInteger segmentIndex = 0;
	
	NSImage* image = [NSImage imageNamed:@"HUDSegmentedControl"];
	NSSize imageSize = image.size;
	
	CGFloat leftCapWidth = 12.0;
	CGFloat rightCapWidth = 12.0;
	
	CGFloat contentWidth = 4.0;
	
	CGFloat seperatorWidth = 1.0;
	CGFloat separatorOffsetX = 42.0;

	CGFloat capsuleHeight = imageSize.height / 3.0;
	
	if(numberOfSegments == 1) {
		CGFloat offsetY = ceilf(capsuleHeight * 2.0);

		if([self isSelectedForSegment:0]) {
			offsetY = 0.0;
		}
		
		[image drawFlippedInRect:NSMakeRect(NSMinX(cellFrame), NSMinY(cellFrame), leftCapWidth, NSHeight(cellFrame))
			fromRect:NSMakeRect(0.0, offsetY, leftCapWidth, capsuleHeight)
			operation:NSCompositeSourceOver
			fraction:1.0];
		
		[image drawFlippedInRect:NSMakeRect(NSMinX(cellFrame) + leftCapWidth, NSMinY(cellFrame), NSWidth(cellFrame) - leftCapWidth - rightCapWidth, NSHeight(cellFrame))
			fromRect:NSMakeRect(leftCapWidth, offsetY, contentWidth, capsuleHeight)
			operation:NSCompositeSourceOver
			fraction:1.0];
		
		[image drawFlippedInRect:NSMakeRect(NSMaxX(cellFrame) - rightCapWidth, NSMinY(cellFrame), rightCapWidth, NSHeight(cellFrame))
			fromRect:NSMakeRect(imageSize.width - rightCapWidth, offsetY, rightCapWidth, capsuleHeight)
			operation:NSCompositeSourceOver
			fraction:1.0];
		
		[self drawHUDInteriorWithFrame:cellFrame inView:controlView];
		
		return;
	}

	CGFloat offsetX = NSMinX(cellFrame);
	
	for(; segmentIndex < numberOfSegments; ++segmentIndex) {
		CGFloat width = [self widthForSegment:segmentIndex];
		BOOL selected = [self selectedSegment] == segmentIndex;
		
		CGFloat offsetY = selected ? 0.0 : capsuleHeight * 2.0;
		
		if(segmentIndex == 0) {
			[image drawFlippedInRect:NSMakeRect(offsetX, NSMinY(cellFrame), leftCapWidth, NSHeight(cellFrame))
				fromRect:NSMakeRect(0.0, offsetY, leftCapWidth, capsuleHeight)
				operation:NSCompositeSourceOver
				fraction:1.0];
			[image drawFlippedInRect:NSMakeRect(offsetX + leftCapWidth, NSMinY(cellFrame), width - leftCapWidth, NSHeight(cellFrame))
				fromRect:NSMakeRect(leftCapWidth, offsetY, contentWidth, capsuleHeight)
				operation:NSCompositeSourceOver
				fraction:1.0];
		} else if(segmentIndex + 1 == numberOfSegments) {
			[image drawFlippedInRect:NSMakeRect(offsetX, NSMinY(cellFrame), seperatorWidth, NSHeight(cellFrame))
				fromRect:NSMakeRect(separatorOffsetX, capsuleHeight * 2.0, seperatorWidth, capsuleHeight)
				operation:NSCompositeSourceOver
				fraction:1.0];
			[image drawFlippedInRect:NSMakeRect(offsetX + seperatorWidth, NSMinY(cellFrame), width - seperatorWidth - rightCapWidth, NSHeight(cellFrame))
				fromRect:NSMakeRect(leftCapWidth, offsetY, contentWidth, capsuleHeight)
				operation:NSCompositeSourceOver
				fraction:1.0];
			[image drawFlippedInRect:NSMakeRect(offsetX + width - rightCapWidth, NSMinY(cellFrame), rightCapWidth, NSHeight(cellFrame))
				fromRect:NSMakeRect(imageSize.width - rightCapWidth, offsetY, rightCapWidth, capsuleHeight)
				operation:NSCompositeSourceOver
				fraction:1.0];
		} else {
			[image drawFlippedInRect:NSMakeRect(offsetX, NSMinY(cellFrame), seperatorWidth, NSHeight(cellFrame))
				fromRect:NSMakeRect(separatorOffsetX, capsuleHeight * 2.0, seperatorWidth, capsuleHeight)
				operation:NSCompositeSourceOver
				fraction:1.0];
			[image drawFlippedInRect:NSMakeRect(offsetX + seperatorWidth, NSMinY(cellFrame), width - seperatorWidth, NSHeight(cellFrame))
				fromRect:NSMakeRect(leftCapWidth, offsetY, contentWidth, capsuleHeight)
				operation:NSCompositeSourceOver
				fraction:1.0];
		}
		
		offsetX += width;
	}

	[self drawHUDInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawHUDInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	if(NSAppKitVersionNumber >= NSAppKitVersionNumber10_7) {
		cellFrame = NSOffsetRect(cellFrame, 0.0, -3.0);
	}
	
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
