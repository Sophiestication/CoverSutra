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

#import "LastDotFMController+Private.h"

#import "LastDotFMHandshake.h"
#import "LastDotFMHandshake+Delegate.h"

#import "LastDotFMNowPlayingNotification.h"
#import "LastDotFMNowPlayingNotification+Delegate.h"

#import "LastDotFMSubmission.h"
#import "LastDotFMSubmission+Delegate.h"

#import "LastDotFMNowPlayingNotification.h"
#import "LastDotFMNowPlayingNotification+Delegate.h"

#import "PlaybackController.h"
#import "NowPlayingController.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "MusicLibraryTrack.h"

#import "CoverSutra.h"

#import "Keychain.h"

#import "NSString+MD5.h"

#import "Utilities.h"

@implementation LastDotFMController(Private)

- (id)_credentials {
	id credentials = [NSDictionary dictionaryWithObjectsAndKeys:
		[self account], @"user",
		[[self password] md5DigestString], @"password",
		_challenge, LastDotFMHandshakeSessionIDKey,
		_submissionURLString, LastDotFMHandshakeSubmissionURLKey,
		_nowPlayingURLString, LastDotFMHandshakeNowPlayingURLKey,
		nil];
	
	return credentials;
}

- (LastDotFMStatus)_status {
	return _status;
}

- (void)_setStatus:(LastDotFMStatus)status {
	if(_status != status) {
		_status = status;
	}
}

- (LastDotFMSubmission*)_submission {
	if(!_submission) {
		id credentials = [self _credentials];
		_submission = [LastDotFMSubmission submissionWithCredentials:credentials];
		
		[_submission setDelegate:self];
	}
	
	return _submission;
}

- (void)_setLastSubmissionDate:(NSDate*)lastSubmissionDate {
	if(_lastSubmissionDate != lastSubmissionDate) {
		_lastSubmissionDate = lastSubmissionDate;
	}
}

- (void)_setLastFailedSubmissionDate:(NSDate*)lastFailedSubmissionDate {
	if(_lastFailedSubmissionDate != lastFailedSubmissionDate) {
		_lastFailedSubmissionDate = lastFailedSubmissionDate;
	}
}

- (void)_scheduleSubmission {
	// Ignore if we don't disabled song submissions at all
	if(![self submissionsEnabled]) {
		return;
	}
	
	if([self isSubmittingSongs]) {
		return; // We currently submit songs
	}
	
	// 050507	Connect even if the song cache is empty, so users aren't confused if they're connected or not
	//			if we are not with Last.fm connected
	if(![self isOnline] || [self _status] == LastDotFMStatusFailedAuthentication) {
		[self performSelector:@selector(_resetHandshake) // Connect with Last.fm
			withObject:nil
			afterDelay:0.0];
		
		return;
	}
	
	// Ignore if we don't cached up songs
	if(IsEmpty(_recentSongs)) {
		return;
	}

	NSTimeInterval interval = 0.0;

	if(_nextPossibleSubmissionDate) {
		interval = [_nextPossibleSubmissionDate timeIntervalSinceNow];
	}
	
	NSTimeInterval submissionAgedInterval = 10.0 * 60.0; // TODO 10 minutes
	
	BOOL lastSubmissionAged = interval < 0.0 && (interval * -1) >= submissionAgedInterval;
	BOOL fullSongCache = [_recentSongs count] >= CSLastDotFMMaxSongCacheSize;
	
	if(lastSubmissionAged || fullSongCache) {
		[self performSelector:@selector(_submitRecentSongs)
			withObject:nil
			afterDelay:MAX(interval, 0.0)];
	}
}

- (void)_submitRecentSongs {
	int countOrMaxNumbersOfSongs = MIN([_recentSongs count], CSLastDotFMMaxNumberOfSubmissionableSongs);
	NSArray* recentSongs = [_recentSongs subarrayWithRange:
		NSMakeRange(0, countOrMaxNumbersOfSongs)];
	
	[[self _submission] submitSongs:recentSongs];
}

- (LastDotFMNowPlayingNotification*)_nowPlayingNotification {
	if(!_nowPlayingNotification) {
		id credentials = [self _credentials];
		_nowPlayingNotification = [LastDotFMNowPlayingNotification nowPlayingNotificationWithCredentials:credentials];
	
		[_nowPlayingNotification setDelegate:self];
	}
	
	return _nowPlayingNotification;
}

- (void)_submitPlayingSong {
	if(![self nowPlayingNotificationsEnabled]) {
		return;
	}
	
	// Cancel any previous notifications
	LastDotFMNowPlayingNotification* nowPlayingNotification = [self _nowPlayingNotification];
	[LastDotFMNowPlayingNotification cancelPreviousPerformRequestsWithTarget:nowPlayingNotification];
	
	// Check if iTunes is still running
	if(![CSiTunesApplication() isRunning]) {
		return;
	}
	
	// Look for the currently playing song
	MusicLibraryTrack* currentTrack = [[[CoverSutra self] nowPlayingController] track];
	
	if(!currentTrack) {
		return;
	}
	
	// Report this song but only if it's not a podcast, movie or tv show
	if(currentTrack.podcast || currentTrack.movie || currentTrack.TVShow) {
		return ;
	}
	
	// Submit the song after 2.0 seconds
	id scrobbleInformation = [self _scrobbleInformationForTrack:currentTrack];
	
	[nowPlayingNotification performSelector:@selector(submitSong:)
		withObject:scrobbleInformation
		afterDelay:2.0];
}

- (NSString*)playerState {
	return _playerState;
}

- (void)setPlayerState:(NSString*)playerState {
	if(!EqualStrings(_playerState, playerState)) {
		_playerState = playerState;

		if(EqualStrings(PlayingPlayerState, playerState)) {
			_timeWhenSongStartedPlaying = [[NSDate alloc] init];
		} else if(EqualStrings(PausedPlayerState, playerState) ||
				  EqualStrings(StoppedPlayerState, playerState)) {
			NSTimeInterval duration = -[_timeWhenSongStartedPlaying timeIntervalSinceNow];
			_timeWhenSongStartedPlaying = nil;
		
			_playDuration += duration;
		}
	}
}

- (void)playerDidChangeTrack:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	
	MusicLibraryTrack* newTrack = [userInfo objectForKey:@"track"];
	MusicLibraryTrack* previousTrack = [userInfo objectForKey:@"previousTrack"];
	
	[self _playerDidChangeTrack:newTrack previousTrack:previousTrack isARepeat:NO];
}

- (void)playerDidRepeatTrack:(NSNotification*)notification {
	NSDictionary* userInfo = [notification userInfo];
	
	MusicLibraryTrack* newTrack = [userInfo objectForKey:@"track"];
	
	[self _playerDidChangeTrack:newTrack previousTrack:newTrack isARepeat:YES];
}

- (void)_playerDidChangeTrack:(MusicLibraryTrack*)newTrack previousTrack:(MusicLibraryTrack*)previousTrack isARepeat:(BOOL)isARepeat {
	// Ignore if we don't do song submissions at all
	if(![self submissionsEnabled]) {
		_playDuration = 0.0;
		_timeWhenSongStartedPlaying = nil;
		
		return;
	}
	
	// Update the playing timestamp	
	if(_timeWhenSongStartedPlaying) {
		_playDuration += -[_timeWhenSongStartedPlaying timeIntervalSinceNow];
		_timeWhenSongStartedPlaying = nil;
	}

	// Reset our playing timestamp if we're still playing
	if(EqualStrings(PlayingPlayerState, [self playerState])) {
		_timeWhenSongStartedPlaying = [[NSDate alloc] init];
	}
	
	// We always check the previous song
	if(!IsEmpty(_nowPlayingURLString) && newTrack && (!EqualTracks(newTrack, previousTrack) || isARepeat) && !newTrack.streamed && !newTrack.podcast && !newTrack.movie && !newTrack.TVShow && !newTrack.storePreview) {
		[self _submitPlayingSong];
	}

	if(!previousTrack) {
		return;
	}
	
	// We don't want internet radio
	if(previousTrack.streamed) {
		return;
	}
	
	// Check if the song really changed, it might be just a update to the current song
	NSTimeInterval playingDurationInSeconds = _playDuration;
	
	if(!EqualTracks(newTrack, previousTrack) || isARepeat) {
		_playDuration = 0.0;
	}
	
	// Song duration needs to be longer than 30 seconds
	NSTimeInterval durationInSeconds = previousTrack.durationInSeconds;
	
	if(durationInSeconds <= 30.0) {
		return;
	}
	
	// Add two seconds playground
	playingDurationInSeconds += 2.0;
	
	if(playingDurationInSeconds < 240.0 && playingDurationInSeconds < durationInSeconds * 0.5) {
		return; // We probably skipped
	}

	// Reset the playing duration since we now scrobble the song
	_playDuration = 0.0;

	// Queue up this song, but only if it's not a podcast or movie
	if(!previousTrack.podcast && !previousTrack.movie && !previousTrack.TVShow && !newTrack.storePreview) {
		id songInfo = [self _scrobbleInformationForTrack:previousTrack];
	
		if(songInfo) {	
			[_recentSongs addObject:songInfo];
			[self _scheduleSubmission];
		}
	}
}

- (void)_applicationWillTerminate:(NSNotification*)notification {
	// Store recent songs and account in user defaults
	// Create lastfm dictionary on demand.
	id lastfm = [[NSUserDefaultsController sharedUserDefaultsController]
		valueForKeyPath:@"values.lastfm"];
	
	if(!lastfm) {
		lastfm = [NSMutableDictionary dictionary];
	}
	
	[lastfm setValue:_recentSongs
		forKey:@"recentSongs"];
	[lastfm setValue:[self account]
		forKey:@"account"];
	[lastfm setValue:[NSNumber numberWithBool:[self submissionsEnabled]]
		forKey:@"submissionsEnabled"];
	[lastfm setValue:[NSNumber numberWithBool:[self nowPlayingNotificationsEnabled]]
		forKey:@"nowPlayingNotificationsEnabled"];
	[lastfm setValue:[self lastSubmissionDate]
		forKey:@"lastSubmissionDate"];
	[lastfm setValue:[self lastFailedSubmissionDate]
		forKey:@"lastFailedSubmissionDate"];
	
	[[NSUserDefaultsController sharedUserDefaultsController]
		setValue:lastfm
		forKeyPath:@"values.lastfm"];
}

- (id)_scrobbleInformationForTrack:(MusicLibraryTrack*)track {
	NSMutableDictionary* scrobbleInfo = [NSMutableDictionary dictionary];
	
	[scrobbleInfo setValue:track.displayName
		forKey:@"title"];
	[scrobbleInfo setValue:track.displayArtist
		forKey:@"artist"];
	[scrobbleInfo setValue:track.displayAlbumArtist
		forKey:@"albumArtist"];
	[scrobbleInfo setValue:track.displayAlbum
		forKey:@"albumTitle"];
	[scrobbleInfo setValue:[NSNumber numberWithInteger:track.trackNumber]
		forKey:@"trackNumber"];
	[scrobbleInfo setValue:[NSNumber numberWithUnsignedInteger:track.durationInSeconds]
		forKey:@"durationInSeconds"];
	[scrobbleInfo setValue:track.location
		forKey:@"location"];
	
	// Set played date
	[scrobbleInfo setValue:[NSDate date]
		forKey:@"playedDate"];
	
	return scrobbleInfo;
}

- (void)_resetHandshake {
	if(_handshake) {
		if([_handshake isHandshaking]) {
			[_handshake cancel];
		}
		
		_handshake = nil;
	}
	
	[self _setStatus:LastDotFMStatusOffline];
	
	if(!IsEmpty([self account]) && !IsEmpty([self password])) {
		[self handshake];
	}
}

- (void)_resetSubmission {
	if(_submission) {
		if([_submission isSubmitting]) {
			[_submission cancel];
		}
		
		_submission = nil;
	}
	
	if(_nowPlayingNotification) {
		if([_nowPlayingNotification isSubmitting]) {
			[_nowPlayingNotification cancel];
		}
		
		_nowPlayingNotification = nil;
	}
	
	[self _setLastSubmissionDate:nil];
	[self _setLastFailedSubmissionDate:nil];
}

- (void)_updateNextPossibleSubmissionDateWithInterval:(int)interval {
	_nextPossibleSubmissionDate = nil;
	
	if(interval > 0) {
		NSDate* nextPossibleSubmissionDate = [NSDate dateWithTimeIntervalSinceNow:interval];
		_nextPossibleSubmissionDate = nextPossibleSubmissionDate;
	}
}

@end
