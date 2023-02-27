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

#import "SCPlaybackModeBezelViewController.h"

#import "SCBezelImageView.h"
#import "SCBezelTextField.h"
#import "SCBezelLevelIndicator.h"

#import "MusicLibraryTrack.h"

#import "PlaybackController.h"
#import "NowPlayingController.h"
#import "CoverSutra.h"

#import "NSImage+Additions.h"
#import "Utilities.h"

@implementation SCPlaybackModeBezelViewController

+ (SCPlaybackModeBezelViewController*)viewController {
	return [[self alloc] initWithNibName:@"SCPlaybackModeBezelView" bundle:nil];
}

- (void)loadView {
	[super loadView];
	
	// Playback Mode Observer
	id playbackModeBlock = ^(NSNotification* notification) {
		[self updatePlaybackMode];
	};
	
	_playbackModeObserver = [[NSNotificationCenter defaultCenter]
		addObserverForName:CSPlayerDidChangePlaybackModeNotification
		object:nil
		queue:[NSOperationQueue mainQueue]
		usingBlock:playbackModeBlock];
	
	[self updatePlaybackMode];
	
	// Playlist Observer
	id playlistBlock = ^(NSNotification* notification) {
		[self updatePlaylist];
	};
	
	_playlistObserver = [[NSNotificationCenter defaultCenter]
		addObserverForName:CSPlayerDidChangePlaylistNotification
		object:nil
		queue:[NSOperationQueue mainQueue]
		usingBlock:playlistBlock];
	
	[self updatePlaylist];
	
	// ...
//	[[[CoverSutra self] playbackController] addPlayerControlsObserver:self];
}

- (void)viewDidUnload {
	[super viewDidUnload];

	[[NSNotificationCenter defaultCenter] removeObserver:_playbackModeObserver];
	[[NSNotificationCenter defaultCenter] removeObserver:_playlistObserver];
	
	[[[CoverSutra self] playbackController] removePlayerControlsObserver:self];
}

- (void)setShuffleMode {
	if(!_shuffleMode) {
		_shuffleMode = YES;
		[self updatePlaybackMode];
	}
}

- (void)setRepeatMode {
	if(_shuffleMode) {
		_shuffleMode = NO;
		[self updatePlaybackMode];
	}
}

- (void)updatePlaybackMode {
	NSImage* image = nil;
	
	if(_shuffleMode) {
		image = [[[CoverSutra self] playbackController] shuffle] ?
			[NSImage templateImageNamed:ImageNameShuffleTemplate] :
			[NSImage templateImageNamed:ImageNameShuffleOffTemplate];
	} else {
		NSString* repeatMode = [[[CoverSutra self] playbackController] repeatMode];
		
		if([repeatMode isEqualToString:PlaybackRepeatModeOff]) {
			image = [NSImage templateImageNamed:ImageNameRepeatModeOffTemplate];
		} else if([repeatMode isEqualToString:PlaybackRepeatModeOne]) {
			image = [NSImage templateImageNamed:ImageNameRepeatModeOneTemplate];
		} else if([repeatMode isEqualToString:PlaybackRepeatModeAll]) {
			image = [NSImage templateImageNamed:ImageNameRepeatModeAllTemplate];
		}
	}
	
	imageView.image = image;
}

- (void)updatePlaylist {
	titleLabel.text = [[[CoverSutra self] playbackController] playlistName];
}

@end
