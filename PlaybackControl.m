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

#import "PlaybackControl.h"

#import "PlaybackController.h"
#import "PlayerController.h"
#import "CoverSutra.h"

@implementation PlaybackControl

+ (Class)cellClass {
	return [PlaybackControlCell class];
}

@end

// PlaybackControlCell implementation

@implementation PlaybackControlCell

- (id)init {
	if((self = [super init])) {
		[self setSegmentCount:3];
	
		[self setTarget:self];
    	[self setAction:@selector(segmentPressed:)];
		[self setDelayedTarget:self];
    	[self setDelayedAction:@selector(segmentPressedWithDelay:)];
	}

	return self;
}

- (void)segmentPressed:(id)sender {
	PlaybackController* playbackController = [[CoverSutra self] playbackController];
	
	// Check if we need to resume to normal playback
	if(playbackController.fastForwarding || playbackController.rewinding) {
		return;
	}

	// Perform the appropiate action
	NSInteger selectedSegment = [sender selectedSegment];
	
	if(selectedSegment == 0) {
		[playbackController backTrack];
	}
	
	if(selectedSegment == 1) {
		[playbackController playpause];
	}
	
	if(selectedSegment == 2) {
		[playbackController nextTrack];
	}
}

- (void)segmentPressedWithDelay:(id)sender {
	NSInteger selectedSegment = [sender selectedSegment];

	if(selectedSegment == 0) {
		[[[CoverSutra self] playbackController] rewind];
	}
	
	if(selectedSegment == 2) {
		[[[CoverSutra self] playbackController] fastForward];
	}
}

- (BOOL)trackMouse:(NSEvent*)theEvent inRect:(NSRect)cellFrame ofView:(NSView*)controlView untilMouseUp:(BOOL)flag {
	BOOL result = [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:flag];

	// Resume to normal playback if needed
	PlaybackController* playbackController = [[CoverSutra self] playbackController];
	
	if(playbackController.fastForwarding || playbackController.rewinding) {
		[playbackController resume];
	}
	
	return result;
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView*)controlView {
	BOOL result = [super startTrackingAt:startPoint inView:controlView];
	return result;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView*)controlView {
	return [super continueTracking:lastPoint at:currentPoint inView:controlView];
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView*)controlView mouseIsUp:(BOOL)flag {
	[super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}

@end
