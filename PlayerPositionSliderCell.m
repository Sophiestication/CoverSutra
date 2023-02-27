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

#import "PlayerPositionSliderCell.h"
#import "PlayerPositionSlider.h"

#import "PlaybackController.h"
#import "PlaybackController+Private.h"

#import "PlaybackController.h"
#import "CoverSutra.h"

#import "NSBezierPath+Additions.h"
#import "NSImage+Additions.h"

@implementation PlayerPositionSliderCell

+ (BOOL)prefersTrackingUntilMouseUp {
	return YES;
}

- (id)init {
	if((self = [super init])) {
		_tracking = NO;
		_needsToStopTracking = NO;
	
		_positionCell = [[NSTextFieldCell alloc] initTextCell:@""];
		[_positionCell setBordered:NO];
		[_positionCell setDrawsBackground:NO];
		[_positionCell setTextColor:
			[NSColor whiteColor]];
		[_positionCell setFont:
			[NSFont boldSystemFontOfSize:9.0]];
	
		_durationCell = [_positionCell copy];
		[_durationCell setStringValue:@""];
	}

	return self;
}


- (double)progress {
	double position = [[self positionInSeconds] doubleValue];
	double duration = [[self durationInSeconds] doubleValue];
	
	if(duration <= 0.0) {
		return 0.0;
	}
	
	return position / duration;
}

- (NSNumber*)positionInSeconds {
	return _positionInSeconds;
}

- (void)setPositionInSeconds:(NSNumber*)positionInSeconds {
	_positionInSeconds = positionInSeconds;
	
	[self _updatePlayerPositionAndDurationCells];
}

- (NSNumber*)durationInSeconds {
	return _durationInSeconds;
}

- (void)setDurationInSeconds:(NSNumber*)durationInSeconds {
	_durationInSeconds = durationInSeconds;
	
	[self _updatePlayerPositionAndDurationCells];
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView*)controlView {
	if(![self isEnabled]) {
		return NO;
	}
	
	// Check if the mouse is within the tracking bar
	NSRect trackingBarRect = [self trackingBarRectForFrame:[controlView bounds] inView:controlView];
	
	if(!NSPointInRect(startPoint, trackingBarRect)) {
		return NO;
	}
	
	if([_durationInSeconds integerValue] <= 0) {
		return NO;
	}

	// TODO
	[[[CoverSutra self] playbackController] setShouldNotUpdatePlayerPosition:YES];
	
	_tracking = YES;
	
	// Update from the initial mouse position
	[self _setProgressFromPoint:startPoint inView:controlView];
	
	while(1) {
        NSEvent* theEvent = [NSApp nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask
			untilDate:[NSDate distantFuture]
			inMode:NSEventTrackingRunLoopMode
			dequeue:NO];

        if([theEvent type] == NSLeftMouseUp) {
            [self stopTracking:startPoint
				at:startPoint
				inView:controlView
				mouseIsUp:YES];
			
			break;
		}
           
        [NSApp nextEventMatchingMask:NSLeftMouseDraggedMask
			untilDate:[NSDate distantFuture]
			inMode:NSEventTrackingRunLoopMode
			dequeue:YES];
        
		NSPoint point = [controlView convertPoint:[theEvent locationInWindow]
			fromView:nil];
        
		if(![self continueTracking:startPoint at:point inView:controlView]) {
			[self stopTracking:startPoint
				at:point
				inView:controlView
				mouseIsUp:NO];
			
			break;
		}
    }

	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView*)controlView {
//	if(!_needsToStopTracking) {
		[self _setProgressFromPoint:currentPoint inView:controlView];
		return YES;
//	}
//
//	return NO;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView*)controlView mouseIsUp:(BOOL)flag {
	_tracking = NO;
	_needsToStopTracking = NO;
	
	// TODO
	[[[CoverSutra self] playbackController] setShouldNotUpdatePlayerPosition:NO];
}

- (void)_setProgressFromPoint:(NSPoint)point inView:(NSView*)controlView {
	NSRect trackingBarRect = [self trackingBarRectForFrame:[controlView bounds] inView:controlView];
	
	trackingBarRect = NSInsetRect(trackingBarRect, 5.0, 0.0);
	
	double progress = (point.x - NSMinX(trackingBarRect)) / NSWidth(trackingBarRect);
	
	progress = MIN(progress, 1.0);
	progress = MAX(progress, 0.0);
	
	double playerPosition = [[self durationInSeconds] doubleValue] * progress;
	
//	playerPosition = rint(playerPosition);
	
	[(PlayerPositionSlider*)controlView setPositionInSeconds:[NSNumber numberWithDouble:playerPosition]];
	
	// TODO
	[[[CoverSutra self] playbackController] setPlayerPosition:playerPosition];
}

- (NSRect)trackingBarRectForFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSRect trackingRect;
	
	trackingRect = NSInsetRect(cellFrame, 3.0, 3.0);
	
	NSRect positionCellRect = [self positionCellRectForFrame:cellFrame inView:controlView];
	trackingRect.size.width -= NSWidth(positionCellRect);
	trackingRect.origin.x += NSWidth(positionCellRect);
	
	NSRect durationCellRect = [self durationCellRectForFrame:cellFrame inView:controlView];
	trackingRect.size.width -= NSWidth(durationCellRect);
	
	return trackingRect;
}

- (NSRect)knobRectForFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSRect trackingBarRect = [self trackingBarRectForFrame:cellFrame inView:controlView];
	
	trackingBarRect = NSInsetRect(trackingBarRect, 5.0, 0.0);
	
	CGFloat knobPosition = NSWidth(trackingBarRect) * [self progress];
	CGFloat knobSize = NSHeight(trackingBarRect);
	
	NSRect knobRect = NSMakeRect(
		NSMinX(trackingBarRect) + knobPosition - knobSize * 0.5, NSMinY(trackingBarRect),
		knobSize, knobSize);
	
	return knobRect;
}

- (NSRect)positionCellRectForFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSSize positionCellSize = [_positionCell cellSize];
	
	NSRect positionCellRect = NSMakeRect(
		NSMinX(cellFrame), NSMinY(cellFrame),
		positionCellSize.width, positionCellSize.height);
	
	positionCellRect = NSOffsetRect(positionCellRect, 0.0, 2.0);
	
	return positionCellRect;
}

- (NSRect)durationCellRectForFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSSize durationCellSize = [_durationCell cellSize];
	
	NSRect durationCellRect = NSMakeRect(
		NSMaxX(cellFrame) - durationCellSize.width, NSMinY(cellFrame),
		durationCellSize.width, durationCellSize.height);
	
	durationCellRect = NSOffsetRect(durationCellRect, 0.0, 2.0);
	
	return durationCellRect;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	[super drawWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
//	[[NSColor orangeColor] set];
//	NSRectFill(cellFrame);

	NSInteger durationInSeconds = [[self durationInSeconds] integerValue];
	
	// Draw the player position and duration strings
	[NSGraphicsContext saveGraphicsState]; {
		[[self _trackingBarShadow] set];
		
		NSRect positionCellRect = [self positionCellRectForFrame:cellFrame inView:controlView];
		[_positionCell drawWithFrame:positionCellRect inView:controlView];
		
		NSRect durationCellRect = [self durationCellRectForFrame:cellFrame inView:controlView];
		[_durationCell drawWithFrame:durationCellRect inView:controlView];
	} [NSGraphicsContext restoreGraphicsState];
	
	NSRect trackingBarRect = [self trackingBarRectForFrame:cellFrame inView:controlView];
	NSRect knobRect = [self knobRectForFrame:cellFrame inView:controlView];
	
	// Draw the tracking bar
	[NSGraphicsContext saveGraphicsState]; {
		CGFloat cornerRadius = NSHeight(trackingBarRect) * 0.5;
		NSBezierPath* sliderBarPath = [NSBezierPath bezierPathWithRoundedRect:
			NSInsetRect(trackingBarRect, 0.0, 0.5)
			xRadius:cornerRadius
			yRadius:cornerRadius];
		
		[NSGraphicsContext saveGraphicsState]; {
			[sliderBarPath addClip];
			
			NSRect trackingFillRect = NSMakeRect(
				NSMinX(trackingBarRect), NSMinY(trackingBarRect),
				NSMinX(cellFrame) - NSMinX(trackingBarRect) + NSMidX(knobRect), NSHeight(trackingBarRect));
			[[[NSColor whiteColor] colorWithAlphaComponent:0.25] set];
			
			if(durationInSeconds > 0) {
				NSRectFillUsingOperation(trackingFillRect, NSCompositeSourceOver);
			}
		} [NSGraphicsContext restoreGraphicsState];

		[[self _trackingBarShadow] set];
		
		[[NSColor whiteColor] set];
		[sliderBarPath stroke];
	} [NSGraphicsContext restoreGraphicsState];
	
	// Draw the tracking knob
	if(durationInSeconds > 0) {
		[[NSColor whiteColor] set];
		
		knobRect = NSInsetRect(knobRect, 1.0, 1.0);
		
		NSBezierPath* knob = [NSBezierPath bezierPath];
		
		[knob setLineJoinStyle:NSBevelLineJoinStyle];
		[knob setLineCapStyle:NSSquareLineCapStyle];
		[knob setFlatness:0.1];
		
		[knob moveToPoint:NSMakePoint(NSMidX(knobRect), NSMinY(knobRect))];
		[knob lineToPoint:NSMakePoint(NSMinX(knobRect), NSMidY(knobRect))];
		[knob lineToPoint:NSMakePoint(NSMidX(knobRect), NSMaxY(knobRect))];
		[knob lineToPoint:NSMakePoint(NSMaxX(knobRect), NSMidY(knobRect))];
		[knob lineToPoint:NSMakePoint(NSMidX(knobRect), NSMinY(knobRect))];
		
		[knob closePath];
		
		[knob fill];
	}
}

- (void)_updatePlayerPositionAndDurationCells {
	long long positionInSeconds = [[self positionInSeconds] longLongValue];

	unsigned long positionSeconds = positionInSeconds % 60;
	unsigned long positionMinutes = (positionInSeconds / 60) % 60;
	unsigned long positionHours = positionInSeconds / 3600;
	
	long long durationInSeconds = [[self durationInSeconds] longLongValue];
	
//	unsigned long durationSeconds = durationInSeconds % 60;
	unsigned long durationMinutes = (durationInSeconds / 60) % 60;
	unsigned long durationHours = durationInSeconds / 3600;
	
	long long remaining = MAX(durationInSeconds - positionInSeconds, 0);
	
	unsigned long remainingSeconds = remaining % 60;
	unsigned long remainingMinutes = (remaining / 60) % 60;
	unsigned long remainingHours = remaining / 3600;
	
	NSString* positionString = nil;
	NSString* durationString = nil;
	
	if(positionInSeconds < 0 || durationInSeconds < 0) {
		positionString = @"--:--";
		durationString = @"--:--";
	} else if(durationHours >= 10) {
		positionString = [NSString stringWithFormat:@"%02ld:%02ld:%02ld", positionHours, positionMinutes, positionSeconds];
		durationString = [NSString stringWithFormat:@"-%02ld:%02ld:%02ld", remainingHours, remainingMinutes, remainingSeconds];
	} else if(durationHours > 0) {
		positionString = [NSString stringWithFormat:@"%ld:%02ld:%02ld", positionHours, positionMinutes, positionSeconds];
		durationString = [NSString stringWithFormat:@"-%ld:%02ld:%02ld", remainingHours, remainingMinutes, remainingSeconds];
	} else if(durationMinutes >= 10) {
		positionString = [NSString stringWithFormat:@"%02ld:%02ld", positionMinutes, positionSeconds];
		durationString = [NSString stringWithFormat:@"-%02ld:%02ld", remainingMinutes, remainingSeconds];
	} else {
		positionString = [NSString stringWithFormat:@"%ld:%02ld", positionMinutes, positionSeconds];
		durationString = [NSString stringWithFormat:@"-%ld:%02ld", remainingMinutes, remainingSeconds];
	}
	
	// In case we're playing a stream
	if(durationInSeconds <= 0) {
		durationString = @"";
	}
	
	[_positionCell setStringValue:positionString];
	[_durationCell setStringValue:durationString];
}

- (NSShadow*)_trackingBarShadow {
	if(!_trackingBarShadow) {
		_trackingBarShadow = [[NSShadow alloc] init];
		
		[_trackingBarShadow setShadowOffset:
			NSMakeSize(0.0, -1.0)];
		
		[_trackingBarShadow setShadowBlurRadius:0.0];
		[_trackingBarShadow setShadowColor:
			[NSColor colorWithCalibratedWhite:0.0 alpha:1.0 / 3.0]];
	}
	
	return _trackingBarShadow;
}

@end
