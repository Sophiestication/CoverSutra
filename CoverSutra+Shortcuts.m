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

#import "CoverSutra+Shortcuts.h"
#import "CoverSutra+Menu.h"
#import "CoverSutra+Private.h"

#import "ApplicationWindowController.h"
#import "MusicSearchWindowController.h"

#import "PlaybackController.h"
#import "PlaybackController+Private.h"

#import "PlayerController.h"
#import "NowPlayingController.h"
#import "StarRatingController.h"

#import "ShortcutController.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "MusicLibraryTrack.h"

#import "SCBezelController.h"
#import "SCBezelController+Playback.h"
#import "SCBezelController+Alert.h"

#import "NSEvent+SpecialKeys.h"
#import "NSString+Additions.h"

@implementation CoverSutra(Shortcuts)

- (void)showApplicationWindow:(id)sender {
	ShortcutEvent* event = sender;

	if([event type] == NSKeyDown) {
		ApplicationWindowController* applicationWindowController = [self applicationWindowController];

		if([applicationWindowController isVisible]) {
			[applicationWindowController orderOut:sender];
		} else {
			[applicationWindowController orderFront:sender];
		}
	} else if([event type] == NSKeyUp) {
		Shortcut* shortcut = [event shortcut];
		double interval = fabs([event timestamp] - [[shortcut currentShortcutDownEvent] timestamp]);
	
		if(interval >= 0.5) {
			ApplicationWindowController* applicationWindowController = [self applicationWindowController];

			if([applicationWindowController isVisible]) {
				[applicationWindowController orderOut:sender];
			}
		} else {
//			[self activateIfNeeded];
		}
	}
}

- (void)showLyricsWindow:(id)sender {
/*
	ShortcutEvent* event = sender;
	SCLyricsWindowController* lyricsWindowController = [self lyricsWindowController];
	
	if ([event type] == NSKeyDown) {
		if ([lyricsWindowController isVisible]) {
			[lyricsWindowController orderOut:sender];
		} else {
			[lyricsWindowController orderFront:sender];
		}
	} else if ([event type] == NSKeyUp) {
		Shortcut* shortcut = [event shortcut];
		double interval = fabs([event timestamp] - [[shortcut currentShortcutDownEvent] timestamp]);
		
		if (interval >= 0.5) {
			if ([lyricsWindowController isVisible]) {
				[lyricsWindowController orderOut:sender];
			}
		}
	}
*/
}

- (void)showMusicSearch:(id)sender {
	ShortcutEvent* event = sender;
	
	if([event type] == NSKeyDown) {
		[[self musicSearchWindowController] toggleWindowShown:sender];
	}
}

- (void)searchForAll:(id)sender {
	ShortcutEvent* event = sender;
	
	if([event type] == NSKeyDown) {
		MusicSearchWindowController* windowController = [self musicSearchWindowController];
		
		if(windowController.filter == PopupSearchFieldAllFilter && windowController.isVisible) {
			[windowController toggleWindowShown:sender];
		} else {
			[windowController orderFront:sender];
			[windowController filterByAll:sender];
		}
	}
}

- (void)searchForArtists:(id)sender {
	ShortcutEvent* event = sender;
	
	if([event type] == NSKeyDown) {
		MusicSearchWindowController* windowController = [self musicSearchWindowController];
		
		if(windowController.filter == PopupSearchFieldArtistFilter && windowController.isVisible) {
			[windowController toggleWindowShown:sender];
		} else {
			[windowController orderFront:sender];
			[windowController filterByArtist:sender];
		}
	}
}

- (void)searchForAlbums:(id)sender {
	ShortcutEvent* event = sender;
	
	if([event type] == NSKeyDown) {
		MusicSearchWindowController* windowController = [self musicSearchWindowController];
		
		if(windowController.filter == PopupSearchFieldAlbumFilter && windowController.isVisible) {
			[windowController toggleWindowShown:sender];
		} else {
			[windowController orderFront:sender];
			[windowController filterByAlbum:sender];
		}
	}
}

- (void)searchForSongs:(id)sender {
	ShortcutEvent* event = sender;
	
	if([event type] == NSKeyDown) {
		MusicSearchWindowController* windowController = [self musicSearchWindowController];
		
		if(windowController.filter == PopupSearchFieldSongFilter && windowController.isVisible) {
			[windowController toggleWindowShown:sender];
		} else {
			[windowController orderFront:sender];
			[windowController filterBySong:sender];
		}
	}
}

- (void)searchByUserRating:(id)sender {
	ShortcutEvent* event = sender;
	
	if([event type] == NSKeyDown) {
		MusicSearchWindowController* windowController = [self musicSearchWindowController];
		
		if(windowController.filter == PopupSearchFieldUserRatingFilter && windowController.isVisible) {
			[windowController toggleWindowShown:sender];
		} else {
			[windowController orderFront:sender];
			[windowController filterByUserRating:sender];
		}
	}
}

- (void)searchForPlaylists:(id)sender {
	ShortcutEvent* event = sender;
	
	if([event type] == NSKeyDown) {
		MusicSearchWindowController* windowController = [self musicSearchWindowController];
		
		if(windowController.filter == PopupSearchFieldPlaylistFilter && windowController.isVisible) {
			[windowController toggleWindowShown:sender];
		} else {
			[windowController orderFront:sender];
			[windowController filterByPlaylist:sender];
		}
	}
}

- (void)playPauseSong:(id)sender {	
	if([((ShortcutEvent*)sender) type] == NSKeyDown) {
		PlaybackController* playbackController = self.playbackController;
		PlayerController* playerController = self.playerController;
		
		if(playerController.iTunesIsBusy) {
			[[SCBezelController sharedController] orderFrontPlayerIsBusyBezel:sender];
		} else if(!playerController.iTunesIsRunning) {
			// Show player is launching bezel
			[[SCBezelController sharedController] orderFrontPlayerLaunchingBezel:sender];
			
			// We need to play after launching
			playbackController.shouldPlayAfterLaunching = YES;
			
			// Launch iTunes...
			[self openPlayer:sender];
		} else {
			[playbackController playpause];
			[[SCBezelController sharedController] orderFrontPlaypauseBezel:sender];
		}
	} else {
		[[SCBezelController sharedController] scheduleOrderOut:sender];
	}
}

- (void)nextSong:(id)sender {
	// Reset the current rating controller
	self.currentRatingController = nil;
	
	PlaybackController* playbackController = self.playbackController;
	
	// Plain old event handler
	if(![sender isKindOfClass:[ShortcutEvent class]]) {
		[playbackController nextTrack];
		
		[[SCBezelController sharedController] orderFrontSkippingBezel:sender];
		[[SCBezelController sharedController] scheduleOrderOut:sender];

		return;
	}
	
	// Special shortcuts code
	if([((ShortcutEvent*)sender) type] == NSKeyDown) {
		_delayActionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
			target:self
			selector:@selector(_fastForward:)
			userInfo:nil
			repeats:NO];
			
		[[SCBezelController sharedController] orderFrontSkippingBezel:sender];
	} else if([((ShortcutEvent*)sender) type] == NSKeyUp) {
		[_delayActionTimer invalidate], _delayActionTimer = nil;
		
		if(playbackController.fastForwarding) {
			[playbackController resume];
			
			[[SCBezelController sharedController] scheduleOrderOut:sender];
			
			return;
		}
		
		PlayerController* playerController = self.playerController;
	
		if(playerController.iTunesIsRunning && !playerController.iTunesIsBusy) {
//			// Synchronize state with iTunes
//			[player _updateSelectedPlaylist];

			[playbackController nextTrack];
			[[SCBezelController sharedController] orderFrontSkippingBezel:sender];
		}

		[[SCBezelController sharedController] scheduleOrderOut:sender];
	}
}

- (void)previousSong:(id)sender {
	// Reset the current rating controller
	self.currentRatingController = nil;
	
	PlaybackController* playbackController = self.playbackController;
	
	// Plain old event handler
	if(![sender isKindOfClass:[ShortcutEvent class]]) {
		[playbackController backTrack];
		
		[[SCBezelController sharedController] orderFrontRewindingBezel:sender];
		[[SCBezelController sharedController] scheduleOrderOut:sender];

		return;
	}
	
	// Special shortcuts code
	if([((ShortcutEvent*)sender) type] == NSKeyDown) {
		_delayActionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
			target:self
			selector:@selector(_rewind:)
			userInfo:nil
			repeats:NO];
			
		[[SCBezelController sharedController] orderFrontRewindingBezel:sender];
	} else if([((ShortcutEvent*)sender) type] == NSKeyUp) {
		[_delayActionTimer invalidate], _delayActionTimer = nil;
		
		if(playbackController.rewinding) {
			[playbackController resume];
			[[SCBezelController sharedController] scheduleOrderOut:sender];
			
			return;
		}
		
		PlayerController* playerController = self.playerController;
	
		if(playerController.iTunesIsRunning && !playerController.iTunesIsBusy) {
//			// Synchronize state with iTunes
//			[player _updateSelectedPlaylist];

			[playbackController backTrack];
			[[SCBezelController sharedController] orderFrontRewindingBezel:sender];
		}

		[[SCBezelController sharedController] scheduleOrderOut:sender];
	}
}

- (void)nextAlbum:(id)sender {
}

- (void)previousAlbum:(id)sender {
}

- (void)toggleShuffle:(id)sender {
	if([self _isShortcutEvent:sender]) {
		if([((ShortcutEvent*)sender) type] == NSKeyUp) {
			[[SCBezelController sharedController] scheduleOrderOut:sender];
			
			return;
		}
	}
	
	[[self playbackController] toggleShuffle];
	
	if([self _isShortcutEvent:sender]) {
		if([((ShortcutEvent*)sender) type] == NSKeyDown) {
			[[SCBezelController sharedController] orderFrontShuffleBezel:sender];
			
		}
	}
}

- (void)toggleSongRepeat:(id)sender {
	if([self _isShortcutEvent:sender]) {
		if([((ShortcutEvent*)sender) type] == NSKeyUp) {
			[[SCBezelController sharedController] scheduleOrderOut:sender];
			
			return;
		}
	}
	
	[[self playbackController] toggleRepeatMode];
	
	if([self _isShortcutEvent:sender]) {
		if([((ShortcutEvent*)sender) type] == NSKeyDown) {
			[[SCBezelController sharedController] orderFrontRepeatModeBezel:sender];
			
		}
	}
}

- (void)increaseSoundVolume:(id)sender {
	// Special shortcuts code
	if([self _isShortcutEvent:sender] && [(ShortcutEvent*)sender type] == NSKeyUp) {
		[_increaseSoundVolumeDelayTimer invalidate], _increaseSoundVolumeDelayTimer = nil;
		[_repeatActionTimer invalidate], _repeatActionTimer = nil;
			
		[[SCBezelController sharedController] scheduleOrderOut:sender];
		
		return;
	}

	[[self playbackController] increaseSoundVolume];
	
	if(self.playbackController.soundVolume >= 100) {
		[_increaseSoundVolumeDelayTimer invalidate], _increaseSoundVolumeDelayTimer = nil;
		[_repeatActionTimer invalidate], _repeatActionTimer = nil;
	}

	// Special shortcuts code
	if([self _isShortcutEvent:sender] && [(ShortcutEvent*)sender type] == NSKeyDown) {
		[_repeatActionTimer invalidate], _repeatActionTimer = nil;
		
		_increaseSoundVolumeDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
			target:self
			selector:@selector(_increaseSoundVolume:)
			userInfo:nil
			repeats:NO];

		[[SCBezelController sharedController] orderFrontSoundVolumeBezel:sender];
	}
}

- (void)decreaseSoundVolume:(id)sender {
	// Special shortcuts code
	if([self _isShortcutEvent:sender] && [(ShortcutEvent*)sender type] == NSKeyUp) {
		[_decreaseSoundVolumeDelayTimer invalidate], _decreaseSoundVolumeDelayTimer = nil;
		[_repeatActionTimer invalidate], _repeatActionTimer = nil;
			
		[[SCBezelController sharedController] scheduleOrderOut:sender];
		
		return;
	}
	
	[[self playbackController] decreaseSoundVolume];
	
	if(self.playbackController.soundVolume <= 0) {
		[_decreaseSoundVolumeDelayTimer invalidate], _decreaseSoundVolumeDelayTimer = nil;
		[_repeatActionTimer invalidate], _repeatActionTimer = nil;
	}
	
	// Special shortcuts code
	if([self _isShortcutEvent:sender] && [(ShortcutEvent*)sender type] == NSKeyDown) {
		[_repeatActionTimer invalidate], _repeatActionTimer = nil;
		
		_decreaseSoundVolumeDelayTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
			target:self
			selector:@selector(_decreaseSoundVolume:)
			userInfo:nil
			repeats:NO];
			
		[[SCBezelController sharedController] orderFrontSoundVolumeBezel:sender];
	}
}

- (void)muteSoundVolume:(id)sender {
	if([self _isShortcutEvent:sender]) {
		if([((ShortcutEvent*)sender) type] == NSKeyUp) {
			[[SCBezelController sharedController] scheduleOrderOut:sender];
			return;
		}
	}
	
	if(!self.playerController.iTunesIsBusy && self.playerController.iTunesIsRunning) {
		self.playbackController.mute = !self.playbackController.mute;
	}
	
	if([self _isShortcutEvent:sender]) {
		if([((ShortcutEvent*)sender) type] == NSKeyDown) {
			[[SCBezelController sharedController] orderFrontSoundVolumeBezel:sender];
		}
	}
}

- (void)increaseUserRating:(id)sender {
	[self _rateUsingSelector:@selector(increaseRating) sender:sender];
}

- (void)decreaseUserRating:(id)sender {
	[self _rateUsingSelector:@selector(decreaseRating) sender:sender];
}

- (void)halfIncreaseUserRating:(id)sender {
	[self _rateUsingSelector:@selector(halfIncreaseRating) sender:sender];
}

- (void)halfDecreaseUserRating:(id)sender {
	[self _rateUsingSelector:@selector(halfDecreaseRating) sender:sender];
}

- (void)unrateSong:(id)sender {
	[self _rateCurrentSongWith:UnratedRating sender:sender];
}

- (void)rateSongWithOneStar:(id)sender {
	[self _rateCurrentSongWith:OneStarRating sender:sender];
}

- (void)rateSongWithTwoStars:(id)sender {
	[self _rateCurrentSongWith:TwoStarsRating sender:sender];
}

- (void)rateSongWithThreeStars:(id)sender {
	[self _rateCurrentSongWith:ThreeStarsRating sender:sender];
}

- (void)rateSongWithFourStars:(id)sender {
	[self _rateCurrentSongWith:FourStarsRating sender:sender];
}

- (void)rateSongWithFiveStars:(id)sender {
	[self _rateCurrentSongWith:FiveStarsRating sender:sender];
}

- (void)showiTunes:(id)sender {
	ShortcutEvent* event = sender;
	
	PlayerController* playerController = self.playerController;
	
	if([event type] == NSKeyDown) {
		if(playerController.iTunesIsRunning) {
			playerController.iTunesIsFrontmost = !playerController.iTunesIsFrontmost;
		} else {
			// TODO
			playerController.iTunesIsFrontmost = YES;
		}
	} else if([event type] == NSKeyUp) {
		Shortcut* shortcut = [event shortcut];
		double interval = fabs([event timestamp] - [[shortcut currentShortcutDownEvent] timestamp]);
	
		if(interval >= 0.5) {
			if(playerController.iTunesIsFrontmost) {
				playerController.iTunesIsFrontmost = NO;
			}
		}
	}
}

- (void)showCurrentSong:(id)sender {
	NS_DURING
		[CSiTunesApplication() activate];
		[[CSiTunesApplication() currentTrack] reveal];
	NS_HANDLER
	NS_ENDHANDLER
}

- (void)shortcutDown:(id)sender {
}

- (void)shortcutUp:(id)sender {
}

- (BOOL)_isShortcutEvent:(id)event {
	return [event isKindOfClass:[ShortcutEvent class]];
}

- (void)next:(NSEvent*)theEvent {
	// Check if iTunes is still the active player
	if(!self.playerController.iTunesIsCurrentPlayer) {
		return;
	}
	
	// Order bezel to front if needed
	if([theEvent isSpecialKeyDown] && ![theEvent isSpecialKeyARepeat]) {
		// Ignore the next track change
		self.playbackController.shouldNotNotifyAboutTrackChanges = YES;
		
		[self performSelector:@selector(_orderFrontNextSongBezel:)
			withObject:theEvent
			afterDelay:0.25];
	}
	
//	// Display the fast forward bezel
	if([theEvent isSpecialKeyDown] && [theEvent isSpecialKeyARepeat]) {
		[[SCBezelController sharedController] orderFrontSkippingBezel:theEvent];
		[[SCBezelController sharedController] scheduleOrderOut:theEvent];
	}
}

- (void)previous:(NSEvent*)theEvent {
	// Check if iTunes is still the active player
	if(!self.playerController.iTunesIsCurrentPlayer) {
		return;
	}
	
	// Order bezel to front if needed
	if([theEvent isSpecialKeyDown] && ![theEvent isSpecialKeyARepeat]) {
		// Ignore the next track change
		self.playbackController.shouldNotNotifyAboutTrackChanges = YES;
		
		[self performSelector:@selector(_orderFrontPreviousSongBezel:)
			withObject:theEvent
			afterDelay:0.25];
	}
	
	// Display the rewind bezel
	if([theEvent isSpecialKeyDown] && [theEvent isSpecialKeyARepeat]) {
		[[SCBezelController sharedController] orderFrontRewindingBezel:theEvent];
		[[SCBezelController sharedController] scheduleOrderOut:theEvent];
	}
}

- (void)increaseSystemSoundVolume:(NSEvent*)theEvent {
	if([theEvent isSpecialKeyDown]) {
		[[SCBezelController sharedController] orderOutImmediately:theEvent];
	}
}

- (void)decreaseSystemSoundVolume:(NSEvent*)theEvent {
	if([theEvent isSpecialKeyDown]) {
		[[SCBezelController sharedController] orderOutImmediately:theEvent];
	}
}

- (void)muteSystemSoundVolume:(NSEvent*)theEvent {
	if([theEvent isSpecialKeyDown]) {
		[[SCBezelController sharedController] orderOutImmediately:theEvent];
	}
}

@end
