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

#import <Cocoa/Cocoa.h>

@interface PlayerPositionSliderCell : NSActionCell {
@private
	double _progress;
	
	BOOL _tracking;
	BOOL _needsToStopTracking;
	
	NSShadow* _trackingBarShadow;
	
	NSNumber* _positionInSeconds;
	NSNumber* _durationInSeconds;
	
	NSTextFieldCell* _positionCell;
	NSTextFieldCell* _durationCell;
}

- (double)progress;

- (NSNumber*)positionInSeconds;
- (void)setPositionInSeconds:(NSNumber*)positionInSeconds;

- (NSNumber*)durationInSeconds;
- (void)setDurationInSeconds:(NSNumber*)durationInSeconds;

- (void)_setProgressFromPoint:(NSPoint)point inView:(NSView*)controlView;

- (NSRect)trackingBarRectForFrame:(NSRect)cellFrame inView:(NSView*)controlView;
- (NSRect)knobRectForFrame:(NSRect)cellFrame inView:(NSView*)controlView;

- (NSRect)positionCellRectForFrame:(NSRect)cellFrame inView:(NSView*)controlView;
- (NSRect)durationCellRectForFrame:(NSRect)cellFrame inView:(NSView*)controlView;

- (void)_updatePlayerPositionAndDurationCells;
- (NSShadow*)_trackingBarShadow;

@end
