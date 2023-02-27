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

#import "SliderCell.h"

#import "NSImage+Additions.h"
#import "NSView+Additions.h"

@implementation SliderCell

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	return self;
}


// NSCell interface

- (NSFocusRingType)focusRingType {
	if(self.controlView.HUDControl) {
		return NSFocusRingTypeNone;
	}
	
	return [super focusRingType];
}

// NSSliderCell interface

- (void)drawBarInside:(NSRect)cellFrame flipped:(BOOL)flipped {
	if(self.controlView.HUDControl) {
		[self drawHUDBarInside:cellFrame flipped:flipped];
		return;
	}
	
	[super drawBarInside:cellFrame flipped:flipped];
}

- (void)drawKnob:(NSRect)rect {
	if(self.controlView.HUDControl) {
		[self drawHUDKnob:rect];
		return;
	}
	
	[super drawKnob:rect];
}

// Slider HUD interface

- (void)initHUDImagesIfNeeded {
	if(!_trackImage) {
		_trackImage = [NSImage imageNamed:@"HUDSliderTrack"];
	}
	
	if(!_knobImage) {
		_knobImage = [NSImage imageNamed:@"HUDSliderKnob"];
	}
}

- (void)drawHUDBarInside:(NSRect)cellFrame flipped:(BOOL)flipped {
	// Initialize the track image if needed
	[self initHUDImagesIfNeeded];

	// Flip image if needed
	[_trackImage setFlipped:flipped];
	
	// Draw our track image
	NSSize trackImageSize = _trackImage.size;
	
	CGFloat trackHeight = trackImageSize.height;
	
	CGFloat leftCapWidth = 3.0;
	CGFloat rightCapWidth = 3.0;
	
	NSRect barFrame = NSMakeRect(
		NSMinX(cellFrame), round(NSMidY(cellFrame) - trackImageSize.height * 0.5),
		NSWidth(cellFrame), trackHeight);
	barFrame = NSInsetRect(barFrame, 5.0, 0.0);
	
	CGFloat opacity = [self isEnabled] ? 1.0 : 0.5;
	
	[_trackImage drawInRect:NSMakeRect(NSMinX(barFrame), NSMinY(barFrame), leftCapWidth, NSHeight(barFrame))
		fromRect:NSMakeRect(0.0, 0.0, leftCapWidth, trackHeight)
		operation:NSCompositeSourceOver
		fraction:opacity];
	[_trackImage drawInRect:NSMakeRect(NSMinX(barFrame) + leftCapWidth, NSMinY(barFrame), NSWidth(barFrame) - leftCapWidth - rightCapWidth, NSHeight(barFrame))
		fromRect:NSMakeRect(leftCapWidth, 0.0, 4.0 /* TODO */, trackHeight)
		operation:NSCompositeSourceOver
		fraction:opacity];
	[_trackImage drawInRect:NSMakeRect(NSMaxX(barFrame) - rightCapWidth, NSMinY(barFrame), rightCapWidth, NSHeight(barFrame))
		fromRect:NSMakeRect(trackImageSize.width - rightCapWidth, 0.0, rightCapWidth, trackHeight)
		operation:NSCompositeSourceOver
		fraction:opacity];
}

- (void)drawHUDKnob:(NSRect)rect {
	// Initialize the track image if needed
	[self initHUDImagesIfNeeded];
	
	// Flip image
	[_knobImage setFlipped:YES];
	
	// Draw slider knob
	NSSize knobImageSize = _knobImage.size;
	CGFloat knobHeight = knobImageSize.height * 0.5;
	
	CGFloat opacity = [self isEnabled] ? 1.0 : 0.5;
	
	NSRect knobRect = NSMakeRect(
		round(NSMidX(rect) - knobImageSize.width * 0.5),
		ceilf(NSMidY(rect) - knobHeight * 0.5) + 1.0,
		knobImageSize.width,
		knobHeight);
	
	[_knobImage drawInRect:knobRect
		fromRect:NSMakeRect(0.0, [self isHighlighted] ? knobHeight : 0.0, knobImageSize.width, knobHeight)
		operation:NSCompositeSourceOver
		fraction:opacity];
}

// AppKit Private interface

- (BOOL)_usesCustomTrackImage {
	if(self.controlView.HUDControl) {
		return YES;
	}
	
	return NO;
}

@end
