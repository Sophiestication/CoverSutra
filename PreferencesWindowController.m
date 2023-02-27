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

#import "PreferencesWindowController.h"

#import "PreferencesWindowController+General.h"
#import "PreferencesWindowController+Toolbar.h"
#import "PreferencesWindowController+Shortcuts.h"
#import "PreferencesWindowController+Skin.h"
#import "PreferencesWindowController+LastDotFM.h"
#import "PreferencesWindowController+Private.h"

#import "CoverSutra.h"
#import "CoverSutra+LoginItems.h"
#import "CoverSutra+Private.h"

#import "NSString+Additions.h"

@implementation PreferencesWindowController

+ (PreferencesWindowController*)preferencesWindowController {
	return [[self alloc] initWithWindowNibName:@"PreferencesWindow"];
}

- (void)windowWillLoad {
	_toolbar = [[NSToolbar alloc] initWithIdentifier:@"preferencesWindowToolbar"];
	[_toolbar setDelegate:self];
	
	[super windowWillLoad];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	

}

- (void)cancel:(id)sender {
	[[self window] performClose:sender];
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	_animationInProgress = NO;
	_shortcutsInitialized = NO;
	
	for(NSCell *currentCell in [albumCoverSizeMatrix cells]) {
		NSString *previousTitle = [currentCell title];
		[currentCell setTitle:NSLocalizedString(previousTitle, nil)];
	}
	
	NSWindow* window = [self window];

	[window setToolbar:_toolbar];

	// Show General preferences
	[self showGeneralPreferences:nil];
	
	// Don't we have a dock item?
	if(![[CoverSutra self] dockItemShown]) {
		// Add the apps name to the window title if necessary
		[window setTitle:
			[NSString stringWithFormat:@"%@ %@", @"CoverSutra", [window title]]];
		
		// Let the preferences float above all windows if we don't have a dock item
		[window setLevel:NSModalPanelWindowLevel];
	}
	
	[window center];
}

- (void)windowWillClose:(NSNotification*)notification {
	[[CoverSutra self] _resetPreferencesWindowController];
}

- (IBAction)showWindow:(id)sender {
	[super showWindow:sender];
	[[self window] makeKeyAndOrderFront:sender];
}

- (IBAction)showGeneralPreferences:(id)sender {
	if([self contentView] == generalPreferencesView || _animationInProgress) {
		return;
	}
	
	[self _initGeneralPreferences];
	
	if(![[_toolbar selectedItemIdentifier] isEqualToString:@"generalPreferences"]) {
		[_toolbar setSelectedItemIdentifier:@"generalPreferences"];
	}

	[self showView:generalPreferencesView];
}

- (IBAction)showAlbumCoverPreferences:(id)sender {
	if([self contentView] == albumCoverPreferencesView || _animationInProgress) {
		return;
	}
	
	if(![[_toolbar selectedItemIdentifier] isEqualToString:@"albumCoverPreferences"]) {
		[_toolbar setSelectedItemIdentifier:@"albumCoverPreferences"];
	}
	
	[self _initSkinPreferences];
	
	[self showView:albumCoverPreferencesView];
}

- (IBAction)showShortcutPreferences:(id)sender {
	if([self contentView] == shortcutPreferencesView || _animationInProgress) {
		return;
	}
	
	if(![[_toolbar selectedItemIdentifier] isEqualToString:@"shortcutPreferences"]) {
		[_toolbar setSelectedItemIdentifier:@"shortcutPreferences"];
	}
	
	[self _initShortcutPreferences];

	[self showView:shortcutPreferencesView];
}

- (IBAction)showLastFMPreferences:(id)sender {
	if([self contentView] == lastFMPreferencesView || _animationInProgress) {
		return;
	}
	
	if(![[_toolbar selectedItemIdentifier] isEqualToString:@"lastFMPreferences"]) {
		[_toolbar setSelectedItemIdentifier:@"lastFMPreferences"];
	}
	
	[self _initLastDotFM];
	
	[self showView:lastFMPreferencesView];
}

- (IBAction)showAdvancedPreferences:(id)sender {
	if(!self.visible) {
		[self showWindow:sender];
	}
	
	if([self contentView] == advancedPreferencesView || _animationInProgress) {
		return;
	}

	if(![[_toolbar selectedItemIdentifier] isEqualToString:@"advancedPreferences"]) {
		[_toolbar setSelectedItemIdentifier:@"advancedPreferences"];
	}

	[self showView:advancedPreferencesView];
}

/*
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
	if(context) {
		[self performSelector:(SEL)context];
	}
}
*/

@end
