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

#import "ApplicationWindowController+Private.h"

#import "PlayerController.h"
#import "PlaybackController.h"

#import "CoverSutra.h"
#import "CoverSutra+Shortcuts.h"

#import "CoverView.h"
#import "PlayerPositionSlider.h"
#import "StarRatingControl.h"

#import "SegmentedControl.h"
#import "Slider.h"

#import "NSImage+Additions.h"
#import "NSString+Additions.h"
#import "NSShadow+Additions.h"

#import "Utilities.h"

@implementation ApplicationWindowController(Private)

- (void)_updatePlayerPositionSlider {
}

- (void)_updatePlayerButtons {
	PlaybackController* playbackController = [[CoverSutra self] playbackController];
	
	if(playbackController.paused || playbackController.stopped) {
		[playerControls setImage:[self _segmentedControlButtonWithName:ImageNamePlayTemplate]
			forSegment:1];
	} else if(playbackController.playpauseWillStop) {
		[playerControls setImage:[self _segmentedControlButtonWithName:ImageNameStopTemplate]
			forSegment:1];
	} else if(playbackController.playing) {
		[playerControls setImage:[self _segmentedControlButtonWithName:ImageNamePauseTemplate]
			forSegment:1];
	}
	
	BOOL iTunesIsRunning = [[[CoverSutra self] playerController] iTunesIsRunning];
	
	[playerControls setEnabled:iTunesIsRunning && playbackController.playable
		forSegment:1];
		
	[playerControls setEnabled:iTunesIsRunning && playbackController.rewindable
		forSegment:0];
	[playerControls setEnabled:iTunesIsRunning && playbackController.skipable
		forSegment:2];
}

- (void)_updateShuffleButtons {
	PlaybackController* playbackController = [[CoverSutra self] playbackController];
	
	NSImage* image = playbackController.shuffle ?
		[self _segmentedControlButtonWithName:ImageNameShuffleTemplate] :
		[self _segmentedControlButtonWithName:ImageNameShuffleOffTemplate];
	
	[playlistControls setImage:image
		forSegment:0];
	[playlistControls setEnabled:playbackController.shuffleAndRepeatModeChangeable
		forSegment:0];
}

- (void)_updateSongRepeatButtons {
	PlaybackController* playbackController = [[CoverSutra self] playbackController];
	
	NSString* repeatMode = playbackController.repeatMode;
	
	if(EqualStrings(PlaybackRepeatModeAll, repeatMode)) {
		[playlistControls
			setImage:[self _segmentedControlButtonWithName:ImageNameRepeatModeAllTemplate]
			forSegment:1];
	} else if(EqualStrings(PlaybackRepeatModeOne, repeatMode)) {
		[playlistControls
			setImage:[self _segmentedControlButtonWithName:ImageNameRepeatModeOneTemplate]
			forSegment:1];
	} else {
		[playlistControls
			setImage:[self _segmentedControlButtonWithName:ImageNameRepeatModeOffTemplate]
			forSegment:1];
	}
	
	[playlistControls setEnabled:playbackController.shuffleAndRepeatModeChangeable
		forSegment:1];
}

- (void)_updateSoundVolumeButtons {
	PlaybackController* playbackController = [[CoverSutra self] playbackController];
	
	if(playbackController.mute) {
		NSImage* muteSoundVolumeImage = [NSImage templateImageNamed:ImageNameMuteSoundVolumeTemplate];
		
		[muteSoundVolumeImage setSize:NSMakeSize(16.0, 16.0)];
		
		[minSoundVolume setImage:muteSoundVolumeImage];
		[maxSoundVolume setImage:muteSoundVolumeImage];
	} else {
		[minSoundVolume setImage:[NSImage templateImageNamed:ImageNameMinSoundVolumeTemplate]];
		[maxSoundVolume setImage:[NSImage templateImageNamed:ImageNameMaxSoundVolumeTemplate]];
	}
}

- (void)_updatePlayerInfo {
	NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
	
	[paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
	[paragraph setAlignment:NSCenterTextAlignment];
	
	NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSColor whiteColor], NSForegroundColorAttributeName,
		[NSFont boldSystemFontOfSize:12.0], NSFontAttributeName,
		[NSShadow HUDImageShadow], NSShadowAttributeName,
		paragraph, NSParagraphStyleAttributeName,
		nil];
	
	NSString* stringValue = nil;

	if(![[[CoverSutra self] playerController] iTunesIsRunning]) {
		stringValue = NSLocalizedString(@"ITUNESNOTRUNNING_BEZEL_TEXT", @"");
	} else {
		stringValue = NSLocalizedString(@"NOSONG_BEZEL_TEXT", @"");
	}
		 
	[notRunning setAttributedTitle:
		[[NSAttributedString alloc] initWithString:stringValue attributes:attributes]];
}

- (void)_initAlert {
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
	
	NSImage* alertImage = [NSImage templateImageNamed:ImageNameAlertTemplate];
	
	[alertImage setSize:NSMakeSize(72.0, 72.0)];
	
	[notRunning setImage:alertImage];
	[notRunning setImagePosition:NSImageAbove];
	[[notRunning cell] setImageScaling:NSImageScaleProportionallyDown];
	
	[notRunning setBordered:NO];
	[notRunning setButtonType:NSMomentaryChangeButton];
	[notRunning setAlignment:NSCenterTextAlignment];
	[notRunning setFocusRingType:NSFocusRingTypeNone];
	
	[notRunning setTarget:self];
	[notRunning setAction:@selector(orderFrontiTunes:)];
}

- (void)_initPlayerControls {
//	[playerControls setIgnoresMultiClick:YES];
	
	[playerControls setSegmentStyle:NSSegmentStyleCapsule];
	[[playerControls cell] setTrackingMode:NSSegmentSwitchTrackingMomentary];
	
	CGFloat segmentWidth = 40.0;
	
	[playerControls setImage:[self _segmentedControlButtonWithName:ImageNameRewindTemplate] forSegment:0];
	[playerControls setWidth:segmentWidth forSegment:0];
	[playerControls setImageScaling:NSImageScaleProportionallyDown forSegment:0];
	
	[playerControls setImage:[self _segmentedControlButtonWithName:ImageNamePlayTemplate] forSegment:1];
	[playerControls setWidth:segmentWidth forSegment:1];
	[playerControls setImageScaling:NSImageScaleProportionallyDown forSegment:1];

	[playerControls setImage:[self _segmentedControlButtonWithName:ImageNameFastForwardTemplate] forSegment:2];
	[playerControls setWidth:segmentWidth forSegment:2];
	[playerControls setImageScaling:NSImageScaleProportionallyDown forSegment:2];
}

- (void)_initPlaylistControls {
//	[playlistControls setIgnoresMultiClick:YES];

	[playlistControls setSegmentCount:2];
	
	[playlistControls setSegmentStyle:NSSegmentStyleCapsule];
	[[playlistControls cell] setTrackingMode:NSSegmentSwitchTrackingMomentary];
	
	CGFloat segmentWidth = 40.0;
	
	[playlistControls setImage:[self _segmentedControlButtonWithName:ImageNameShuffleOffTemplate] forSegment:0];
	[playlistControls setWidth:segmentWidth forSegment:0];
	[playlistControls setImageScaling:NSImageScaleProportionallyDown forSegment:0];
	
	[playlistControls setImage:[self _segmentedControlButtonWithName:ImageNameRepeatModeOffTemplate] forSegment:1];
	[playlistControls setWidth:segmentWidth forSegment:1];
	[playlistControls setImageScaling:NSImageScaleProportionallyDown forSegment:1];

	[playlistControls setTarget:self];
	[playlistControls setAction:@selector(playlistControlsButtonPressed:)];
	
	[playlistControls removeAllToolTips];
	[[playlistControls cell] setToolTip:NSLocalizedString(@"SHUFFLE_BUTTON_TOOLTIP", @"Shuffle on/off application window control")
		forSegment:0];
	[[playlistControls cell] setToolTip:NSLocalizedString(@"REPEATMODE_BUTTON_TOOLTIP", @"Repeat mode application window control")
		forSegment:1];
}

- (void)_initSoundVolumeControls {
	// Init min sound volume control
	[[minSoundVolume cell] setButtonType:NSMomentaryChangeButton];
	[[minSoundVolume cell] setBordered:NO];
	
	[[minSoundVolume cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
	
	[minSoundVolume setTarget:self];
	[minSoundVolume setAction:@selector(minimizeSoundVolume:)];
	
//	[minSoundVolume bind:NSEnabledBinding
//		toObject:[CoverSutra self]
//		withKeyPath:@"playerController.iTunesIsRunning"
//		options:nil];
	
	// Init max sound volume control
	[[maxSoundVolume cell] setButtonType:NSMomentaryChangeButton];
	[[maxSoundVolume cell] setBordered:NO];
	
	[[maxSoundVolume cell] setImageScaling:NSImageScaleProportionallyUpOrDown];
	
	[maxSoundVolume setTarget:self];
	[maxSoundVolume setAction:@selector(maximizeSoundVolume:)];
	
//	[maxSoundVolume bind:NSEnabledBinding
//		toObject:[CoverSutra self]
//		withKeyPath:@"playerController.iTunesIsRunning"
//		options:nil];
	
	// Init sound volume slider
	[soundVolumeSlider bind:NSValueBinding
		toObject:[CoverSutra self]
		withKeyPath:@"playbackController.soundVolume"
		options:nil];
}

- (void)_initTrackLabels {
	// Setup textfields
	[title setFont:[NSFont boldSystemFontOfSize:12.0]];
	[title bind:NSValueBinding
		toObject:[CoverSutra self]
		withKeyPath:@"nowPlayingController.track.displayName"
		options:nil];
	[[title cell] setLineBreakMode:NSLineBreakByTruncatingTail];
	[title setBezeled:NO];
	[title setBordered:NO];
	[title setDrawsBackground:NO];
	[title setEditable:NO];
	[title setSelectable:NO];
	[title setRefusesFirstResponder:YES];
	[title setDelegate:self];
	
	[album setFont:[NSFont boldSystemFontOfSize:11.0]];
	[album bind:NSValueBinding
		toObject:[CoverSutra self]
		withKeyPath:@"nowPlayingController.track.displayAlbum"
		options:nil];
	[[album cell] setLineBreakMode:NSLineBreakByTruncatingTail];
	[album setBezeled:NO];
	[album setBordered:NO];
	[album setDrawsBackground:NO];
	[album setEditable:NO];
	[album setSelectable:NO];
	[album setRefusesFirstResponder:YES];
	[album setDelegate:self];
	
	[artist setFont:[NSFont boldSystemFontOfSize:11.0]];
	[artist bind:NSValueBinding
		toObject:[CoverSutra self]
	 	withKeyPath:@"nowPlayingController.track.displayArtist"
		options:nil];
	[[artist cell] setLineBreakMode:NSLineBreakByTruncatingTail];
	[artist setBezeled:NO];
	[artist setBordered:NO];
	[artist setDrawsBackground:NO];
	[artist setEditable:NO];
	[artist setSelectable:NO];
	[artist setRefusesFirstResponder:YES];
	[artist setDelegate:self];
	
	[trackNumber setFont:[NSFont boldSystemFontOfSize:10.0]];
	[trackNumber bind:NSValueBinding
		toObject:[CoverSutra self]
		withKeyPath:@"nowPlayingController.track.displayTrackNumber"
		options:nil];
	[[trackNumber cell] setLineBreakMode:NSLineBreakByTruncatingTail];
	[trackNumber setBezeled:NO];
	[trackNumber setBordered:NO];
	[trackNumber setDrawsBackground:NO];
	[trackNumber setEditable:NO];
	[trackNumber setSelectable:NO];
	[trackNumber setRefusesFirstResponder:YES];
	[trackNumber setDelegate:self];
}

- (void)_initActionButton {
	[actionButton setSegmentCount:1];
	
	[actionButton setSegmentStyle:NSSegmentStyleCapsule];
	[[actionButton cell] setTrackingMode:NSSegmentSwitchTrackingMomentary];
	
	NSMenu* actionMenu = [[CoverSutra self] valueForKey:@"actionMenu"];
	[actionMenu setAutoenablesItems:YES];
	[actionButton setMenu:actionMenu forSegment:0];
	
	NSImage* image = [self _segmentedControlButtonWithName:ImageNameAdvancedTemplate];
	
	NSRect alignmentRect = NSOffsetRect([image alignmentRect], -1.0, 0.0);
	[image setAlignmentRect:alignmentRect];
	
	[actionButton setImage:image forSegment:0];
	[actionButton setWidth:48.0 forSegment:0];
	[actionButton setImageScaling:NSImageScaleProportionallyDown forSegment:0];
}

- (NSImage*)_segmentedControlButtonWithName:(NSString*)name {
	NSImage* image = [NSImage templateImageNamed:name];
	
	CGFloat userSpaceScaleFactor = self.window.userSpaceScaleFactor;
	[image setSize:NSMakeSize(20.0 * userSpaceScaleFactor, 19.0 * userSpaceScaleFactor)];
	
	return image;
}

- (void)_iTunesWillFinishLaunching:(NSNotification*)notification {
	[self _updatePlayerInfo];
	[self _updatePlayerButtons];
}

- (void)_iTunesDidTerminate:(NSNotification*)notification {
	[self _updatePlayerInfo];
	[self _updatePlayerButtons];
	
	[self orderOut:notification];
}

@end
