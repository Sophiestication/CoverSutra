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

#import <Carbon/Carbon.h>

#import "ApplicationWindowController.h"
#import "ApplicationWindowController+Private.h"

#import "CoverSutra.h"
#import "CoverSutra+Shortcuts.h"

#import "PlaybackController.h"
#import "PlayerController.h"
#import "NowPlayingController.h"

#import "MusicLibraryPlaylist.h"

#import "PlayerPositionSlider.h"
#import "StarRatingControl.h"
#import "CoverView.h"

#import "SegmentedControl.h"
#import "Slider.h"

#import "NSMenu+Additions.h"
#import "NSString+Additions.h"
#import "NSShadow+Additions.h"

@implementation ApplicationWindowController

+ (ApplicationWindowController*)applicationWindowController {
	return [[self alloc] initWithWindowNibName:@"ApplicationWindow"];
}

- (BOOL)condensedLayout {
	return _condensedLayout;
}

- (void)setCondensedLayout:(BOOL)condensedLayout {
	_condensedLayout = condensedLayout;
}

- (void)windowWillLoad {
	[super windowWillLoad];
	
	_condensedLayout = NO;
}

- (void)windowDidLoad {
    [super windowDidLoad];
	
    NSWindow* window = [self window];
	
	// Setup bezel window
	[window setOpaque:NO];
    [window setAlphaValue:0.0];
    
    [window useOptimizedDrawing:YES];
    [window setAutodisplay:YES];

    [window setHidesOnDeactivate:NO];
    [window setCanHide:NO];
    
    [window setIgnoresMouseEvents:NO];
    [window setMovable:YES];

	[window setLevel:kCGStatusWindowLevel];
	[window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorStationary|NSWindowCollectionBehaviorFullScreenAuxiliary];
    
    [window setOneShot:YES];
    
    [window setFrame:NSMakeRect(0.0, 0.0, 480.0, 226.0) display:NO];
	[window center];
	
    [self setShouldCascadeWindows:NO];
    
	// Setup the custom close button
	NSButton* closeButton = [window standardWindowButton:NSWindowCloseButton];
	
	[closeButton setTarget:self];
	[closeButton setAction:@selector(orderOut:)];
	
	// Setup cover view
	[coverView bind:@"image"
		toObject:[CoverSutra self]
		withKeyPath:@"nowPlayingController.mediumAlbumCaseImage"
		options:nil];
		
	// Setup "Is Not Running" button
	[self _initAlert];
	
	// Player controls stuff
	[self _initPlayerControls];
	[self _initPlaylistControls];
	[self _initSoundVolumeControls];
	[self _initActionButton];
	
	// Setup track labels
	[self _initTrackLabels];
	
	[self _updatePlayerButtons];
	[self _updateShuffleButtons];
	[self _updateSongRepeatButtons];
	[self _updateSoundVolumeButtons];
	[self _updatePlayerInfo];
	
	[[CoverSutra self] addObserver:self
		forKeyPath:@"playbackController.playerState"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
						   context:NULL];
	[[CoverSutra self] addObserver:self
		forKeyPath:@"playbackController.playpauseWillStop"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
		context:NULL];
	
	[[CoverSutra self] addObserver:self
		forKeyPath:@"playbackController.iTunesIsRunning"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
		context:NULL];
	[[CoverSutra self] addObserver:self
		forKeyPath:@"nowPlayingController.track"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
		context:NULL];
	
	[[CoverSutra self] addObserver:self
		forKeyPath:@"playbackController.playable"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
		context:NULL];
	[[CoverSutra self] addObserver:self
		forKeyPath:@"playbackController.skipable"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
		context:NULL];
	[[CoverSutra self] addObserver:self
		forKeyPath:@"playbackController.rewindable"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
		context:NULL];
		
	[[CoverSutra self] addObserver:self
		forKeyPath:@"playbackController.shuffleAndRepeatModeChangeable"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
		context:NULL];
	[[CoverSutra self] addObserver:self
		forKeyPath:@"playbackController.shuffle"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
		context:NULL];
	[[CoverSutra self] addObserver:self
		forKeyPath:@"playbackController.repeatMode"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
		context:NULL];
		
	[[CoverSutra self] addObserver:self
		forKeyPath:@"playbackController.mute"
		options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
		context:NULL];
		
	// Player position slider
	[playerPositionSlider bind:@"positionInSeconds"
		toObject:[CoverSutra self]
		withKeyPath:@"playbackController.playerPosition"
		options:nil];
	[playerPositionSlider bind:@"durationInSeconds"
		toObject:[CoverSutra self]
		withKeyPath:@"nowPlayingController.track.durationInSeconds"
		options:nil];
	[playerPositionSlider setDelegate:self];
	
	// Star Rating control
	[userRatingControl bind:@"representedObject"
				   toObject:[CoverSutra self]
				withKeyPath:@"nowPlayingController.track"
					options:nil];
		
	[self setWindowFrameAutosaveName:@"applicationWindow2"];

//	[[self window] setRepresentedFilename:@"hello world.pdf"];
}

- (IBAction)maximizeSoundVolume:(id)sender {
	CoverSutraApp.playbackController.soundVolume = 100;
}

- (IBAction)minimizeSoundVolume:(id)sender {
	CoverSutraApp.playbackController.soundVolume = 0;
}

- (IBAction)changeSoundVolume:(id)sender {
	CoverSutraApp.playbackController.soundVolume = soundVolumeSlider.floatValue;
}

- (NSSize)windowWillResize:(NSWindow*)window toSize:(NSSize)proposedFrameSize {
	CGFloat scaleFactor = [window userSpaceScaleFactor];
	
	if(proposedFrameSize.height <= 140.0) {
		proposedFrameSize.height = 72.0 * scaleFactor;
		
		if(![self condensedLayout]) {
			[self setCondensedLayout:YES];
		}
	}
	
	if(proposedFrameSize.height > 140.0) {
		proposedFrameSize.height = 226.0 * scaleFactor;
		
		if([self condensedLayout]) {
			[self setCondensedLayout:NO];
		}
	}
	
	proposedFrameSize.width = MAX(proposedFrameSize.width, 398.0 * scaleFactor);
	
	return proposedFrameSize;
}

- (void)windowDidBecomeKey:(NSNotification*)notification {
	if([self isOrderingOut]) {
		[self orderFront:notification];
	}
	
	[[[CoverSutra self] playbackController] addPlayerControlsObserver:self];
	[[[CoverSutra self] playbackController] addPlayerPositionObserver:self];
}

- (void)windowDidResignKey:(NSNotification*)notification {
//	if(![self condensedLayout]) {
		[self orderOut:notification];
//	}
}

- (IBAction)orderFront:(id)sender {
	[self orderFront:sender animate:YES];
	[[self window] makeKeyWindow];
}

- (IBAction)orderOut:(id)sender {
	[self orderOut:sender animate:YES];
	
	[[[CoverSutra self] playbackController] removePlayerControlsObserver:self];
	[[[CoverSutra self] playbackController] removePlayerPositionObserver:self];
}

- (IBAction)orderFrontiTunes:(id)sender {
	[[[CoverSutra self] playerController] setITunesIsFrontmost:YES];
}

- (float)animationOrderInTime {
	return 0.125;
}

- (float)animationOrderOutTime {
	return 0.25;
}

- (void)playlistControlsButtonPressed:(id)sender {
	NSInteger selectedSegment = [sender selectedSegment];
	
	if(selectedSegment == 0) {
		[[CoverSutra self] toggleShuffle:sender];
	}
	
	if(selectedSegment == 1) {
		[[CoverSutra self] toggleSongRepeat:sender];
	}
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
//	// Check if the value changed
//	if([[change objectForKey:NSKeyValueChangeKindKey] integerValue] == NSKeyValueChangeSetting) {
//		if([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[change objectForKey:NSKeyValueChangeOldKey]]) {
//			return; // The values are equal, no need to refresh
//		}
//	}
	
	if([keyPath isEqualToString:@"nowPlayingController.track"]) {
		[self _updatePlayerInfo];
	}

	if([keyPath isEqualToString:@"playbackController.playerState"] ||
	   [keyPath isEqualToString:@"playbackController.iTunesIsRunning"] ||
	   [keyPath isEqualToString:@"playbackController.playable"] ||
	   [keyPath isEqualToString:@"playbackController.skipable"] ||
	   [keyPath isEqualToString:@"playbackController.rewindable"] ||
	   [keyPath isEqualToString:@"playbackController.playpauseWillStop"]) {
		[self _updatePlayerButtons];
	}
	
	if([keyPath isEqualToString:@"playbackController.shuffleAndRepeatModeChangeable"] ||
	   [keyPath isEqualToString:@"playbackController.shuffle"] ||
	   [keyPath isEqualToString:@"playbackController.repeatMode"]) {
		[self _updateShuffleButtons];
		[self _updateSongRepeatButtons];
	}
	
	if([keyPath isEqualToString:@"playbackController.mute"]) {
		[self _updateSoundVolumeButtons];
	}
}

- (BOOL)control:(NSControl*)control textShouldBeginEditing:(NSText*)fieldEditor {
	return NO;
}

- (void)mouseUp:(NSEvent*)theEvent {
	if([theEvent clickCount] == 2) {
		NSView* contentView = [[self window] contentView];
		NSPoint point = [contentView convertPoint:[theEvent locationInWindow] fromView:nil];
		NSView* clickedView = [contentView hitTest:point];
		
		if(clickedView == coverView) {
			[[CoverSutra self] showCurrentSong:theEvent];
			return;
		}
	}	
	
	[super mouseUp:theEvent];
}

@end
