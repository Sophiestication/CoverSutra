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

#import "PreferencesWindowController+Private.h"

#import "CoverSutra.h"

@implementation PreferencesWindowController(Private)

- (id)preferenceValueForKey:(NSString*)key {
	return [[[NSUserDefaultsController sharedUserDefaultsController] values]
		valueForKey:key];
}

- (void)setPreferenceValue:(id)value forKey:(NSString*)key {
	[[[NSUserDefaultsController sharedUserDefaultsController] values]
		setValue:value forKey:key];
}

- (NSView*)contentView {
	for(NSView* subview in [[[self window] contentView] subviews]) {
		if(![subview isHidden]) {
			return subview;
		}
	}
	
	return nil;
}

- (void)showView:(NSView*)view {
	if(_animationInProgress) {
		return;
	}
	
	// ...
	if([[CoverSutra self] dockItemShown]) {
		for(NSToolbarItem* toolbarItem in _toolbar.items) {
			if([[toolbarItem itemIdentifier] isEqualToString:[_toolbar selectedItemIdentifier]]) {
				[[self window] setTitle:[toolbarItem paletteLabel]];
			}
		}
	}

	NSView* contentView = [self contentView];

	if(contentView == view) {
		return;
	}
	
	NSWindow* window = [self window];
    
    // Determine the new window frame
	NSRect newFrame = [window frame];

    newFrame.size.height = [view frame].size.height + ([window frame].size.height - [(NSView*)[window contentView] frame].size.height);
    newFrame.size.width = [view frame].size.width;
    newFrame.origin.y += ([(NSView*)[window contentView] frame].size.height - [view frame].size.height);
    
	CGFloat scaleFactor = [window userSpaceScaleFactor];
//	newFrame.size.height *= scaleFactor;
	newFrame.size.width *= scaleFactor;
	
	[[window contentView] addSubview:view];
	[view setHidden:YES];
	
	if(!contentView) { // No animation
//		[[window contentView] addSubview:view];
		[view setHidden:NO];
		[window setFrame:newFrame display:YES animate:NO];
		
		return;
	}

/*
	// The quick and ugly method
	[contentView setHidden:YES];
	[window setFrame:newFrame display:YES animate:YES];
	[view setHidden:NO];
*/

	NSDictionary* windowFrameAnimation = [NSDictionary dictionaryWithObjectsAndKeys:
		window, NSViewAnimationTargetKey,
		[NSValue valueWithRect:newFrame], NSViewAnimationEndFrameKey,
		nil];
		
	NSDictionary* fadeOutAnimation = [NSDictionary dictionaryWithObjectsAndKeys:
		contentView, NSViewAnimationTargetKey,
		NSViewAnimationFadeOutEffect, NSViewAnimationEffectKey,
		nil];
	
	NSDictionary* fadeInAnimation = [NSDictionary dictionaryWithObjectsAndKeys:
		view, NSViewAnimationTargetKey,
		NSViewAnimationFadeInEffect, NSViewAnimationEffectKey,
		nil];
		
	NSViewAnimation* animation = [[NSViewAnimation alloc] initWithViewAnimations:
		[NSArray arrayWithObjects:windowFrameAnimation, fadeInAnimation, fadeOutAnimation, nil]];
		
	[animation setDelegate:self];
	
	unsigned modifierFlags = [[window currentEvent] modifierFlags];
	
	if(modifierFlags & NSShiftKeyMask) {
		[animation setDuration:1.5]; // Slow motion
	} else {
		[animation setDuration:0.3];
	}
	
	[animation setAnimationCurve:NSAnimationEaseInOut];
	[animation setAnimationBlockingMode:NSAnimationNonblocking];
	
	_animationInProgress = YES;
	
	[animation startAnimation];
}

- (void)animationDidStop:(NSAnimation*)animation {	
	_animationInProgress = NO;
}

- (void)animationDidEnd:(NSAnimation*)animation {	
	_animationInProgress = NO;
}

@end
