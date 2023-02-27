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

#import "PlayerPositionSlider.h"
#import "PlayerPositionSliderCell.h"

@implementation PlayerPositionSlider

+ (void)initialize {
	[self setCellClass:[PlayerPositionSliderCell class]];
}


- (id)delegate {
	return _delegate;
}

- (void)setDelegate:(id)delegate {
	_delegate = delegate;
}

- (NSNumber*)positionInSeconds {
	return [[self cell] positionInSeconds];
}

- (void)setPositionInSeconds:(NSNumber*)positionInSeconds {
	[[self cell] setPositionInSeconds:positionInSeconds];
	[self setNeedsDisplay:YES];
}

- (NSNumber*)durationInSeconds {
	return [[self cell] durationInSeconds];
}

- (void)setDurationInSeconds:(NSNumber*)durationInSeconds {
	[[self cell] setDurationInSeconds:durationInSeconds];
	[self setNeedsDisplay:YES];
}

- (double)progress {
	return [[self cell] progress];
}

- (void)setProgress:(double)progress {
	[[self cell] setProgress:progress];
	[self setNeedsDisplay:YES];
}

- (BOOL)acceptsFirstMouse:(NSEvent*)mouseDownEvent {
	return YES;
}

@end
