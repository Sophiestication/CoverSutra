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

#import "StatusItemCell.h"

#import "StatusItemControl.h"

#import "MusicSearchWindowController.h"
#import "PlayerNotificationController.h"

#import "CoverSutra.h"
#import "CoverSutra+Menu.h"

@implementation StatusItemCell

@synthesize
	dimmed = _dimmed,
	alphaValue = _alphaValue,
	scaleFactor = _scaleFactor;

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_alphaValue = 1.0;
	_scaleFactor = 1.0;
	_imageWidth = 16.0;
	_imageMargin = 5.0;
	
	_musicSearchWindowShown = NO;
	
	[self setBordered:NO];
	[self setBezelStyle:NSTexturedRoundedBezelStyle];
	[self setButtonType:NSToggleButton];
	[self setImageScaling:NSImageScaleProportionallyDown];
	[self setImagePosition:NSImageOnly];
	
	return self;
}

- (NSSize)cellSize {
	NSSize cellSize = NSMakeSize(
		_imageWidth + _imageMargin * 2.0,
		[[NSStatusBar systemStatusBar] thickness]);
	return cellSize;
}

- (BOOL)isOpaque {
	return NO;
}

- (BOOL)trackMouse:(NSEvent*)theEvent inRect:(NSRect)cellFrame ofView:(NSView*)controlView untilMouseUp:(BOOL)untilMouseUp {
	NSEventType eventType = [theEvent type];
	unsigned int modifiers = [theEvent modifierFlags];
	
	if((modifiers & NSControlKeyMask) || eventType == NSRightMouseDown) {
		StatusItemControl* statusItemControl = (StatusItemControl*)controlView;
		
		[[[CoverSutra self] musicSearchWindowController] orderOut:theEvent];
		[[[CoverSutra self] playerNotificationController] orderOut:theEvent];
		
		[[statusItemControl statusItem] popUpStatusItemMenu:
			[controlView menu]];
		
		return YES;
	}
	
	if(!(modifiers & NSAlternateKeyMask) && eventType != NSOtherMouseDown) {
		[[[CoverSutra self] musicSearchWindowController] toggleWindowShown:theEvent];
		return YES;
	}
	
	if(eventType == NSOtherMouseDown) {
		[[CoverSutra self] toggleApplicationWindowShown:controlView];
		return YES;
	}
	
	BOOL trackedMouse = [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
	
	if(trackedMouse && (modifiers & NSAlternateKeyMask)) {
		[[CoverSutra self] toggleApplicationWindowShown:controlView];
	}
	
	return trackedMouse;
}

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView*)controlView {
	[controlView display];
	return YES;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView*)controlView {
	[super continueTracking:lastPoint at:currentPoint inView:controlView];
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView*)controlView mouseIsUp:(BOOL)flag {
	[controlView display];
}

- (NSMenu*)menuForEvent:(NSEvent*)theEvent inRect:(NSRect)cellFrame ofView:(NSView*)controlView {
	return nil;
}

- (NSBackgroundStyle)backgroundStyle {
	return NSBackgroundStyleLowered;
}

- (NSBackgroundStyle)interiorBackgroundStyle {
	BOOL highlighted = [self isHighlighted] || _musicSearchWindowShown;
	return highlighted ? NSBackgroundStyleDark : NSBackgroundStyleRaised;
}

- (BOOL)isHighlighted {
	return _musicSearchWindowShown || [super isHighlighted];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	[[(StatusItemControl*)controlView statusItem]
		drawStatusBarBackgroundInRect:cellFrame
		withHighlight:[self isHighlighted]];
		
	CGFloat imageWidth = _imageWidth * self.scaleFactor;
	
	NSRect imageRect = NSMakeRect(
		floorf(NSMidX(cellFrame) - imageWidth * 0.5),
		floorf(NSMidY(cellFrame) - imageWidth * 0.5),
		imageWidth,
		imageWidth);
	
	[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	
	[super drawInteriorWithFrame:imageRect inView:controlView];
}

@end
