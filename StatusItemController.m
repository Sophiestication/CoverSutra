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

#import "StatusItemController.h"
#import "StatusItemController+Private.h"

#import "StatusItemControl.h"

#import "PlayerController.h"
#import "PlaybackController.h"
#import "NowPlayingController.h"
#import "MusicSearchWindowController.h"

#import "MusicLibraryTrack.h"

#import "CoverSutra.h"

#import "NSImage+Additions.h"
#import "NSString+Additions.h"

#import <QuartzCore/QuartzCore.h>

@implementation StatusItemController

@dynamic
	statusItemShown,
	dimmed,
	statusItem,
	statusItemControl;

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_flags.initialized = NO;
	_flags.statusItemShown = NO;
	_flags.searchMenuShown = NO;
	_flags.dimmed = NO;
	
	// Observe iTunes' isRunning property
	[[CoverSutra self]
		addObserver:self
		forKeyPath:@"playbackController.iTunesIsRunning"
		options:0
		context:NULL];
	
	// Observe the statusItemShown preferences key
	[[NSUserDefaultsController sharedUserDefaultsController]
		addObserver:self
		forKeyPath:@"values.statusItemShown"
		options:0
		context:NULL];
		
	// Get notifications about the music search menu
/*	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_musicSearchMenuDidBeginTracking:)
		name:MusicSearchMenuDidBeginTrackingNotification
		object:nil];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_musicSearchMenuDidEndTracking:)
		name:MusicSearchMenuDidEndTrackingNotification
		object:nil];*/
		
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(applicationWillTerminate:)
		name:NSApplicationWillTerminateNotification
		object:nil];
	
	// Setup the status item regarding user defaults
	id statusItemShown = [[[NSUserDefaultsController sharedUserDefaultsController] values]
		valueForKey:@"statusItemShown"];
	[self setStatusItemShown:ToBoolean(statusItemShown)];
	
	// Setup dimmed status
	[self setDimmed:
		![[[CoverSutra self] playerController] iTunesIsRunning]];
	
	_flags.initialized = YES;
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];


}

- (BOOL)statusItemShown {
	return _flags.statusItemShown;
}

- (void)setStatusItemShown:(BOOL)statusItemShown {
	if(statusItemShown != _flags.statusItemShown || !_flags.initialized) {
		_flags.statusItemShown = statusItemShown;
		
		// Important!!!
		[self statusItem];
		[self statusItemControl];
		
		if(!statusItemShown && !_flags.initialized) {
			NSSize newFrameSize = [[[self statusItemControl] cell] cellSize];
			
			newFrameSize.width = 0.0;
			
			[[self statusItemControl] setFrameSize:newFrameSize];
		}
		
		if(statusItemShown) {
//			// Create the status item, automatically create the status item control
//			[self statusItem];
//			[self statusItemControl]; // Not necessary, but cleaner
			
			// Register all necessary player notifications
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
			[[NSNotificationCenter defaultCenter]
				addObserver:self
				selector:@selector(_playerDidChangeTrack:)
				name:PlayerDidChangeTrackNotification
				object:nil];
				
			NSSize newFrameSize = [[[self statusItemControl] cell] cellSize];
			[[self statusItemControl] setFrameSize:newFrameSize];
	
			[[[self statusItemControl] animator] setAlphaValue:self.dimmed ? 0.75 : 1.0];
			[[[self statusItemControl] animator] setScaleFactor:1.0];
		} else {
			// We don't longer want player notifications
			[[NSNotificationCenter defaultCenter] removeObserver:self];
			
			// Hide the status item
			[[[self statusItemControl] animator] setAlphaValue:0.0];
			[[[self statusItemControl] animator] setScaleFactor:0.0];
		}
	}
}

- (BOOL)isDimmed {
	return _flags.dimmed;
}

- (void)setDimmed:(BOOL)dimmed {
	if(dimmed != [self isDimmed] || !_flags.initialized) {
		[self _setDimmed:dimmed];
	}
}

- (NSStatusItem*)statusItem {
	if(!_statusItem) {
		NSStatusItem* statusItem = [[NSStatusBar systemStatusBar]
			statusItemWithLength:NSVariableStatusItemLength];
	
		_statusItem = statusItem;
		
		[statusItem setView:[self statusItemControl]];
	}

	return _statusItem;
}

- (StatusItemControl*)statusItemControl {
	if(!_statusItemControl) {
		_statusItemControl = [[StatusItemControl alloc] initWithStatusItem:_statusItem];
		
		[_statusItemControl setMenu:
			[[CoverSutra self] valueForKey:@"statusMenu"]];
		
		[_statusItemControl setFrameSize:NSZeroSize];
//		[[_statusItemControl cell] cellSize]];
		[_statusItemControl setScaleFactor:0.0];
		[_statusItemControl setAlphaValue:0.0];
		
		NSImage* statusImage = nil;
		
		if(EqualStrings([[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:@"values.gender"], @"female")) {
			statusImage = [NSImage templateImageNamed:@"statusItemTemplate2.pdf"];
		} else {
			statusImage = [NSImage templateImageNamed:@"statusItemTemplate.pdf"];
		}

		[statusImage setSize:NSMakeSize(17.0, 17.0)];
		
		[_statusItemControl setImage:statusImage];
	}
	
	return _statusItemControl;
}

- (void)_setDimmed:(BOOL)dimmed {
	if([self statusItemShown]) {
		[[[self statusItemControl] animator] setAlphaValue:dimmed ? 0.75 : 1.0];
	}
	
	_flags.dimmed = dimmed;
}

- (void)removeImmediately {
	[[NSStatusBar systemStatusBar] removeStatusItem:[self statusItem]];
}

- (void)_playerDidChangeTrack:(NSNotification*)notification {
	MusicLibraryTrack* track = [[[CoverSutra self] nowPlayingController] track];
	
	if(track) {
		NSString* toolTip = [NSString stringWithFormat:NSLocalizedString(@"NOWPLAYING_STATUSITEM", @"Now playing status item tooltip"), track.displayName];
		[[self statusItemControl] setToolTip:toolTip];
	} else {
		[[self statusItemControl] setToolTip:@""];
	}
}

- (void)_iTunesWillFinishLaunching:(NSNotification*)notification {
	[self setDimmed:NO];
	
	MusicLibraryTrack* track = [[[CoverSutra self] nowPlayingController] track];
		
	if(track) {
		NSString* toolTip = [NSString stringWithFormat:NSLocalizedString(@"NOWPLAYING_STATUSITEM", @"Now playing status item tooltip"),
			track.displayName];
		[[self statusItemControl] setToolTip:toolTip];
	} else {
		[[self statusItemControl] setToolTip:@""];
	}
}

- (void)_iTunesDidTerminate:(NSNotification*)notification {
	[[self statusItemControl] setToolTip:
		NSLocalizedString(@"ITUNESNOTRUNNING_BEZEL_TEXT", @"")];
	[self setDimmed:YES];
}

- (void)_musicSearchMenuDidBeginTracking:(NSNotification*)notification {
	_flags.searchMenuShown = 1;
	
	if(!self.statusItemShown) {
		self.statusItemShown = YES;
	}
}

- (void)_musicSearchMenuDidEndTracking:(NSNotification*)notification {
	_flags.searchMenuShown = 0;
	
	BOOL statusItemShown = ToBoolean([[[NSUserDefaultsController sharedUserDefaultsController] values]
		valueForKey:@"statusItemShown"]);
	self.statusItemShown = statusItemShown;
}

- (void)applicationWillTerminate:(NSNotification*)notification {
	[self removeImmediately];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
	if(EqualStrings(keyPath, @"values.statusItemShown")) {
		BOOL statusItemShown = ToBoolean([[[NSUserDefaultsController sharedUserDefaultsController] values]
			valueForKey:@"statusItemShown"]);
		
		self.statusItemShown = statusItemShown;
	}
	
	if(EqualStrings(keyPath, @"isRunning")) {
		BOOL isPlayerRunning = ToBoolean([change valueForKey:NSKeyValueChangeNewKey]);
		self.dimmed = !isPlayerRunning;
	}
}

@end
