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

#import "CoverSutra+Menu.h"

#import "NSEvent+Additions.h"
#import "NSEvent+SpecialKeys.h"
#import "NSMenu+Additions.h"

#import "ApplicationWindowController.h"
#import "DesktopWindowController.h"
#import "MusicSearchWindowController.h"

#import "NowPlayingController.h"
#import "PlayerController.h"
#import "PlaybackController.h"
#import "PlaybackController+Private.h"

#import "MusicLibraryAlbum.h"
#import "MusicLibraryAlbum+UIAdditions.h"

#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Scripting.h"

#import "SCBezelController.h"
#import "SCBezelController+Playback.h"
#import "SCBezelController+Alert.h"

#import "ShortcutController.h"
#import "LastDotFMController.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "Utilities.h"

#import "obsolete__SCLyricsWindowController.h"

@implementation CoverSutra(Menu)

- (IBAction)playpause:(id)sender {
	if([sender isKindOfClass:[NSEvent class]] && [sender isSpecialKeyEvent]) {
		// Check if iTunes is still the active player
		if(![[self playerController] iTunesIsCurrentPlayer]) {
			return;
		}
		
		if(![[self playerController] iTunesIsRunning]) {
			// Show player is launching bezel
			[[SCBezelController sharedController] orderFrontPlayerLaunchingBezel:sender];
			[[SCBezelController sharedController] scheduleOrderOut:sender];
			
			// We need to play after launching
			self.playbackController.shouldPlayAfterLaunching = YES; // TODO
			
			// Launch iTunes...
			[self openPlayer:sender];
			
			return;
		}
		
		// Order the play/pause bezel front if needed
		if([sender isSpecialKeyDown] && ![sender isSpecialKeyARepeat]) {
			[self performSelector:@selector(_playpause:)
				withObject:sender
				afterDelay:0.25];
		}
		
		if(![sender isSpecialKeyDown] || [sender isSpecialKeyARepeat]) {
			[[SCBezelController sharedController] orderFrontPlaypauseBezel:sender];
			[[SCBezelController sharedController] scheduleOrderOut:sender];
		}

		return;
	}

	[[self playbackController] playpause];
}

- (IBAction)repeatNone:(id)sender {
	self.playbackController.repeatMode = PlaybackRepeatModeOff;
}

- (IBAction)repeatOne:(id)sender {
	self.playbackController.repeatMode = PlaybackRepeatModeOne;
}

- (IBAction)repeatAll:(id)sender {
	self.playbackController.repeatMode = PlaybackRepeatModeAll;
}

- (IBAction)toggleApplicationWindowShown:(id)sender {
	ApplicationWindowController* applicationWindowController = [self applicationWindowController];
	
	if([applicationWindowController isVisible]) {
		[applicationWindowController orderOut:sender];
	} else {
		[applicationWindowController orderFront:sender];
	}
}

- (IBAction)toggleDesktopWindowShown:(id)sender {
	DesktopWindowController* desktopWindowController = [self desktopWindowController];
	
	if([desktopWindowController isVisible]) {
		[desktopWindowController orderOut:sender];
	} else {
		[desktopWindowController orderFront:sender];
	}
}

- (IBAction)toggleLyricsWindowShown:(id)sender {
	// TODO
}

- (IBAction)toggleGlobalShortcutsEnabled:(id)sender {
	ShortcutController* shortcutController = [ShortcutController sharedShortcutController];
	[shortcutController setShortcutsEnabled:
		![shortcutController shortcutsEnabled]];
}

- (IBAction)toggleLastFMEnabled:(id)sender {
	LastDotFMController* lastDotFMController = [self lastDotFMController];
	[lastDotFMController setSubmissionsEnabled:![lastDotFMController submissionsEnabled]];
}

- (IBAction)terminateiTunes:(id)sender {
	[CSiTunesApplication() quit];
}

- (void)menuNeedsUpdate:(NSMenu*)menu {
	// Handle the Dock menu
	if(menu == dockMenu) {
		[self dockMenuNeedsUpdate:menu];
		return;
	}
	
	// Add or Remove desktop window item if necessary
/*	int desktopWindowMenuItemIndex = [menu indexOfItemWithTag:4004];
	BOOL playerIsRunning = self.playerController.iTunesIsRunning;
	
	if(playerIsRunning && desktopWindowMenuItemIndex < 0) {
		NSMenuItem* desktopWindowMenuItem = [[[NSMenuItem alloc] initWithTitle:@""
			action:@selector(toggleDesktopWindowShown:)
			keyEquivalent:@""] autorelease];
		[desktopWindowMenuItem setTag:4004];
		
		desktopWindowMenuItemIndex = [menu indexOfItemWithTag:1];
		
		[menu insertItem:desktopWindowMenuItem
			atIndex:desktopWindowMenuItemIndex]; // Insert just before the separator
	} else if(!playerIsRunning && desktopWindowMenuItemIndex >= 0) {
		[menu removeItemAtIndex:desktopWindowMenuItemIndex];
	}*/
	
	// Add or Remove Last.fm item if necessary
	int lastFMMenuItemIndex = [menu indexOfItemWithTag:4003];
	
	if(lastFMMenuItemIndex < 0 && !IsEmpty([[self lastDotFMController] account])) {
		NSMenuItem* lastFMMenuItem = [[NSMenuItem alloc] initWithTitle:@""
			action:@selector(toggleLastFMEnabled:)
			keyEquivalent:@""];
		[lastFMMenuItem setTag:4003];
		
		lastFMMenuItemIndex = [menu indexOfItemWithTag:2];
		
		[menu insertItem:lastFMMenuItem
			atIndex:lastFMMenuItemIndex]; // Insert just before the separator
	} else if(lastFMMenuItemIndex >= 0 && IsEmpty([[self lastDotFMController] account])) {
		[menu removeItemAtIndex:lastFMMenuItemIndex];
	}
}

- (void)dockMenuNeedsUpdate:(NSMenu*)menu {
	MusicLibraryTrack* currentTrack = [[self nowPlayingController] track];
	MusicLibraryAlbum* currentAlbum = [[self nowPlayingController] album];
	
	[menu removeAllItems];
	
	if(currentTrack) {
		// Add now playing info
		[menu
			addItemWithTitle:NSLocalizedString(@"NOWPLAYING_MENUITEM", @"Now playing menu item title")
			action:nil
			keyEquivalent:@""];
		
		[menu
			addItemWithTitle:[NSString stringWithFormat:@"  %@", currentTrack.displayAlbum]
			action:nil
			keyEquivalent:@""];
			
		[menu
			addItemWithTitle:[NSString stringWithFormat:@"  %@", currentTrack.displayAlbumArtist]
			action:nil
			keyEquivalent:@""];
		
		if(currentAlbum) {
			[menu addItem:[NSMenuItem separatorItem]];
			[menu addItemsFromArray:
				[currentAlbum menuItemsForTracks:NO]];
		}
	}
	
	// Add a open iTunes menu item
	if(menu.numberOfItems <= 0) {
		if([CSiTunesApplication() isRunning]) {
			[menu addItemWithTitle:NSLocalizedString(@"NOSONG_MENUITEM", @"No song dock menu item title")
				action:nil
				keyEquivalent:@""];
		} else {
			[menu addItemWithTitle:NSLocalizedString(@"OPENITUNES_MENUITEM", @"Open iTunes dock menu item title")
				action:@selector(openPlayer:)
				keyEquivalent:@""];
		}
	}
}

- (NSMenu*)albumMenu {
	MusicLibraryTrack* currentTrack = [[self nowPlayingController] track];
	MusicLibraryAlbum* currentAlbum = [[self nowPlayingController] album];
	
	if(!currentTrack) {
		return nil;
	}

	// Add now playing info
	NSMenu* menu = [[NSMenu alloc] initWithTitle:NSLocalizedString(@"NOWPLAYING_MENUITEM", @"")];
	
	[menu addItemWithTitle:[NSString stringWithFormat:@"  %@", currentTrack.displayAlbum]
		action:nil
		keyEquivalent:@""];
		
	[menu addItemWithTitle:[NSString stringWithFormat:@"  %@", currentTrack.displayAlbumArtist]
		action:nil
		keyEquivalent:@""];
	
	if(currentAlbum) {
		[menu addItem:[NSMenuItem separatorItem]];
		[menu addItemsFromArray:
			[currentAlbum menuItemsForTracks:NO]];
	}
	
	return menu;
}

- (BOOL)menuHasKeyEquivalent:(NSMenu*)menu forEvent:(NSEvent*)event target:(id*)target action:(SEL*)action {
	if([event hasSpaceKey]) {
		*target = self;
		*action = @selector(playpause:);
		return YES;
	}
	
	BOOL hasCommandKey = ([event modifierFlags] & (NSCommandKeyMask)) ? YES : NO;
	BOOL hasAltKey = ([event modifierFlags] & (NSAlternateKeyMask)) ? YES : NO;

	if(hasCommandKey) {
		if([event hasRightArrowKey]) {
			*target = self;
			*action = @selector(nextSong:);
			
			return YES;
		}
		
		if([event hasLeftArrowKey]) {
			*target = self;
			*action = @selector(previousSong:);
			
			return YES;
		}
		
		if([event hasUpArrowKey]) {
			*target = self;
			*action = @selector(increaseSoundVolume:);
			
			return YES;
		}
		
		if([event hasDownArrowKey]) {
			*target = self;
			*action = hasAltKey ? @selector(muteSoundVolume:) : @selector(decreaseSoundVolume:);
			
			return YES;
		}
	}

	return NO;
}

- (BOOL)validateMenuItem:(NSMenuItem*)menuItem {
	if([menuItem action] == @selector(toggleApplicationWindowShown:)) {
		if(_applicationWindowController && [[self applicationWindowController] isVisible]) {
			[menuItem setTitle:NSLocalizedString(@"HIDE_PLAYERCONTROLS_MENUITEM", @"")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"SHOW_PLAYERCONTROLS_MENUITEM", @"")];
		}
	}
	
	if([menuItem action] == @selector(toggleDesktopWindowShown:)) {
		if(_desktopWindowController && [[self desktopWindowController] isVisible]) {
			[menuItem setTitle:NSLocalizedString(@"HIDE_ALBUMCOVER_MENUITEM", @"")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"SHOW_ALBUMCOVER_MENUITEM", @"")];
		}
	}
	
/*
	if ([menuItem action] == @selector(toggleLyricsWindowShown:)) {
		if (_lyricsWindowController && [[self lyricsWindowController] isVisible]) {
			[menuItem setTitle:NSLocalizedString(@"HIDE_LYRICS_MENUITEM", @"")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"SHOW_LYRICS_MENUITEM", @"")];
		}
	}
*/

	if([menuItem action] == @selector(toggleGlobalShortcutsEnabled:)) {
		if([[ShortcutController sharedShortcutController] shortcutsEnabled]) {
			[menuItem setTitle:NSLocalizedString(@"DISABLE_SHORTCUTS_MENUITEM", @"")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"ENABLE_SHORTCUTS_MENUITEM", @"")];
		}
	}
	
	if([menuItem action] == @selector(toggleLastFMEnabled:)) {
		if([[self lastDotFMController] submissionsEnabled]) {
			[menuItem setTitle:NSLocalizedString(@"DISABLE_LASTFM_MENUITEM", @"")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"ENABLE_LASTFM_MENUITEM", @"")];
		}
		
		[menuItem setToolTip:
			[[self lastDotFMController] localizedStatus]];
	}
	
	if([menuItem action] == @selector(playpause:)) {
		if(self.playbackController.playing) {
			[menuItem setTitle:NSLocalizedString(@"PAUSE_MENUITEM", @"")];
		} else {
			[menuItem setTitle:NSLocalizedString(@"PLAY_MENUITEM", @"")];
		}
		
		return self.playbackController.playable;
	}
	
	if([menuItem action] == @selector(nextSong:)) {
		unichar key = NSRightArrowFunctionKey;
		[menuItem setKeyEquivalent:[NSString stringWithCharacters:&key length:1]];
		[menuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
		
		return self.playbackController.skipable;
	}
	
	if([menuItem action] == @selector(previousSong:)) {
		unichar key = NSLeftArrowFunctionKey;
		[menuItem setKeyEquivalent:[NSString stringWithCharacters:&key length:1]];
		[menuItem setKeyEquivalentModifierMask:NSCommandKeyMask];
		
		return self.playbackController.rewindable;
	}
	
	if([menuItem action] == @selector(repeatNone:) ||
	   [menuItem action] == @selector(repeatOne:) ||
	   [menuItem action] == @selector(repeatAll:)) {
		if(!self.playerController.iTunesIsRunning || self.playerController.iTunesIsBusy) {
			return NO;
		}
		
		NSString* repeatMode = nil;
		
		if([menuItem action] == @selector(repeatNone:)) {
			repeatMode = PlaybackRepeatModeOff;
		} else if([menuItem action] == @selector(repeatOne:)) {
			repeatMode = PlaybackRepeatModeOne;
		} else if([menuItem action] == @selector(repeatAll:)) {
			repeatMode = PlaybackRepeatModeAll;
		}
		
		BOOL isChecked = EqualStrings(repeatMode, self.playbackController.repeatMode);
		[menuItem setState:isChecked ? NSOnState : NSOffState];
		
		return self.playbackController.shuffleAndRepeatModeChangeable;
	}
	
	if([menuItem action] == @selector(toggleShuffle:)) {
		if(!self.playerController.iTunesIsRunning || self.playerController.iTunesIsBusy) {
			return NO;
		}
		
		[menuItem setState:self.playbackController.shuffle ? NSOnState : NSOffState];
		
		return self.playbackController.shuffleAndRepeatModeChangeable;
	}
	
	if([menuItem action] == @selector(increaseSoundVolume:)) {
		if(![[self musicSearchWindowController] isVisible]) {
			unichar key = NSUpArrowFunctionKey;
			[menuItem setKeyEquivalent:[NSString stringWithCharacters:&key length:1]];
		}

		return self.playerController.iTunesIsRunning && !self.playerController.iTunesIsBusy && self.playbackController.soundVolume < 100;
	}
	
	if([menuItem action] == @selector(decreaseSoundVolume:)) {
		if(![[self musicSearchWindowController] isVisible]) {
			unichar key = NSDownArrowFunctionKey;
			[menuItem setKeyEquivalent:[NSString stringWithCharacters:&key length:1]];
		}

		return self.playerController.iTunesIsRunning && !self.playerController.iTunesIsBusy && self.playbackController.soundVolume >= 0;
	}
	
	if([menuItem action] == @selector(muteSoundVolume:)) {
		if(![[self musicSearchWindowController] isVisible]) {
			unichar key = NSDownArrowFunctionKey;
			[menuItem setKeyEquivalent:[NSString stringWithCharacters:&key length:1]];
			[menuItem setKeyEquivalentModifierMask:NSCommandKeyMask | NSAlternateKeyMask];
		}

		[menuItem setState:self.playbackController.mute ? NSOnState : NSOffState];
		
		return self.playerController.iTunesIsRunning && !self.playerController.iTunesIsBusy;
	}
	
	if([menuItem action] == @selector(unrateSong:)) {
		MusicLibraryTrack* track = self.nowPlayingController.track;
		
		[menuItem setState:track && track.rating == 0 ? NSOnState : NSOffState];

		return track != nil && [[self applicationWindowController] isVisible];
	}
	
	if([menuItem action] == @selector(rateSongWithOneStar:)) {
		MusicLibraryTrack* track = self.nowPlayingController.track;
		
		[menuItem setState:track && track.rating == 20 ? NSOnState : NSOffState];

		return track != nil && [[self applicationWindowController] isVisible];
	}
	
	if([menuItem action] == @selector(rateSongWithTwoStars:)) {
		MusicLibraryTrack* track = self.nowPlayingController.track;
		
		[menuItem setState:track && track.rating == 40 ? NSOnState : NSOffState];

		return track != nil && [[self applicationWindowController] isVisible];
	}
	
	if([menuItem action] == @selector(rateSongWithThreeStars:)) {
		MusicLibraryTrack* track = self.nowPlayingController.track;
		
		[menuItem setState:track && track.rating == 60 ? NSOnState : NSOffState];

		return track != nil && [[self applicationWindowController] isVisible];
	}
	
	if([menuItem action] == @selector(rateSongWithFourStars:)) {
		MusicLibraryTrack* track = self.nowPlayingController.track;
		
		[menuItem setState:track && track.rating == 80 ? NSOnState : NSOffState];

		return track != nil && [[self applicationWindowController] isVisible];
	}
	
	if([menuItem action] == @selector(rateSongWithFiveStars:)) {
		MusicLibraryTrack* track = self.nowPlayingController.track;
		
		[menuItem setState:track && track.rating == 100 ? NSOnState : NSOffState];

		return track != nil && [[self applicationWindowController] isVisible];
	}

	return YES;
}

- (void)openPlayer:(id)sender {
	[CSiTunesApplication() activate];
}

- (void)play:(id)sender {
	[[sender representedObject] performSelectorInBackground:@selector(play)
		withObject:nil];
}

- (void)show:(id)sender {
	[[sender representedObject] performSelectorInBackground:@selector(show)
		withObject:nil];
}

- (void)showInFinder:(id)sender {
	[[sender representedObject] showInFinder];
}

@end
