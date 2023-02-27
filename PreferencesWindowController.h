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

#import "WindowController.h"

@class ShortcutRecorder;

@interface PreferencesWindowController : WindowController<NSWindowDelegate, NSToolbarDelegate, NSAnimationDelegate> {
	IBOutlet NSView* generalPreferencesView;
	IBOutlet NSView* albumCoverPreferencesView;
	IBOutlet NSView* shortcutPreferencesView;
	IBOutlet NSView* lastFMPreferencesView;
	IBOutlet NSView* advancedPreferencesView;

	IBOutlet NSView* shortcutPreferencesContentView;
	IBOutlet NSView* generalShortcutPreferencesView;
	IBOutlet NSView* musicSearchShortcutPreferencesView;
	IBOutlet NSView* enhancedShortcutPreferencesView;
	
	IBOutlet NSButton* launchAtLogin;
	IBOutlet NSButton* launchWithiTunes;
	
	IBOutlet NSButton* showStatusItem;
	IBOutlet NSButton* showDockItem;
	
	IBOutlet ShortcutRecorder* showApplicationWindowShortcut;
	
	IBOutlet ShortcutRecorder* playPauseSongShortcut;
	IBOutlet ShortcutRecorder* nextSongShortcut;
	IBOutlet ShortcutRecorder* previousSongShortcut;
	
	IBOutlet ShortcutRecorder* toggleSongRepeatShortcut;
	IBOutlet ShortcutRecorder* toggleShuffleShortcut;
	
	IBOutlet ShortcutRecorder* increaseSoundVolumeShortcut;
	IBOutlet ShortcutRecorder* decreaseSoundVolumeShortcut;
	IBOutlet ShortcutRecorder* muteSoundVolumeShortcut;

	IBOutlet ShortcutRecorder* increaseUserRating;
	IBOutlet ShortcutRecorder* decreaseUserRating;
	
	IBOutlet ShortcutRecorder* showMusicSearchShortcut;
	IBOutlet ShortcutRecorder* searchForAllShortcut;
	IBOutlet ShortcutRecorder* searchForArtistsShortcut;
	IBOutlet ShortcutRecorder* searchForAlbumsShortcut;
	IBOutlet ShortcutRecorder* searchForSongsShortcut;
	IBOutlet ShortcutRecorder* searchByUserRatingShortcut;
	IBOutlet ShortcutRecorder* searchForPlaylistsShortcut;
	
	IBOutlet ShortcutRecorder* nextAlbumShortcut;
	IBOutlet ShortcutRecorder* previousAlbumShortcut;
	
	IBOutlet ShortcutRecorder* unrateSongShortcut;
	IBOutlet ShortcutRecorder* rateSongWithOneStarShortcut;
	IBOutlet ShortcutRecorder* rateSongWithTwoStarsShortcut;
	IBOutlet ShortcutRecorder* rateSongWithThreeStarsShortcut;
	IBOutlet ShortcutRecorder* rateSongWithFourStarsShortcut;
	IBOutlet ShortcutRecorder* rateSongWithFiveStarsShortcut;
	
	IBOutlet ShortcutRecorder* showiTunesShortcut;
	IBOutlet ShortcutRecorder* showCurrentSongShortcut;
	IBOutlet ShortcutRecorder* showLyricsWindowShortcut;
	
	IBOutlet NSButton* jewelcase;
	IBOutlet NSButton* jewelboxing;
	IBOutlet NSButton* vinyl;
	
	IBOutlet NSMatrix* albumCoverSizeMatrix;
	
@private
	NSToolbar* _toolbar;
	BOOL _animationInProgress;
	
	NSRect shortcutsViewFrame;
	BOOL _shortcutsInitialized;
}

+ (PreferencesWindowController*)preferencesWindowController;

- (IBAction)showGeneralPreferences:(id)sender;
- (IBAction)showAlbumCoverPreferences:(id)sender;
- (IBAction)showShortcutPreferences:(id)sender;
- (IBAction)showLastFMPreferences:(id)sender;
- (IBAction)showAdvancedPreferences:(id)sender;

@end
