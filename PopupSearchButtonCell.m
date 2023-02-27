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

#import "PopupSearchButtonCell.h"
#import "NSImage+Additions.h"

@implementation PopupSearchButtonCell

- (id)initImageCell:(NSImage*)image {
	if(![super initImageCell:image]) {
		return nil;
	}
	
	_indicatorImage = [NSImage imageNamed:@"popupSearchIndicator"];
	
	[self setBordered:NO];
	
	return self;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	[super drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView*)controlView {
	NSSize indicatorSize = [_indicatorImage size];
	NSPoint indicatorOrigin = NSMakePoint(
		NSMaxX(frame) - indicatorSize.width, NSMaxY(frame) - 3.0);
	// [_indicatorImage dissolveToPoint:indicatorOrigin
	//	fraction:1.0];
	
	NSRect indicatorRect = NSMakeRect(indicatorOrigin.x, indicatorOrigin.y - indicatorSize.height, indicatorSize.width, indicatorSize.height);
	[_indicatorImage drawFlippedInRect:indicatorRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	
	frame.origin.x -= (indicatorSize.width + 2.0);
	[super drawImage:image withFrame:frame inView:controlView];
}

@end
