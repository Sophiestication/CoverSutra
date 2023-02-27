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

#import <Cocoa/Cocoa.h>

@class iTunesPlaylist;

NSString* const StoppedPlayerState;
NSString* const PlayingPlayerState;
NSString* const PausedPlayerState;
NSString* const FastForwardingPlayerState;
NSString* const RewindingPlayerState;

NSString* const PlaybackRepeatModeOff;
NSString* const PlaybackRepeatModeOne;
NSString* const PlaybackRepeatModeAll;

NSString* const CSPlayerDidChangeStateNotification;
NSString* const CSPlayerDidChangePositionNotification;
NSString* const CSPlayerDidChangeSoundVolumeNotification;
NSString* const CSPlayerDidChangePlaylistNotification;
NSString* const CSPlayerDidChangePlaybackModeNotification;

@interface PlaybackController : NSObject {
@private
	NSThread* _refreshThread;

	NSHashTable* _playerPositionObservers;
	NSTimer* _playerPositionRefreshTimer;
	
	NSHashTable* _playerControlsObservers;
	NSTimer* _playerControlsRefreshTimer;
			
	NSInteger _playerPosition;
	NSUInteger _trackDurationInSeconds;
	NSString* _playerState;
	
	NSString* _repeatMode;
	BOOL _shuffle;
	
	BOOL _mute;
	NSInteger _soundVolume;
	
	BOOL _shouldNotUpdatePlayerPosition;
	BOOL _shouldNotNotifyAboutTrackChanges;
	
	BOOL _playable;
	BOOL _rewindable;
	BOOL _skipable;
	BOOL _playpauseWillStop;
	BOOL _shuffleAndRepeatModeChangeable;
	
	BOOL _shouldPlayAfterLaunching;
	
	NSString* _playlistName;
	iTunesPlaylist* _activePlaylist;
	
	BOOL _refreshing;
}

@property(readwrite) NSInteger playerPosition;
@property(readonly) double playerProgress;

@property(readonly, strong) NSString* playerState;

@property(readonly, getter=isPlaying) BOOL playing;
@property(readonly, getter=isPaused) BOOL paused;
@property(readonly, getter=isStopped) BOOL stopped;
@property(readonly, getter=isFastForwarding) BOOL fastForwarding;
@property(readonly, getter=isRewinding) BOOL rewinding;

@property(readwrite, strong) NSString* repeatMode;
@property(readwrite) BOOL shuffle;

@property(readonly, strong) NSString* playlistName;

@property(readwrite, getter=isMuted) BOOL mute;
@property(readwrite) NSInteger soundVolume;

@property(readonly, getter=isPlayable) BOOL playable;
@property(readonly, getter=isRewindable) BOOL rewindable;
@property(readonly, getter=isSkipable) BOOL skipable;

@property(readonly) BOOL playpauseWillStop;
@property(readonly, getter=isShuffleAndRepeatModeChangeable) BOOL shuffleAndRepeatModeChangeable;

- (void)refresh;
- (void)refreshIfNeeded;
- (void)refreshImmediately;

- (void)nextTrack;
- (void)backTrack;

- (void)playpause;

- (void)fastForward;
- (void)rewind;

- (void)resume;

- (void)toggleShuffle;
- (void)toggleRepeatMode;

- (void)increaseSoundVolume;
- (void)decreaseSoundVolume;

- (void)addPlayerControlsObserver:(id)observer;
- (void)removePlayerControlsObserver:(id)observer;

- (void)addPlayerPositionObserver:(id)observer;
- (void)removePlayerPositionObserver:(id)observer;

@end
