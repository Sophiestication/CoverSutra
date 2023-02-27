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

#import "PreferencesWindowController+Shortcuts.h"
#import "PreferencesWindowController+Private.h"

#import "ShortcutController.h"
#import "ShortcutRecorder.h"

#import "NSArray+Additions.h"

@implementation PreferencesWindowController(Shortcuts)

- (IBAction)selectShortcutPreferences:(id)sender {
	NSInteger selectedSegment = [sender selectedSegment];

	NSView* newView = nil;
	
	switch(selectedSegment) {
		case 1:
			newView = musicSearchShortcutPreferencesView;
		break;
		
		case 2:
			newView = enhancedShortcutPreferencesView;
		break;
		
		default:
			newView = generalShortcutPreferencesView;
		break;
	};

	[self _showShortcutsView:newView resizeWindow:YES];
}

- (void)_initShortcutPreferences {
	if(_shortcutsInitialized) {
		return;
	}
	
	NSArray* shortcuts = [[ShortcutController sharedShortcutController] allShortcuts];
	
	unsigned numberOfShortcuts = [shortcuts count];
	unsigned shortcutIndex = 0;
	
	for(; shortcutIndex < numberOfShortcuts; ++shortcutIndex)  {
		Shortcut* shortcut = [shortcuts objectAtIndex:shortcutIndex];
		
		ShortcutRecorder* recorder = [self _controlForPreferenceKey:[shortcut identifier]];
		
		if(recorder) {
			KeyCombo keyCombo = SRMakeKeyCombo(
				[[shortcut keyCombination] keyCode],
				[[shortcut keyCombination] modifiers]);
			[recorder setKeyCombo:keyCombo];
			
			[recorder setDelegate:self];
		} else {
			NSLog(@"Could not find recorder for shortcut %@", [shortcut identifier]);
		}
	}
	
	[self _showShortcutsView:generalShortcutPreferencesView resizeWindow:NO];
	
	_shortcutsInitialized = YES;
}

- (void)_showShortcutsView:(NSView*)newView resizeWindow:(BOOL)resizeWindow {
	CGFloat heightDelta = NSHeight(newView.frame) - NSHeight(shortcutPreferencesContentView.frame);
	
	// Replace the content view
	[shortcutPreferencesContentView setSubviews:
		[NSArray arrayWithObject:newView]];
		
	NSRect newContentFrame = shortcutPreferencesView.frame;
	newContentFrame.size.height += heightDelta;
	
	[shortcutPreferencesView setFrame:newContentFrame];
	
	if(resizeWindow) {
		// Resize the window regarding our new content height
		NSRect newWindowFrame = self.window.frame;
		
		newWindowFrame.size.height += heightDelta;
		newWindowFrame.origin.y -= heightDelta;
		
		[self.window setFrame:newWindowFrame display:YES animate:NO];
	}
}

- (BOOL)shortcutRecorder:(ShortcutRecorder*)recorder isKeyCode:(signed short)keyCode andFlagsTaken:(unsigned int)flags reason:(NSString**)aReason {
	return NO;
}

- (void)shortcutRecorder:(ShortcutRecorder*)recorder keyComboDidChange:(KeyCombo)newKeyCombo {
	KeyCombination* keyCombination = [KeyCombination
		keyCombinationWithKeyCode:newKeyCombo.code
		modifiers:newKeyCombo.flags];
	
	id shortcutIdentifier = [self _preferenceKeyForControl:recorder];
	Shortcut* shortcut = [[ShortcutController sharedShortcutController]
		shortcutForIdentifier:shortcutIdentifier];
	
	if(!shortcut) {
		shortcut = [Shortcut shortcutWithIdentifier:shortcutIdentifier keyCombination:keyCombination];
	}
	
	if(![keyCombination isValid]) {
		[shortcut setKeyCombination:[KeyCombination emptyKeyCombination]];
		return;
	}
	
	if(EqualKeyCombinations(keyCombination, [shortcut keyCombination])) {
		return;
	}
	
	Shortcut* previousShortcut = [[ShortcutController sharedShortcutController]
		shortcutForKeyCombination:keyCombination];
		
	if(previousShortcut) {
		[[self _controlForPreferenceKey:[previousShortcut identifier]]
			setKeyCombo:SRMakeKeyCombo(-1, 0)];
		[previousShortcut setKeyCombination:nil];
	}
	
	[shortcut setKeyCombination:keyCombination];
}

- (NSString*)_preferenceKeyForControl:(ShortcutRecorder*)control {
	if(control == showApplicationWindowShortcut) { return @"showApplicationWindow"; }
	
	if(control == playPauseSongShortcut) { return @"playPauseSong"; }
	if(control == nextSongShortcut) { return @"nextSong"; }
	if(control == previousSongShortcut) { return @"previousSong"; }
	
	if(control == showiTunesShortcut) { return @"showiTunes"; }
	if(control == showCurrentSongShortcut) { return @"showCurrentSong"; }
	if (control == showLyricsWindowShortcut) { return @"showLyricsWindow"; }
	
	if(control == toggleSongRepeatShortcut) { return @"toggleSongRepeat"; }
	
	if(control == toggleShuffleShortcut) { return @"toggleShuffle"; }
	
	if(control == muteSoundVolumeShortcut) { return @"muteSoundVolume"; }
	
	if(control == increaseSoundVolumeShortcut) { return @"increaseSoundVolume"; }
	if(control == decreaseSoundVolumeShortcut) { return @"decreaseSoundVolume"; }
	
	if(control == showMusicSearchShortcut) { return @"showMusicSearch"; }
	if(control == searchForAllShortcut) { return @"searchForAll"; }
	if(control == searchForArtistsShortcut) { return @"searchForArtists"; }
	if(control == searchForAlbumsShortcut) { return @"searchForAlbums"; }
	if(control == searchForSongsShortcut) { return @"searchForSongs"; }
	if(control == searchByUserRatingShortcut) { return @"searchByUserRating"; }
	if(control == searchForPlaylistsShortcut) { return @"searchForPlaylists"; }
	
	if(control == nextAlbumShortcut) { return @"nextAlbum"; }
	if(control == previousAlbumShortcut) { return @"previousAlbum"; }

	if(control == unrateSongShortcut) { return @"unrateSong"; }
	if(control == rateSongWithOneStarShortcut) { return @"rateSongWithOneStar"; }
	if(control == rateSongWithTwoStarsShortcut) { return @"rateSongWithTwoStars"; }
	if(control == rateSongWithThreeStarsShortcut) { return @"rateSongWithThreeStars"; }
	if(control == rateSongWithFourStarsShortcut) { return @"rateSongWithFourStars"; }
	if(control == rateSongWithFiveStarsShortcut) { return @"rateSongWithFiveStars"; }

	if(control == increaseUserRating) { return @"increaseUserRating"; }
	if(control == decreaseUserRating) { return @"decreaseUserRating"; }

	return nil;
}

- (ShortcutRecorder*)_controlForPreferenceKey:(NSString*)preferenceKey {
	if([preferenceKey isEqualToString:@"showApplicationWindow"]) { return showApplicationWindowShortcut; }
	
	if([preferenceKey isEqualToString:@"playPauseSong"]) { return playPauseSongShortcut; }
	if([preferenceKey isEqualToString:@"nextSong"]) { return nextSongShortcut; }
	if([preferenceKey isEqualToString:@"previousSong"]) { return previousSongShortcut; }
	
	if([preferenceKey isEqualToString:@"showiTunes"]) { return showiTunesShortcut; }
	if([preferenceKey isEqualToString:@"showCurrentSong"]) { return showCurrentSongShortcut; }
	if ([preferenceKey isEqualToString:@"showLyricsWindow"]) { return showLyricsWindowShortcut; }
	
	if([preferenceKey isEqualToString:@"toggleSongRepeat"]) { return toggleSongRepeatShortcut; }
	if([preferenceKey isEqualToString:@"toggleShuffle"]) { return toggleShuffleShortcut; }
	
	if([preferenceKey isEqualToString:@"muteSoundVolume"]) { return muteSoundVolumeShortcut; }
	if([preferenceKey isEqualToString:@"increaseSoundVolume"]) { return increaseSoundVolumeShortcut; }
	if([preferenceKey isEqualToString:@"decreaseSoundVolume"]) { return decreaseSoundVolumeShortcut; }
	
	if([preferenceKey isEqualToString:@"showMusicSearch"]) { return showMusicSearchShortcut; }
	if([preferenceKey isEqualToString:@"searchForAll"]) { return searchForAllShortcut; }
	if([preferenceKey isEqualToString:@"searchForArtists"]) { return searchForArtistsShortcut; }
	if([preferenceKey isEqualToString:@"searchForAlbums"]) { return searchForAlbumsShortcut; }
	if([preferenceKey isEqualToString:@"searchForSongs"]) { return searchForSongsShortcut; }
	if([preferenceKey isEqualToString:@"searchByUserRating"]) { return searchByUserRatingShortcut; }
	if([preferenceKey isEqualToString:@"searchForPlaylists"]) { return searchForPlaylistsShortcut; }
	
	if([preferenceKey isEqualToString:@"nextAlbum"]) { return nextAlbumShortcut; }
	if([preferenceKey isEqualToString:@"previousAlbum"]) { return previousAlbumShortcut; }

	if([preferenceKey isEqualToString:@"unrateSong"]) { return unrateSongShortcut; }
	if([preferenceKey isEqualToString:@"rateSongWithOneStar"]) { return rateSongWithOneStarShortcut; }
	if([preferenceKey isEqualToString:@"rateSongWithTwoStars"]) { return rateSongWithTwoStarsShortcut; }
	if([preferenceKey isEqualToString:@"rateSongWithThreeStars"]) { return rateSongWithThreeStarsShortcut; }
	if([preferenceKey isEqualToString:@"rateSongWithFourStars"]) { return rateSongWithFourStarsShortcut; }
	if([preferenceKey isEqualToString:@"rateSongWithFiveStars"]) { return rateSongWithFiveStarsShortcut; }
	
	if([preferenceKey isEqualToString:@"increaseUserRating"]) { return increaseUserRating; }
	if([preferenceKey isEqualToString:@"decreaseUserRating"]) { return decreaseUserRating; }
	
	return nil;
}

@end
