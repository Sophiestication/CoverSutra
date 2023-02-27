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

@class iTunesPlaylist;

/*!
    @category	 PlaybackController()
    @abstract    <#(brief description)#>
    @discussion  <#(comprehensive description)#>
*/
@interface PlaybackController()

@property(readwrite, strong) NSString* playerState;
@property(readwrite) NSUInteger trackDurationInSeconds;

@property(readwrite) BOOL shouldNotUpdatePlayerPosition;
@property(readwrite) BOOL shouldNotNotifyAboutTrackChanges;

@property(readwrite) BOOL playable;
@property(readwrite) BOOL rewindable;
@property(readwrite) BOOL skipable;
@property(readwrite) BOOL playpauseWillStop;
@property(readwrite) BOOL shuffleAndRepeatModeChangeable;

@property(readwrite) BOOL shouldPlayAfterLaunching;

@property(readwrite, strong) NSString* playlistName;

@property(readwrite, strong) iTunesPlaylist* activePlaylist;

@property(readonly) BOOL iTunesIsAvailable;

@property(readwrite, getter=isRefreshing) BOOL refreshing;

- (iTunesPlaylist*)_activePlaylistScriptingObject;
- (NSDictionary*)_playlistScriptingObjects;

- (void)startUpdatesIfNeeded;

- (void)stopUpdatesIfNeeded;
- (void)stopUpdates;

- (void)schedulePlayerPositionRefresh;
- (void)refreshPlayerPosition:(id)sender;

- (void)schedulePlayerControlsRefresh;
- (void)refreshPlayerControls:(id)sender;

- (void)_refreshOperation:(id)sender;
- (void)_cancelRefreshOperation:(id)sender;

- (void)_setPlayerPositionFromAutomaticUpdate:(NSNumber*)playerPosition;

- (void)_playerInfoDidChange:(NSNotification*)notification;

- (void)_iTunesWillFinishLaunching:(NSNotification*)notification;
- (void)_iTunesDidTerminate:(NSNotification*)notification;

@end
