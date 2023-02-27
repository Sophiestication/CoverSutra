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

#import "MusicSearchGroupView.h"

#import "MusicSearchMenuView.h"
#import "MusicSearchAlbumCell.h"

#import "MusicLibraryAlbum.h"

#import "NSView+Additions.h"

#import "CoverSutra.h"

#import <QuartzCore/QuartzCore.h>

@implementation MusicSearchGroupView

+ (void)initialize {
	[self setCellClass:[MusicSearchAlbumCell class]];
}

- (id)initWithFrame:(NSRect)frame {
	if(![super initWithFrame:frame]) {
		return nil;
	}
	
	[self bind:@"skin"
		toObject:[CoverSutra self]
		withKeyPath:@"skinController.selection.self"
		options:nil];
	
	return self;
}

- (BOOL)isOpaque {
	return NO;
}

- (BOOL)isFlipped {
	return YES;
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

- (id)representedObject {
	return [[self cell] musicLibraryItem];
}

- (void)setRepresentedObject:(id)representedObject {
	[[self cell] setMusicLibraryItem:representedObject];
}

- (Skin*)skin {
	return [[self cell] skin];
}

- (void)setSkin:(Skin*)skin {
	[[self cell] setSkin:skin];
	[self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent*)theEvent {
	NSPoint currentMouseLocation = theEvent.locationInWindow;
	currentMouseLocation = [self.superview.superview
		convertPoint:currentMouseLocation
		fromView:nil];
	NSView* clickedView = [self.superview hitTest:currentMouseLocation];
	
	if(clickedView != self) {
		[clickedView mouseDown:theEvent];
		return;
	}
	
	NSRect bounds = [self convertRect:self.bounds toView:nil];
	NSPoint newLocation = NSMakePoint(
		NSMaxX(bounds) - 52.0,
		NSMaxY(bounds) - 52.0);
	
	NSEvent* newEvent = [NSEvent mouseEventWithType:NSLeftMouseDown
		location:newLocation
		modifierFlags:theEvent.modifierFlags
		timestamp:theEvent.timestamp
		windowNumber:theEvent.windowNumber
		context:theEvent.context
		eventNumber:theEvent.eventNumber
		clickCount:theEvent.clickCount
		pressure:theEvent.pressure];
		
	NSMenu* menu = [self menuForEvent:newEvent];
	[NSMenu popUpContextMenu:menu
		withEvent:newEvent
		forView:self];
}

- (void)rightMouseDown:(NSEvent*)theEvent {
	NSRect bounds = [self convertRect:self.bounds toView:nil];
	NSPoint newLocation = NSMakePoint(
		NSMaxX(bounds) - 52.0,
		NSMaxY(bounds) - 52.0);
	
	NSEvent* newEvent = [NSEvent mouseEventWithType:NSRightMouseDown
		location:newLocation
		modifierFlags:theEvent.modifierFlags
		timestamp:theEvent.timestamp
		windowNumber:theEvent.windowNumber
		context:theEvent.context
		eventNumber:theEvent.eventNumber
		clickCount:theEvent.clickCount
		pressure:theEvent.pressure];
	
	[super rightMouseDown:newEvent];
}

- (NSMenu*)menuForEvent:(NSEvent*)theEvent {
	id representedObject = self.representedObject;
	
	if([representedObject isKindOfClass:[MusicLibraryAlbum class]]) {
		MusicSearchMenuView* menuView = (MusicSearchMenuView*)[self enclosingViewOfClass:
			[MusicSearchMenuView class]];
		
		[menuView setSelection:nil];
		[menuView setSelectedAlbum:representedObject];
		
		return [super menuForEvent:theEvent];
	}

	return nil;
}

@end
