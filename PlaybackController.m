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

#import "PlaybackController.h"
#import "PlaybackController+Private.h"

#import "PlayerController.h"

#import "NowPlayingController.h"
#import "NowPlayingController+Private.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "MusicLibrary.h"
#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Scripting.h"

#import "CoverSutra.h"

#import "NSArray+Additions.h"

#import "Utilities.h"

// Several player states
NSString* const StoppedPlayerState = @"Stopped";
NSString* const PlayingPlayerState = @"Playing";
NSString* const PausedPlayerState = @"Paused";
NSString* const FastForwardingPlayerState = @"Fast Forwarding";
NSString* const RewindingPlayerState = @"Rewinding";

// Playback repeat modes
NSString* const PlaybackRepeatModeOff = @"off";
NSString* const PlaybackRepeatModeOne = @"one";
NSString* const PlaybackRepeatModeAll = @"all";

// ...
NSString* const CSPlayerDidChangeStateNotification = @"CSPlayerDidChangeState";
NSString* const CSPlayerDidChangePositionNotification = @"CSPlayerDidChangePosition";
NSString* const CSPlayerDidChangeSoundVolumeNotification = @"CSPlayerDidChangeSoundVolume";
NSString* const CSPlayerDidChangePlaylistNotification = @"CSPlayerDidChangePlaylist";
NSString* const CSPlayerDidChangePlaybackModeNotification = @"CSPlayerDidChangePlaybackMode";

@implementation PlaybackController

@synthesize
	trackDurationInSeconds = _trackDurationInSeconds,
	shouldNotUpdatePlayerPosition = _shouldNotUpdatePlayerPosition,
	shouldNotNotifyAboutTrackChanges = _shouldNotNotifyAboutTrackChanges,
	playlistName = _playlistName,
	playable = _playable,
	rewindable = _rewindable,
	skipable = _skipable,
	playpauseWillStop = _playpauseWillStop,
	shuffleAndRepeatModeChangeable = _shuffleAndRepeatModeChangeable,
	shouldPlayAfterLaunching = _shouldPlayAfterLaunching,
	activePlaylist = _activePlaylist,
	refreshing = _refreshing;

@dynamic playerState;
@dynamic repeatMode;
@dynamic shuffle;
@dynamic mute;
@dynamic soundVolume;
	
@dynamic playerPosition;

@dynamic playerProgress;
@dynamic iTunesIsAvailable;

+ (NSSet*)keyPathsForValuesAffectingPlaying { return [NSSet setWithObject:@"playerState"]; }
+ (NSSet*)keyPathsForValuesAffectingPaused { return [NSSet setWithObject:@"playerState"]; }
+ (NSSet*)keyPathsForValuesAffectingStopped { return [NSSet setWithObject:@"playerState"]; }
+ (NSSet*)keyPathsForValuesAffectingFastForwarding { return [NSSet setWithObject:@"playerState"]; }
+ (NSSet*)keyPathsForValuesAffectingRewinding { return [NSSet setWithObject:@"playerState"]; }
+ (NSSet*)keyPathsForValuesAffectingPlayerProgress { return [NSSet setWithObjects:@"playerPosition", @"trackDurationInSeconds", nil]; }

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_refreshing = NO;
	
	_shouldNotUpdatePlayerPosition = NO;
	_shouldNotNotifyAboutTrackChanges = NO;
	
	_shouldPlayAfterLaunching = NO;
	
	_playerPosition = -1;
	_trackDurationInSeconds = 0;
	_playerState = StoppedPlayerState;
	
	_shuffle = NO;
	_repeatMode = PlaybackRepeatModeOff;
	
	_mute = NO;
	_soundVolume = 0;

	_playerPositionObservers = [NSHashTable weakObjectsHashTable];
	_playerControlsObservers = [NSHashTable weakObjectsHashTable];
	
	[[NSDistributedNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_playerInfoDidChange:)
		name:@"com.apple.iTunes.playerInfo"
		object:@"com.apple.iTunes.player"
		suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
		
	[[NSDistributedNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(spotifyPlaybackDidChange:)
		name:@"com.spotify.client.PlaybackStateChanged"
		object:nil
		suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
			
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_iTunesWillFinishLaunching:)
		name:iTunesWillFinishLaunchingNotification
		object:nil];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_iTunesDidTerminate:)
		name:iTunesDidTerminateNotification
		object:nil];
		
	[self bind:@"trackDurationInSeconds"
		toObject:[CoverSutra self]
		withKeyPath:@"nowPlayingController.track.durationInSeconds"
		options:nil];
		
	// Retrieve initial player state
	if([CSiTunesApplication() isRunning]) {
		// _playerState = [CSiTunesApplication() playerState2];
		
		[self performSelectorInBackground:@selector(refreshIfNeeded)
			withObject:nil];
	}
	
	// Start updates if needed
	[self performSelector:@selector(startUpdatesIfNeeded)
		withObject:nil
		afterDelay:0.0];

	return self;
}

- (NSInteger)playerPosition {
	return _playerPosition;
}

- (void)setPlayerPosition:(NSInteger)playerPosition {
	if(_playerPosition != playerPosition) {
		_playerPosition = playerPosition;

		[[NSNotificationCenter defaultCenter]
			postNotificationName:CSPlayerDidChangePositionNotification
			object:self
			userInfo:nil];

		if(!self.refreshing && [NSThread currentThread] != _refreshThread) {
			[CSiTunesApplication() setPlayerPosition:playerPosition];
		}
	}
}

- (double)playerProgress {
	return MIN(MAX((double)self.playerPosition / (double)self.trackDurationInSeconds, 0.0), 1.0);
}

- (NSString*)playerState {
	return _playerState;
}

- (void)setPlayerState:(NSString*)playerState {
	if(!EqualStrings(playerState, [self playerState])) {
		_playerState = playerState;
		
		[[NSNotificationCenter defaultCenter]
			postNotificationName:CSPlayerDidChangeStateNotification
			object:self
			userInfo:nil];
	}
}

- (BOOL)isPlaying {
	return EqualStrings(PlayingPlayerState, self.playerState);
}

- (BOOL)isPaused {
	return EqualStrings(PausedPlayerState, self.playerState);
}

- (BOOL)isStopped {
	return EqualStrings(StoppedPlayerState, self.playerState);
}

- (BOOL)isFastForwarding {
	return EqualStrings(FastForwardingPlayerState, self.playerState);
}

- (BOOL)isRewinding {
	return EqualStrings(RewindingPlayerState, self.playerState);
}

- (NSString*)repeatMode {
	return _repeatMode;
}

- (void)setRepeatMode:(NSString*)repeatMode {
	if(!EqualStrings(repeatMode, _repeatMode)) {
		_repeatMode = repeatMode;
		
		[[NSNotificationCenter defaultCenter]
			postNotificationName:CSPlayerDidChangePlaybackModeNotification
			object:self
			userInfo:nil];
		
		if(!self.refreshing && [NSThread currentThread] != _refreshThread) {
			iTunesERpt songRepeat = iTunesERptOff;
		
			if(EqualStrings(PlaybackRepeatModeOne, repeatMode)) {
				songRepeat = iTunesERptOne;
			}
		
			if(EqualStrings(PlaybackRepeatModeAll, repeatMode)) {
				songRepeat = iTunesERptAll;
			}

			[[self _activePlaylistScriptingObject] setSongRepeat:songRepeat];
		}
	}
}

- (BOOL)shuffle {
	return _shuffle;
}

- (void)setShuffle:(BOOL)shuffle {
	if(_shuffle != shuffle) {
		_shuffle = shuffle;
		
		[[NSNotificationCenter defaultCenter]
			postNotificationName:CSPlayerDidChangePlaybackModeNotification
			object:self
			userInfo:nil];
		
		if(!self.refreshing && [NSThread currentThread] != _refreshThread) {
			[[self _activePlaylistScriptingObject] setShuffle:shuffle];
		}
	}
}

- (BOOL)isMuted {
	return _mute;
}

- (void)setMute:(BOOL)mute {
	if(_mute != mute) {
		_mute = mute;
		
		[[NSNotificationCenter defaultCenter]
			postNotificationName:CSPlayerDidChangeSoundVolumeNotification
			object:self
			userInfo:nil];
		
		if(!self.refreshing && [NSThread currentThread] != _refreshThread) {
			[CSiTunesApplication() setMute:mute];
		}
	}
}

- (NSInteger)soundVolume {
	return _soundVolume;
}

- (void)setSoundVolume:(NSInteger)soundVolume {
	if(_soundVolume != soundVolume) {
		_soundVolume = soundVolume;
		
		[[NSNotificationCenter defaultCenter]
			postNotificationName:CSPlayerDidChangeSoundVolumeNotification
			object:self
			userInfo:nil];
		
		if(!self.refreshing && [NSThread currentThread] != _refreshThread) {
			self.mute = NO;
			[CSiTunesApplication() setSoundVolume:soundVolume];
		}
	}
}

- (void)refresh {
	@autoreleasepool {

		NS_DURING
			[self refreshPlayerPosition:nil];
			[self refreshPlayerControls:nil];
		NS_HANDLER
		NS_ENDHANDLER
	
	}
}

- (void)refreshIfNeeded {
	if(!_refreshThread) {
		[self refreshImmediately];
	}
}

- (void)refreshImmediately {
	self.refreshing = YES;
	[self refresh];
	self.refreshing = NO;
}

- (void)playpause {
	iTunesApplication* application = CSiTunesApplication();

	if(application.playerState == iTunesEPlSPlaying) {
		[application pause];
		self.playerState = PausedPlayerState;
	} else {
		if([[application currentTrack] exists]) {
			[[application currentTrack] playOnce:NO];
		} else {
			[application playpause];
		}
		
		self.playerState = PlayingPlayerState;

		[[[CoverSutra self] nowPlayingController] refreshIfNeeded];
	}
}

- (void)nextTrack {
	// Check if iTunes is available for playback
	if(!self.iTunesIsAvailable) {
		return;
	}
	
	// Resume playback if needed
	if(self.fastForwarding || self.rewinding) {
		[self resume];
	}

	// Skip to the next track
	self.shouldNotNotifyAboutTrackChanges = YES;
	[CSiTunesApplication() nextTrack];
	
	[self refreshImmediately];
	[[[CoverSutra self] nowPlayingController] refreshIfNeeded];
}

- (void)backTrack {
	// Check if iTunes is available for playback
	if(!self.iTunesIsAvailable) {
		return;
	}
	
	// Resume playback if needed
	if(self.fastForwarding || self.rewinding) {
		[self resume];
	}

	self.shouldNotNotifyAboutTrackChanges = YES;
	[CSiTunesApplication() backTrack];
	
	[self refreshImmediately];
	[[[CoverSutra self] nowPlayingController] refreshIfNeeded];
}

- (void)fastForward {
	// Check if iTunes is available for playback
	if(!self.iTunesIsAvailable) {
		return;
	}
	
	// Fast forward
	[CSiTunesApplication() fastForward];
	self.playerState = FastForwardingPlayerState;
}

- (void)rewind {
	// Check if iTunes is available for playback
	if(!self.iTunesIsAvailable) {
		return;
	}
	
	// Rewind
	[CSiTunesApplication() rewind];
	self.playerState = RewindingPlayerState;
}

- (void)resume {
	// Check if iTunes is available for playback
	if(!self.iTunesIsAvailable) {
		return;
	}

	[CSiTunesApplication() resume];
	self.playerState = [CSiTunesApplication() playerState2];
}

- (void)toggleShuffle {
	if(!self.iTunesIsAvailable) {
		return; // This operation is currently not allowed
	}

	self.shuffle = !self.shuffle;
}

- (void)toggleRepeatMode {
	if(!self.iTunesIsAvailable) {
		return; // This operation is currently not allowed
	}

	NSString* repeatMode = self.repeatMode;
	
	if(EqualStrings(PlaybackRepeatModeOff, repeatMode)) {
		self.repeatMode = PlaybackRepeatModeAll;
	} else if(EqualStrings(PlaybackRepeatModeAll, repeatMode)) {
		self.repeatMode = PlaybackRepeatModeOne;
	} else if(EqualStrings(PlaybackRepeatModeOne, repeatMode)) {
		self.repeatMode = PlaybackRepeatModeOff;
	}
}

- (void)increaseSoundVolume {
	if(!self.iTunesIsAvailable) {
		return; // This operation is currently not allowed
	}
	
	NSInteger currentSoundVolume = [CSiTunesApplication() soundVolume];
	
	CGFloat smallestSoundLevel = rintf(100.0 / 16.0); // Use a different value if we use iPhone styled bezels
	CGFloat soundLevel = rintf(currentSoundVolume / smallestSoundLevel) + 1.0;
	
	soundLevel = MIN(MAX(soundLevel, 0.0), 16.0);
	
	if(self.mute) {
		soundLevel = 1;
	}
	
	self.soundVolume = MIN(soundLevel * smallestSoundLevel, 100);
	self.mute = NO;
}

- (void)decreaseSoundVolume {
	if(!self.iTunesIsAvailable) {
		return; // This operation is currently not allowed
	}
	
	NSInteger currentSoundVolume = [CSiTunesApplication() soundVolume];

	CGFloat smallestSoundLevel = rintf(100.0 / 16.0); // Use a different value if we use iPhone styled bezels
	CGFloat soundLevel = rintf(currentSoundVolume / smallestSoundLevel) - 1.0;
	
	soundLevel = MIN(MAX(soundLevel, 0.0), 16.0);
	
	if(self.mute) {
		soundLevel = 0;
	}
	
	self.soundVolume = MAX(soundLevel * smallestSoundLevel, 0);
	self.mute = NO;
}

- (void)addPlayerPositionObserver:(id)observer {
	if(![_playerPositionObservers containsObject:observer]) {
		[_playerPositionObservers addObject:observer];
		[self startUpdatesIfNeeded];
	}
}

- (void)removePlayerPositionObserver:(id)observer {
	[_playerPositionObservers removeObject:observer];
	[self stopUpdatesIfNeeded];
}

- (void)addPlayerControlsObserver:(id)observer {
	if(![_playerControlsObservers containsObject:observer]) {
		[_playerControlsObservers addObject:observer];
		[self startUpdatesIfNeeded];
	}
}

- (void)removePlayerControlsObserver:(id)observer {
	[_playerControlsObservers removeObject:observer];
	[self stopUpdatesIfNeeded];
}

- (void)startUpdatesIfNeeded {
	if(_playerPositionObservers.count == 0 && _playerControlsObservers.count == 0) {
		return;
	}
	
	if(_refreshThread) {
		if(!_playerPositionRefreshTimer && _playerPositionObservers.count > 0) {
			[self performSelector:@selector(schedulePlayerPositionRefresh)
				onThread:_refreshThread
				withObject:nil
				waitUntilDone:NO];
		}
		
		if(!_playerControlsRefreshTimer && _playerControlsObservers.count > 0) {
			[self performSelector:@selector(schedulePlayerControlsRefresh)
				onThread:_refreshThread
				withObject:nil
				waitUntilDone:NO];
		}
		
		return;
	}
	
	// Stop updates if iTunes is not running
	if(![[[CoverSutra self] playerController] iTunesIsRunning]) {
		[self refreshImmediately];
		return;
	}
	
	// Start a new refresh thread
	NSThread* refreshThread = [[NSThread alloc] initWithTarget:self
		selector:@selector(_refreshOperation:)
		object:nil];
	
	_refreshThread = refreshThread;

	[refreshThread start];
}

- (void)stopUpdatesIfNeeded {
	if(_playerPositionObservers.count <= 0 && _playerControlsObservers.count <= 0) {
		[self stopUpdates];
	}
}

- (void)stopUpdates {
	if(_refreshThread) {
		[self performSelector:@selector(_cancelRefreshOperation:)
			onThread:_refreshThread
			withObject:nil
			waitUntilDone:NO];
	}
}

- (void)schedulePlayerPositionRefresh {
	if(!_playerPositionRefreshTimer && _playerPositionObservers.count > 0) {
		_playerPositionRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 3.0
			target:self
			selector:@selector(refreshPlayerPosition:)
			userInfo:nil
			repeats:YES];
		
		[self refreshPlayerPosition:nil];
	}
}

- (void)refreshPlayerPosition:(id)sender {
	if(self.shouldNotUpdatePlayerPosition) {
		return;
	}

	if(!self.iTunesIsAvailable) {
		return;
	}

	// Update player position
	NSInteger playerPosition = 0;
	iTunesApplication* application = CSiTunesApplication();

	if([application isRunning]) {
		 playerPosition = [application playerPosition];
	}

	if(!self.shouldNotUpdatePlayerPosition) {
		[self performSelectorOnMainThread:@selector(_setPlayerPositionFromAutomaticUpdate:)
			withObject:[NSNumber numberWithInteger:playerPosition]
			waitUntilDone:NO];			
	}
	
	// Update player state
	if([application isRunning]) {
		NSString* playerState = [application playerState2];
		self.playerState = playerState;
	}
}

- (void)schedulePlayerControlsRefresh {
	if(!_playerControlsRefreshTimer && _playerControlsObservers.count > 0) {
		_playerControlsRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
			target:self
			selector:@selector(refreshPlayerControls:)
			userInfo:nil
			repeats:YES];
		
		[self refreshPlayerControls:nil];
	}
}

- (void)refreshPlayerControls:(id)sender {
	iTunesApplication* application = CSiTunesApplication();
	
	if(![application isRunning]) {
		self.shuffle = NO;
		self.repeatMode = PlaybackRepeatModeOff;
		
		self.activePlaylist = nil;
		self.playlistName = nil;
		
		self.playable = NO;
		self.shuffleAndRepeatModeChangeable = NO;
		self.rewindable = NO;
		self.skipable = NO;
	
		self.playerState = StoppedPlayerState;
		self.playerPosition = -1;
		
		return;
	}
	
	if(!self.iTunesIsAvailable) {
		self.playable = NO;
		self.shuffleAndRepeatModeChangeable = NO;
		self.rewindable = NO;
		self.skipable = NO;
		
		return; // TODO
	}
	
	NSDictionary* playlistScriptingObjects =  [self _playlistScriptingObjects];
	
	iTunesPlaylist* selectedPlaylist = [playlistScriptingObjects objectForKey:@"selectedPlaylist"];
	iTunesPlaylist* currentPlaylist = [playlistScriptingObjects objectForKey:@"currentPlaylist"];
	
	iTunesPlaylist* playlist = currentPlaylist ? currentPlaylist : selectedPlaylist;
	
	// Update player state
	self.playerState = [application playerState2];
	
	// Update shuffle state
	self.shuffle = playlist.shuffle;

	// Update repeat mode
	iTunesERpt songRepeat = playlist.songRepeat;
	NSString* repeatMode = PlaybackRepeatModeOff;
	
	if(songRepeat == iTunesERptOne) {
		repeatMode = PlaybackRepeatModeOne;
	}
	
	if(songRepeat == iTunesERptAll) {
		repeatMode = PlaybackRepeatModeAll;
	}
	
	self.repeatMode = repeatMode;
	
	// Update our standard player controls states
	BOOL playlistIsEmpty = playlist.tracks.count == 0;
	self.playable = playlist && !playlistIsEmpty;
	
	BOOL playlistsAreEqual = EqualStrings(selectedPlaylist.persistentID, currentPlaylist.persistentID);
	
//	self.playpauseWillStop = !playlistsAreEqual;
	self.playpauseWillStop = NO;
	
	BOOL currentTrackIsStreamed = [[[[CoverSutra self] nowPlayingController] track] isStreamed];
	self.playpauseWillStop = currentTrackIsStreamed;
	
	if(!playlist || !currentPlaylist || playlistIsEmpty || (!playlistsAreEqual && self.paused)) {
		self.rewindable = self.skipable = NO;
	} else if(EqualStrings(PlaybackRepeatModeOff, repeatMode) && !self.playing) {
		NSString* currentTrackPersistentID = [[CSiTunesApplication() currentTrack] persistentID];
			
		self.rewindable = self.playerPosition >= 3 || ![currentTrackPersistentID isEqual:[currentPlaylist.tracks.firstObject persistentID]];
		self.skipable = ![currentTrackPersistentID isEqual:[currentPlaylist.tracks.lastObject persistentID]];
	} else {
		self.rewindable = self.skipable = YES;
	}

	// See if we can alter the shuffle and repeat mode
	BOOL shuffleAndRepeatModeChangeable = NO;
	
	if(playlist) {
		iTunesESpK specialKind = playlist.specialKind;
	
		if(specialKind == iTunesESpKNone || specialKind == iTunesESpKFolder || specialKind == iTunesESpKPurchasedMusic || specialKind == iTunesESpKMusic) {
			shuffleAndRepeatModeChangeable = YES;
		}
	}

	self.shuffleAndRepeatModeChangeable = shuffleAndRepeatModeChangeable;
	
	// Check if our now playing track is still valid
	if(!currentPlaylist && [[[CoverSutra self] nowPlayingController] track]) {
		// We need to refresh
		[[[CoverSutra self] nowPlayingController] refreshIfNeeded];
	}
	
	// Set our new playlist scripting object
	self.activePlaylist = playlist;
	self.playlistName = playlist.name;
	
	[[NSNotificationCenter defaultCenter]
		postNotificationName:CSPlayerDidChangePlaylistNotification
		object:self
		userInfo:nil];
	
	// Refresh sound volume
	self.mute = [application mute];
	self.soundVolume = [application soundVolume];
}

- (void)_refreshOperation:(id)sender {
//	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	
	[self schedulePlayerPositionRefresh];
	[self schedulePlayerControlsRefresh];
	
	while(![[NSThread currentThread] isCancelled]) {
		BOOL keepRunning = [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]; // Wait for input events
	
		if(!keepRunning) {
			break;
		}
		
//		[pool drain], pool = [[NSAutoreleasePool alloc] init];
	}
	
//	[pool drain];
}

- (void)_cancelRefreshOperation:(id)sender {
//	[_refreshThread cancel]; [_refreshThread release], _refreshThread = nil;

	[_playerPositionRefreshTimer invalidate], _playerPositionRefreshTimer = nil;
	[_playerControlsRefreshTimer invalidate], _playerControlsRefreshTimer = nil;
}

/*
- (void)setShouldNotUpdatePlayerPosition:(BOOL)shouldNotUpdatePlayerPosition {
	if(shouldNotUpdatePlayerPosition != _shouldNotUpdatePlayerPosition) {
		_shouldNotUpdatePlayerPosition = shouldNotUpdatePlayerPosition;
		
		[[self class] cancelPreviousPerformRequestsWithTarget:
		 
		 
		 + (void)cancelPreviousPerformRequestsWithTarget:(id)aTarget selector:(SEL)aSelector object:(id)anArgument
	}
}
*/

- (void)_setPlayerPositionFromAutomaticUpdate:(NSNumber*)playerPosition {
	if(_playerPosition != [playerPosition integerValue]) {
		if(!self.shouldNotUpdatePlayerPosition) {
			[self willChangeValueForKey:@"playerPosition"];
			_playerPosition = [playerPosition integerValue];
			[self didChangeValueForKey:@"playerPosition"];
			
			[[NSNotificationCenter defaultCenter]
				postNotificationName:CSPlayerDidChangePositionNotification
				object:self
				userInfo:nil];
		}
	}
	
//	NSLog(@"auto: %i", [playerPosition integerValue]);
}

- (BOOL)iTunesIsAvailable {
	PlayerController* playerController = [[CoverSutra self] playerController];
	return playerController.iTunesIsRunning && !playerController.iTunesIsBusy;
}

- (iTunesPlaylist*)_activePlaylistScriptingObject {
	if(![[[CoverSutra self] playerController] iTunesIsRunning]) {
		return nil;
	}

	// Check if we already have a track with an attached playlist scripting object
	MusicLibraryTrack* currentTrack = [[[CoverSutra self] nowPlayingController] track];

	if([currentTrack respondsToSelector:@selector(playlistScriptingObject)]) {
		return [currentTrack performSelector:@selector(playlistScriptingObject)];
	}
	
	iTunesApplication* application = CSiTunesApplication();
	
	// Check for the currently playing playlist
	iTunesPlaylist* currentPlaylist = [[application currentPlaylist] get];
	
	if(currentPlaylist) {
		return currentPlaylist;
	}
	
	// Try the selected playlist
	iTunesPlaylist* selectedPlaylist = [[application selectedPlaylist] get];
	
	if(selectedPlaylist) {
		return selectedPlaylist;
	}
	
	return nil;
}

- (NSDictionary*)_playlistScriptingObjects {
	NSMutableDictionary* playlistScriptingObjects = [NSMutableDictionary dictionary];
	
	if(![[[CoverSutra self] playerController] iTunesIsRunning]) {
		return playlistScriptingObjects;
	}
	
	// Check if we already have a track with an attached playlist scripting object
	iTunesPlaylist* currentPlaylist = nil;
	iTunesApplication* application = CSiTunesApplication();
	
	// Check for the currently playing playlist
//	if([[application currentPlaylist] exists]) {
		currentPlaylist = [[application currentPlaylist] get];
//	}
	
	if(currentPlaylist) {
		[playlistScriptingObjects setObject:currentPlaylist forKey:@"currentPlaylist"];
	}
	
	// Try the selected playlist
	iTunesPlaylist* selectedPlaylist = nil;
	
//	if([[application selectedPlaylist] exists]) {
		selectedPlaylist = [[application selectedPlaylist] get];
//	}

	if(selectedPlaylist) {
		[playlistScriptingObjects setObject:selectedPlaylist forKey:@"selectedPlaylist"];
	}
	
	return playlistScriptingObjects;
}

- (void)_playerInfoDidChange:(NSNotification*)notification {
	NSDictionary* playerInfo = [notification userInfo];
	
	// Check for new player state
	NSString* playerState = [playerInfo objectForKey:@"Player State"];
	
	if(!EqualStrings(self.playerState, playerState)) {
		self.playerState = playerState ? playerState : StoppedPlayerState;
		
		if(!self.stopped) {
			// Refresh immediatly
			[self refreshImmediately];
		}
	}
}

- (void)spotifyPlaybackDidChange:(NSNotification*)notification {
	[self _playerInfoDidChange:notification];
}

- (void)_iTunesWillFinishLaunching:(NSNotification*)notification {
	// Start automatic updates if needed
	[self startUpdatesIfNeeded];
	
	// Play if needed
	if(self.shouldPlayAfterLaunching) {
		self.shouldPlayAfterLaunching = NO;
		[self playpause];
	}
}

- (void)_iTunesDidTerminate:(NSNotification*)notification {
	// Stop automtic updates
	[self stopUpdates];
}

@end
