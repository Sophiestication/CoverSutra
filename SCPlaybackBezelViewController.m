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

#import "SCPlaybackBezelViewController.h"

#import "SCBezelImageView.h"
#import "SCBezelTextField.h"
#import "SCBezelLevelIndicator.h"

#import "MusicLibraryTrack.h"

#import "Skin.h"

#import "PlaybackController.h"
#import "NowPlayingController.h"
#import "CoverSutra.h"

#import "NSImage+Additions.h"
#import "Utilities.h"

@implementation SCPlaybackBezelViewController

+ (SCPlaybackBezelViewController*)viewController {
	return [[self alloc] initWithNibName:@"SCPlaybackBezelView" bundle:nil];
}

- (void)loadView {
	[super loadView];
	
	// ...
	[self setScrubbingMode:NO];
	_playbackImageRect = playbackImageView.frame;
	
//	playbackImageView.opacity = 0.8;
	
	// Player State Observer
	id playerStateBlock = ^(NSNotification* notification) {
		[self updatePlayerState];
	};
	
	_playerStateObserver = [[NSNotificationCenter defaultCenter]
		addObserverForName:CSPlayerDidChangeStateNotification
		object:nil
		queue:[NSOperationQueue mainQueue]
		usingBlock:playerStateBlock];
	
	[self updatePlayerState];
		
	// Player Position Observer
	id playerPositionBlock = ^(NSNotification* notification) {
		[self updatePlayerPosition];
	};
	
	_playerPositionObserver = [[NSNotificationCenter defaultCenter]
		addObserverForName:CSPlayerDidChangePositionNotification
		object:nil
		queue:[NSOperationQueue mainQueue]
		usingBlock:playerPositionBlock];
	
	[self updatePlayerPosition];
	
	// Current Track Observer
	id nowPlayingBlock = ^(NSNotification* notification) {
		[self updateCurrentTrack];
	};
	
	_nowPlayingObserver = [[NSNotificationCenter defaultCenter]
		addObserverForName:PlayerDidChangeTrackNotification
		object:nil
		queue:[NSOperationQueue mainQueue]
		usingBlock:nowPlayingBlock];
	
	[self updateCurrentTrack];
	
	// Current Album Cover Observer
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"playbackBezelCoverShown"]) {
		id albumCoverBlock = ^(NSNotification* notification) {
			[self updateCurrentAlbumCover];
		};
		
		_albumCoverObserver = [[NSNotificationCenter defaultCenter]
			addObserverForName:PlayerDidChangeCoverNotification
			object:nil
			queue:[NSOperationQueue mainQueue]
			usingBlock:albumCoverBlock];
	
		[self updateCurrentAlbumCover];
	}

	// Keep track of player state and position
	[[[CoverSutra self] playbackController] addPlayerPositionObserver:self];
	[[[CoverSutra self] playbackController] addPlayerControlsObserver:self];
}

- (void)viewDidUnload {
	[super viewDidUnload];

	[[NSNotificationCenter defaultCenter] removeObserver:_playerStateObserver];
	_playerStateObserver = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:_playerPositionObserver];
	_playerPositionObserver = nil;
	
	[[NSNotificationCenter defaultCenter] removeObserver:_nowPlayingObserver];
	_nowPlayingObserver = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:_albumCoverObserver];
	_albumCoverObserver = nil;

	[[[CoverSutra self] playbackController] removePlayerPositionObserver:self];
	[[[CoverSutra self] playbackController] removePlayerControlsObserver:self];
}

- (void)setScrubbingMode:(BOOL)scrubbing {
	[titleLabel setHidden:scrubbing];
	[otherTitleLabel setHidden:!scrubbing];
	[progressIndicator setHidden:!scrubbing];
}

- (void)didSkip {
	SCBezelImageView* imageView = YES ?
		[playbackImageView animator] :
		playbackImageView;
	imageView.image = [NSImage templateImageNamed:ImageNameFastForwardTemplate];
}

- (void)didRewind {
	SCBezelImageView* imageView = YES ?
		[playbackImageView animator] :
		playbackImageView;
	imageView.image = [NSImage templateImageNamed:ImageNameRewindTemplate];
}

- (void)updatePlayerState {
	NSString* playerState = [[[CoverSutra self] playbackController] playerState];
		
	SCBezelImageView* imageView = YES ?
		[playbackImageView animator] :
		playbackImageView;
	
	if(EqualStrings(playerState, PlayingPlayerState)) {
		imageView.image = [NSImage templateImageNamed:ImageNamePlayTemplate];
		[self setScrubbingMode:NO];
	} else if(EqualStrings(playerState, PausedPlayerState)) {
		imageView.image = [NSImage templateImageNamed:ImageNamePauseTemplate];
		[self setScrubbingMode:NO];
	} else if(EqualStrings(playerState, RewindingPlayerState)) {
		imageView.image = [NSImage templateImageNamed:ImageNameRewindTemplate];
		[self setScrubbingMode:YES];
	} else if(EqualStrings(playerState, FastForwardingPlayerState)) {
		imageView.image = [NSImage templateImageNamed:ImageNameFastForwardTemplate];
		[self setScrubbingMode:YES];
	} else if(EqualStrings(playerState, StoppedPlayerState)) {
//		imageView.image = [NSImage templateImageNamed:ImageNameStopTemplate];
	}
}

- (void)updatePlayerPosition {
	float playerProgress = [[[CoverSutra self] playbackController] playerProgress];
	progressIndicator.value = playerProgress;
}

- (void)updateCurrentTrack {
	MusicLibraryTrack* currentTrack = [[[CoverSutra self] nowPlayingController] track];
	
	titleLabel.text = currentTrack.displayName;
	otherTitleLabel.text = currentTrack.displayName;
}

- (void)updateCurrentAlbumCover {
	NSImage* coverImage = [[[CoverSutra self] nowPlayingController] smallAlbumCaseImage];

	if(coverImage) {
		coverView.image = coverImage;
		[coverView setHidden:NO];

		NSRect coverViewRect = self.view.bounds;
		
		CGFloat playbackImageSize = 76.0;
		NSRect playbackImageRect = NSMakeRect(
			floorf(NSMidX(coverViewRect) - playbackImageSize * 0.5),
			floorf(NSMidY(coverViewRect) - playbackImageSize * 0.5),
			playbackImageSize,
			playbackImageSize);
		
		Skin* skin = [[[CoverSutra self] nowPlayingController] skin];
		NSValue* alignmentRectValue = [[skin caseDescriptionOfSkinSize:SmallSkinSize]
			objectForKey:SkinCaseAlignmentRectKey];
			
		if(alignmentRectValue) {
			NSRect alignmentRect = [alignmentRectValue rectValue];
			playbackImageRect = NSOffsetRect(playbackImageRect, -NSMinX(alignmentRect), -NSMinY(alignmentRect));
		}
		
		playbackImageView.frame = playbackImageRect;
	} else {
		coverView.image = nil;
		[coverView setHidden:YES];
		
		playbackImageView.frame = _playbackImageRect;
	}
}

@end
