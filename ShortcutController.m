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

#import "ShortcutController.h"
#import "ShortcutController+Private.h"

#import "Shortcut.h"
#import "ShortcutEvent.h"
#import "KeyCombination.h"

#import <Carbon/Carbon.h>

@implementation ShortcutController

static id _sharedShortcutController = nil;

+ (ShortcutController*)sharedShortcutController {
	if(!_sharedShortcutController) {
		_sharedShortcutController = [[self alloc] init];
		
		// TODO Could be in a separate method
		NSEnumerator* defaultShortcutIdentifiers = [[self defaultShortcutIdentifiers] objectEnumerator];
		id shortcutIdentifier = nil;
		
		while((shortcutIdentifier = [defaultShortcutIdentifiers nextObject])) {
			[_sharedShortcutController addShortcutWithIdentifier:shortcutIdentifier keyCombination:nil];
		}
		
		[_sharedShortcutController _readFromUserDefaults];
	}
	
	return _sharedShortcutController;
}

+ (void)releaseSharedShortcutController {
	if(_sharedShortcutController) {
		[_sharedShortcutController _writeToUserDefaults];
	}
	
	_sharedShortcutController = nil;
}

+ (NSArray*)defaultShortcutIdentifiers {
	NSMutableArray* defaultShortcutIdentifiers = [NSMutableArray array];
	
	[defaultShortcutIdentifiers addObject:@"showApplicationWindow"];
	
	[defaultShortcutIdentifiers addObject:@"playPauseSong"];
	[defaultShortcutIdentifiers addObject:@"nextSong"];
	[defaultShortcutIdentifiers addObject:@"previousSong"];
	[defaultShortcutIdentifiers addObject:@"showiTunes"];
	[defaultShortcutIdentifiers addObject:@"showCurrentSong"];
//	[defaultShortcutIdentifiers addObject:@"showLyricsWindow"];
	[defaultShortcutIdentifiers addObject:@"toggleSongRepeat"];
	[defaultShortcutIdentifiers addObject:@"toggleShuffle"];
	[defaultShortcutIdentifiers addObject:@"muteSoundVolume"];
	[defaultShortcutIdentifiers addObject:@"increaseSoundVolume"];
	[defaultShortcutIdentifiers addObject:@"decreaseSoundVolume"];
	
	[defaultShortcutIdentifiers addObject:@"showMusicSearch"];
	[defaultShortcutIdentifiers addObject:@"searchForAll"];
	[defaultShortcutIdentifiers addObject:@"searchForArtists"];
	[defaultShortcutIdentifiers addObject:@"searchForAlbums"];
	[defaultShortcutIdentifiers addObject:@"searchForSongs"];
//	[defaultShortcutIdentifiers addObject:@"searchByUserRating"];
	[defaultShortcutIdentifiers addObject:@"searchForPlaylists"];
	
//	[defaultShortcutIdentifiers addObject:@"nextAlbum"];
//	[defaultShortcutIdentifiers addObject:@"previousAlbum"];

	[defaultShortcutIdentifiers addObject:@"unrateSong"];
	[defaultShortcutIdentifiers addObject:@"rateSongWithOneStar"];
	[defaultShortcutIdentifiers addObject:@"rateSongWithTwoStars"];
	[defaultShortcutIdentifiers addObject:@"rateSongWithThreeStars"];
	[defaultShortcutIdentifiers addObject:@"rateSongWithFourStars"];
	[defaultShortcutIdentifiers addObject:@"rateSongWithFiveStars"];
	
	[defaultShortcutIdentifiers addObject:@"increaseUserRating"];
	[defaultShortcutIdentifiers addObject:@"decreaseUserRating"];

	return defaultShortcutIdentifiers;
}

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_shortcuts = [[NSMutableArray alloc] init];
	_enabledShortcuts = [[NSMutableDictionary alloc] init];
	_currentShortcutEventIdentifier = 0;
	_shortcutEventIdentifier = [[NSMutableDictionary alloc] init];
		
	_shortcutsEnabled = [[[NSUserDefaultsController sharedUserDefaultsController]
		valueForKeyPath:@"values.globalShortcutsEnabled"] boolValue];
		
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	
}

- (void)addShortcut:(Shortcut*)newShortcut {
	if(!newShortcut) {
		return;
	}
	
	if([self shortcutForIdentifier:[newShortcut identifier]]) {
		return;
	}
	
	[_shortcuts addObject:newShortcut];
	[_shortcutEventIdentifier
		setObject:newShortcut
		forKey:[NSNumber numberWithInteger:++_currentShortcutEventIdentifier]];
	[self _updateShortcut:newShortcut];
}

- (void)removeShortcut:(Shortcut*)shortcut {
	if(!shortcut) {
		return;
	}
	
	if([self shortcutForIdentifier:[shortcut identifier]]) {
		return;
	}
	
	NSValue* carbonHotKey = [self _carbonHotKeyForShortcut:shortcut];
	
	if(carbonHotKey) {
		OSStatus result = UnregisterEventHotKey((EventHotKeyRef)[carbonHotKey pointerValue]);
	
		if(result != noErr) { // TODO
		}

		[_enabledShortcuts removeObjectForKey:carbonHotKey];
	}
	
	[_shortcuts removeObject:shortcut];
	[_shortcutEventIdentifier removeObjectsForKeys:
		[_shortcutEventIdentifier allKeysForObject:shortcut]];
}

- (void)addShortcutWithIdentifier:(id)shortcutIdentifier keyCombination:(KeyCombination*)keyCombination {
	Shortcut* shortcut = [Shortcut shortcutWithIdentifier:shortcutIdentifier keyCombination:keyCombination];
	[self addShortcut:shortcut];
}

- (void)removeShortcutWithIdentifier:(id)shortcutIdentifier {
	Shortcut* shortcut = [self shortcutForIdentifier:shortcutIdentifier];
	
	if(shortcut) {
		[self removeShortcut:shortcut];
	}
}

- (NSArray*)allShortcuts {
	return _shortcuts;
}

- (Shortcut*)shortcutForIdentifier:(id)identifier {
	if(!identifier) {
		return nil;
	}
	
	NSArray* shortcuts = [self allShortcuts];
	
	unsigned numberOfShortcuts = [shortcuts count];
	unsigned shortcutIndex = 0;
	
	for(; shortcutIndex < numberOfShortcuts; ++shortcutIndex) {
		Shortcut* shortcut = [shortcuts objectAtIndex:shortcutIndex];
		
		if([identifier isEqual:[shortcut identifier]]) {
			return shortcut;
		}
	}
	
	return nil;
}

- (Shortcut*)shortcutForKeyCombination:(KeyCombination*)keyCombination {
	if(!keyCombination || [keyCombination isEmpty]) {
		return nil;
	}
	
	NSArray* shortcuts = [self allShortcuts];
	
	unsigned numberOfShortcuts = [shortcuts count];
	unsigned shortcutIndex = 0;
	
	for(; shortcutIndex < numberOfShortcuts; ++shortcutIndex) {
		Shortcut* shortcut = [shortcuts objectAtIndex:shortcutIndex];
		
		if(EqualKeyCombinations(keyCombination, [shortcut keyCombination])) {
			return shortcut;
		}
	}
	
	return nil;
}

- (BOOL)shortcutsEnabled {
	return _shortcutsEnabled;
}

- (void)setShortcutsEnabled:(BOOL)shortcutsEnabled {
	if(_shortcutsEnabled != shortcutsEnabled) {
		_shortcutsEnabled = shortcutsEnabled;
		[self _setShortcutsEnabled:shortcutsEnabled];
		
		[[NSUserDefaultsController sharedUserDefaultsController]
			setValue:[NSNumber numberWithBool:_shortcutsEnabled]
			forKeyPath:@"values.globalShortcutsEnabled"];
	}
}

@end
