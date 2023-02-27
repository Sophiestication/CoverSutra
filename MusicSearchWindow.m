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

#import "MusicSearchWindow.h"

@implementation MusicSearchWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
	id window = [super initWithContentRect:contentRect
		styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask
		backing:bufferingType
		defer:flag];
	
	return window;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen*)screen {
	id window = [super initWithContentRect:contentRect
		styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask
		backing:bufferingType
		defer:flag
		screen:screen];

	return window;
}

- (BOOL)isExcludedFromWindowsMenu {
	return YES;
}

- (BOOL)canBecomeKeyWindow {
	return YES;
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)canMiniaturize {
	return NO; 
}

- (BOOL)canResize {
	return NO;
}

- (BOOL)canClose {
	return NO;
}

- (BOOL)canMove {
	return NO;
}

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen*)screen {
	if(!screen) {
		return frameRect;
	}
	
	NSRect screenFrame = screen.visibleFrame;
	NSRect newFrameRect = frameRect;
	
	CGFloat maxHeight = MIN(NSHeight(screenFrame), [self maxSize].height);
	
	if(NSHeight(frameRect) > maxHeight) {
		newFrameRect.origin.y = NSMinY(screenFrame) + (NSHeight(screenFrame) - maxHeight);
		newFrameRect.size.height = maxHeight;
	}
	
	if(NSMaxX(frameRect) > NSMaxX(screenFrame)) {
		newFrameRect = NSOffsetRect(newFrameRect, NSMaxX(screenFrame) - NSMaxX(frameRect), 0.0);
	}
	
	return [super constrainFrameRect:newFrameRect toScreen:screen];
}

@end
