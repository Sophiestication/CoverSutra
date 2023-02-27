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

#import "SkinSelectionView.h"

#import "NSGraphicsContext+Additions.h"

@implementation SkinSelectionView

- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];

    NSRect bounds = [self bounds];
		
	// Fill the content area with the background pattern
//	[[NSGraphicsContext currentContext] setPatternPhase:
//		NSMakePoint(NSMinX(bounds), NSMaxY(bounds))];
	
	NSColor* backgroundColor = [NSColor colorWithPatternImage:[NSImage imageNamed:@"skinSelectionViewBackground"]];
	[backgroundColor set];
	
	NSRectFill(rect);
	
	// Draw a soft gradient over the background pattern
	NSGradient* overlayGradient = [[NSGradient alloc]
		initWithStartingColor:[NSColor clearColor]
		endingColor:[NSColor blackColor]];
	
	[[NSGraphicsContext currentContext] setAlphaValue:1.0 / 3.0];
	[[NSGraphicsContext currentContext] setBlendMode:kCGBlendModeSoftLight];
	[overlayGradient drawInRect:bounds angle:-90.0];
	
	// Now draw a inner shadow on the top of the window
	NSGradient* innerShadowGradient = [[NSGradient alloc]
		initWithStartingColor:[NSColor blackColor]
		endingColor:[NSColor clearColor]];
	
	CGFloat innerShadowHeight = 10.0;
//	NSRect innerShadowRect = NSMakeRect(
//		NSMinX(bounds), NSMaxY(bounds) - innerShadowHeight,
//		NSWidth(bounds), innerShadowHeight);
	
	NSRect innerShadowRect = NSMakeRect(
		NSMinX(bounds), NSMinY(bounds),
		NSWidth(bounds), innerShadowHeight);
	
	[[NSGraphicsContext currentContext] setAlphaValue:1.0 / 3.0];
	[[NSGraphicsContext currentContext] setBlendMode:kCGBlendModeMultiply];
	[innerShadowGradient drawInRect:innerShadowRect angle:90.0];
}

@end
