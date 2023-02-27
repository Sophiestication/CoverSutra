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

#import "SCHUDButtonCell.h"

@implementation SCHUDButtonCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSImage* buttonImage = [NSImage imageNamed:@"HUDRadioButton"];
	
	NSSize imageSize = [buttonImage size];
	NSSize tileSize = NSMakeSize(
		imageSize.width / 3.0,
		imageSize.height / 2.0);
	
	NSRect firstTileRect = NSMakeRect(
		0.0, 0.0,
		tileSize.width, tileSize.height);
		
	NSRect tileRect = firstTileRect;
	
	if([self state] == NSOffState) {
		tileRect = NSOffsetRect(tileRect, 0.0, tileSize.height);
	}
	
	if([self isEnabled]) {
		tileRect = NSOffsetRect(tileRect, tileSize.width, 0.0);
	}
	
	if([self isHighlighted]) {
		tileRect = NSOffsetRect(tileRect, tileSize.width, 0.0);
	}
	
	NSRect rect = NSMakeRect(
		floorf(NSMidX(cellFrame) - tileSize.width * 0.5),
		floorf(NSMidY(cellFrame) - tileSize.height * 0.5),
		tileSize.width,
		tileSize.height);
	
	[buttonImage drawInRect:rect
		fromRect:tileRect
		operation:NSCompositeSourceOver
		fraction:1.0
		respectFlipped:YES
		hints:nil];
}

@end
