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

#import "SCApplication.h"

#import "MusicSearchWindowController.h"
#import "CoverSutra.h"

#import "NSEvent+Additions.h"
#import "NSEvent+SpecialKeys.h"
#import "NSResponder+SpecialKeys.h"

@implementation SCApplication

- (void)sendEvent:(NSEvent*)theEvent {
	NSUInteger modifierFlags = theEvent.modifierFlags;

	if(theEvent.type == NSKeyDown && modifierFlags & NSCommandKeyMask) {
		id windowController = [[CoverSutra self] musicSearchWindowController];
		
		if([windowController isVisible]) {
			if([theEvent hasUpArrowKey]) {
				[windowController moveUp:theEvent];
				return;
			} else if([theEvent hasDownArrowKey]) {
				[windowController moveDown:theEvent];
				return;
			}
		}
	}

	if([theEvent isSpecialKeyEvent] && [self interpretSpecialKeyEvent:theEvent]) {
		return;
	}

	[super sendEvent:theEvent];
}

- (id)valueForUndefinedKey:(NSString*)key {
	return [(id)[self delegate] valueForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString*)key {
	[(id)[self delegate] setValue:value forKey:key];
}

- (void)orderFrontStandardAboutPanelWithOptions:(NSDictionary*)options {
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[super orderFrontStandardAboutPanelWithOptions:options];
}

- (NSInteger)runModalForWindow:(NSWindow*)aWindow {
	// Set the window's level to that of a status window if the don't have a dock item
	if(![[CoverSutra self] dockItemShown]) {
		[aWindow setLevel:NSStatusWindowLevel];
	}
	
	return [super runModalForWindow:aWindow];
}

@end
