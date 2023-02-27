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

#import "PreferencesWindowController+Toolbar.h"

@implementation PreferencesWindowController(Toolbar)

- (NSArray*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
	return [NSArray arrayWithObjects:
		@"generalPreferences",
		@"albumCoverPreferences",
		@"shortcutPreferences",
		@"lastFMPreferences",
		nil];
}

- (NSArray*)toolbarDefaultItemIdentifiers:(NSToolbar*)aToolbar {
	return [NSArray arrayWithObjects:
		NSToolbarFlexibleSpaceItemIdentifier,
		@"generalPreferences",
		@"albumCoverPreferences",
		@"shortcutPreferences",
		@"lastFMPreferences",
		NSToolbarFlexibleSpaceItemIdentifier,
		nil];
}

- (NSArray*)toolbarSelectableItemIdentifiers:(NSToolbar*)aToolbar {
	return _animationInProgress ? nil : [self toolbarAllowedItemIdentifiers:aToolbar];
}

- (NSToolbarItem*)toolbar:(NSToolbar*)aToolbar itemForItemIdentifier:(NSString*)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag {
	NSString* s = [NSString stringWithFormat:@"toolbar:%@ItemForItemIdentifier:", itemIdentifier];
	SEL selector = NSSelectorFromString(s);
	
	if([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
		return [self performSelector:selector
			withObject:aToolbar
			withObject:itemIdentifier];
#pragma clang diagnostic pop
	}
	
	return nil;
}

- (NSToolbarItem*)toolbar:(NSToolbar*)aToolbar generalPreferencesItemForItemIdentifier:(NSString*)itemIdentifier {
	NSToolbarItem* toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	[toolbarItem setLabel:NSLocalizedString(@"GENERAL_PREFERENCES_ITEM", @"")];
    [toolbarItem setPaletteLabel:NSLocalizedString(@"GENERAL_PREFERENCES_ITEM", @"")];
	
	[toolbarItem setImage:[NSImage imageNamed:@"generalPreferences"]];
	
	[toolbarItem setTarget:self];
	[toolbarItem setAction:@selector(showGeneralPreferences:)];
	
	return toolbarItem;
}

- (NSToolbarItem*)toolbar:(NSToolbar*)aToolbar albumCoverPreferencesItemForItemIdentifier:(NSString*)itemIdentifier {
	NSToolbarItem* toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	[toolbarItem setLabel:NSLocalizedString(@"ALBUMCOVER_PREFERENCES_ITEM", @"")];
    [toolbarItem setPaletteLabel:NSLocalizedString(@"ALBUMCOVER_PREFERENCES_ITEM", @"")];
	
	[toolbarItem setImage:[NSImage imageNamed:@"albumCoverPreferences"]];
	
	[toolbarItem setTarget:self];
	[toolbarItem setAction:@selector(showAlbumCoverPreferences:)];
	
	return toolbarItem;
}

- (NSToolbarItem*)toolbar:(NSToolbar*)aToolbar shortcutPreferencesItemForItemIdentifier:(NSString*)itemIdentifier {
	NSToolbarItem* toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	[toolbarItem setLabel:NSLocalizedString(@"SHORTCUTS_PREFERENCES_ITEM", @"")];
    [toolbarItem setPaletteLabel:NSLocalizedString(@"SHORTCUTS_PREFERENCES_ITEM", @"")];
	
	[toolbarItem setImage:[NSImage imageNamed:@"shortcutPreferences"]];
	
	[toolbarItem setTarget:self];
	[toolbarItem setAction:@selector(showShortcutPreferences:)];
	
	return toolbarItem;
}

- (NSToolbarItem*)toolbar:(NSToolbar*)aToolbar lastFMPreferencesItemForItemIdentifier:(NSString*)itemIdentifier {
	NSToolbarItem* toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	[toolbarItem setLabel:NSLocalizedString(@"LASTFM_PREFERENCES_ITEM", @"")];
    [toolbarItem setPaletteLabel:NSLocalizedString(@"LASTFM_PREFERENCES_ITEM", @"")];
	
	[toolbarItem setImage:[NSImage imageNamed:@"lastfmPreferences"]];
	
	[toolbarItem setTarget:self];
	[toolbarItem setAction:@selector(showLastFMPreferences:)];
	
	return toolbarItem;
}

@end
