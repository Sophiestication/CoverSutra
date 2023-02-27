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

#import "CoverSutra.h"

#import "CoverSutra+Shortcuts.h"
#import "CoverSutra+LoginItems.h"
#import "CoverSutra+Menu.h"
#import "CoverSutra+Private.h"

#import "NSBundle+Additions.h"
#import "NSString+Additions.h"

#import "MusicLibrary.h"

#import "PlayerNotificationController.h"

#import "SCBezelController.h"
#import "SCBezelController+Playback.h"
#import "SCBezelController+Track.h"
#import "SCBezelController+Alert.h"

#import "ShortcutController.h"
#import "ShortcutController+Private.h"

#import "ApplicationWindowController.h"
#import "PreferencesWindowController.h"
#import "DesktopWindowController.h"
#import "SCLyricsWindowController.h"

#import "StatusItemController.h"

#import "MusicSearchWindowController.h"

#import "DockTileController.h"
#import "PlayerController.h"
#import "PlaybackController.h"
#import "NowPlayingController.h"

#import "StarRatingController.h"

// #import "SCLyricsController.h"

#import "LastDotFMController.h"
#import "LastDotFMController+Private.h"

#import "SkinController.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

 CoverSutra* CoverSutraApp = nil;

@implementation CoverSutra

@synthesize
	operationQueue = _operationQueue,
	musicLibrary = _musicLibrary,
	playerController = _playerController,
	playbackController = _playbackController,
	nowPlayingController = _nowPlayingController,
	dockTileController = _dockTileController,
	playerNotificationController = _playerNotificationController,
	skinController = _skinController,
	currentRatingController = _currentRatingController;

+ (void)initialize {
	if(self == [CoverSutra class]) {
		[self setupUserDefaults];
	}
}

+ (CoverSutra*)self {
	return [NSApp delegate];
}

+ (void)setupUserDefaults {
//	CFPreferencesAddSuitePreferencesToApp(kCFPreferencesCurrentApplication, (CFStringRef)@"com.apple.iApps");
	
	// Load the default values for the user defaults
    NSString* pathToUserDefaultsValues = [[NSBundle mainBundle]
		pathForResource:@"userDefaults" 
		ofType:@"plist"];
	NSDictionary* userDefaultsValues = [NSDictionary dictionaryWithContentsOfFile:pathToUserDefaultsValues];
    
    // Set them in the standard user defaults
    [[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValues];

    // Set the initial values in the shared user defaults controller 
//	[[NSUserDefaultsController sharedUserDefaultsController] setInitialValues:userDefaultsValues];
}

- (id)init {
	if((self = [super init])) {
		CoverSutraApp = self;
	
		_operationQueue = [[NSOperationQueue alloc] init];
		[_operationQueue setMaxConcurrentOperationCount:4];

		// Transform CoverSutra into a forground process (with dock tile and menu bar) if needed
		if(self.dockItemShown) {
			ProcessSerialNumber psn = { 0, kCurrentProcess };
			TransformProcessType(&psn, kProcessTransformToForegroundApplication);
		}
	}

	return self;
}

- (void)applicationWillFinishLaunching:(NSNotification*)notification {
//	NSLog(@"Running in Demo mode.");
//	
//	if([[NSDate date] compare:[NSDate dateWithString:@"2011-03-01 00:00:00 +0600"]] == NSOrderedDescending) {
//		exit(666);
//	} 
}

- (void)applicationDidFinishLaunching:(NSNotification*)notification {
	// Set Apple Events timout
//	[CSiTunesApplication() setTimeout:2.5 * 100.0]; // Timeout in ticks
	
	// Show desktop window
	if([DesktopWindowController desktopWindowShown]) {
		[[self desktopWindowController] orderFront:nil];
	}
		
	// Schedule pending submissions
	if([[self lastDotFMController] submissionsEnabled]) {
		[[self lastDotFMController] performSelector:@selector(handshake)
			withObject:nil
			afterDelay:10.0];
	}
	
	// TODO
	[self skinController];
//	[self lyricsController];
	
	// Initialize the various player controllers
	[self performSelector:@selector(playerController)
		withObject:nil
		afterDelay:0.0];
	[self performSelector:@selector(playbackController)
		withObject:nil
		afterDelay:0.0];
	[self performSelector:@selector(nowPlayingController)
		withObject:nil
		afterDelay:0.0];
	[self performSelector:@selector(playerNotificationController)
		withObject:nil
		afterDelay:0.0];
	
	[ShortcutController sharedShortcutController];

	// Initialize the dock tile controller
	if([self dockItemShown]) {
		[self performSelector:@selector(dockTileController)
			withObject:nil
			afterDelay:0.0];
	}

	// Create status item controller and display if needed
	[self performSelector:@selector(statusItemController)
		withObject:nil
		afterDelay:0.0];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication*)sender {
	[[self statusItemController] removeImmediately];
	
	return NSTerminateNow;
}

- (void)applicationWillTerminate:(NSNotification*)notification {
	[ShortcutController releaseSharedShortcutController];
	
//	// Smoothly hide out the status item
//	[[self statusItemController] shrink:notification];
}

- (void)relaunch {
	// Thanks to Allan Odgaard for this restart code, which is much more clever than mine was.
	setenv("LAUNCH_PATH", [[[NSBundle mainBundle] bundlePath] UTF8String], 1);
	system("/bin/bash -c '{ for (( i = 0; i < 3000 && $(echo $(/bin/ps -xp $PPID|/usr/bin/wc -l))-1; i++ )); do\n"
		   "    /bin/sleep .2;\n"
		   "  done\n"
		   "  if [[ $(/bin/ps -xp $PPID|/usr/bin/wc -l) -ne 2 ]]; then\n"
		   "    /usr/bin/open \"${LAUNCH_PATH}\"\n"
		   "  fi\n"
		   "} &>/dev/null &'");
	
	[[NSApplication sharedApplication] terminate:self];	
}

- (MusicLibrary*)musicLibrary {
	if(!_musicLibrary) {
		_musicLibrary = [[MusicLibrary alloc] init];
	}
	
	return _musicLibrary;
}

- (PlayerNotificationController*)playerNotificationController {
	if(!_playerNotificationController) {
		_playerNotificationController = [[PlayerNotificationController alloc] init];
	}
	
	return _playerNotificationController;
}

- (ApplicationWindowController*)applicationWindowController {
	if(!_applicationWindowController) {
		_applicationWindowController = [ApplicationWindowController applicationWindowController];
	}
	
	return _applicationWindowController;
}

- (PreferencesWindowController*)preferencesWindowController {
	if(!_preferencesWindowController) {
		_preferencesWindowController = [PreferencesWindowController preferencesWindowController];
	}
	
	return _preferencesWindowController;
}

- (DesktopWindowController*)desktopWindowController {
	if(!_desktopWindowController) {
		_desktopWindowController = [DesktopWindowController desktopWindowController];
	}
	
	return _desktopWindowController;
}

- (StatusItemController*)statusItemController {
	if(!_statusItemController) {
		_statusItemController = [[StatusItemController alloc] init];
	}
	
	return _statusItemController;
}

- (MusicSearchWindowController*)musicSearchWindowController {
	if(!_musicSearchWindowController) {
		_musicSearchWindowController = [MusicSearchWindowController musicSearchWindowController];
	}
	
	return _musicSearchWindowController;
}

- (DockTileController*)dockTileController {
	if(!_dockTileController) {
		_dockTileController = [[DockTileController alloc] init];
	}
	
	return _dockTileController;
}

- (PlayerController*)playerController {
	if(!_playerController) {
		_playerController = [[PlayerController alloc] init];
	}
	
	return _playerController;
}

- (PlaybackController*)playbackController {
	if(!_playbackController) {
		_playbackController = [[PlaybackController alloc] init];
	}
	
	return _playbackController;
}

- (NowPlayingController*)nowPlayingController {
	if(!_nowPlayingController) {
		_nowPlayingController = [[NowPlayingController alloc] init];
	}
	
	return _nowPlayingController;
}

- (LastDotFMController*)lastDotFMController {
	if(!_lastDotFMController) {
		_lastDotFMController = [[LastDotFMController alloc] init];
	}
	
	return _lastDotFMController;
}

- (SkinController*)skinController {
	if(!_skinController) {
		_skinController = [[SkinController alloc] init];
		
		[_skinController setSelectionIndex:0];
	}
	
	return _skinController;
}

- (NSString*)applicationPreferencesFolder {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Preferences"];
}

- (NSString*)applicationSupportFolder {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"CoverSutra"];
}

- (NSString*)applicationCacheFolder {
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"com.sophiestication.coversutra"];
}

- (NSArray*)applicationPlugInFolders {
	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask|NSLocalDomainMask, YES);
	
	unsigned numberOfPaths = [paths count];
	unsigned pathIndex = 0;
	
	NSMutableArray* plugInFolders = [NSMutableArray array];
	
	[plugInFolders addObject:
		[[NSBundle mainBundle] builtInPlugInsPath]];
	
	for(; pathIndex < numberOfPaths; ++pathIndex) {
		NSString* folder = [[paths objectAtIndex:pathIndex]
			stringByAppendingPathComponent:@"CoverSutra/PlugIn"];
			
		[plugInFolders addObject:folder];
	}
	
	return plugInFolders;
}

- (BOOL)statusItemShown {
	return [[[NSUserDefaultsController sharedUserDefaultsController]
		valueForKeyPath:@"values.statusItemShown"] boolValue];
}

- (BOOL)dockItemShown {
	return [[[NSUserDefaultsController sharedUserDefaultsController]
		valueForKeyPath:@"values.dockItemShown"] boolValue];
}

- (IBAction)orderFrontPurchasePage:(id)sender {
	NSURL* purchasePageURL = [NSURL URLWithString:@"http://sophiestication.com/CoverSutra/"];
	[[NSWorkspace sharedWorkspace] openURL:purchasePageURL];
}

- (IBAction)orderFrontLatestNewsPage:(id)sender {
	NSURL* latestNewsPageURL = [NSURL URLWithString:@"http://sophiestication.com"];
	[[NSWorkspace sharedWorkspace] openURL:latestNewsPageURL];
}

- (IBAction)orderFrontFeedbackMail:(id)sender {
	NSString* address = @"coversutra@sophiestication.com";
	NSString* subject = [[NSString stringWithFormat:@"CoverSutra %@ Feedback", [[NSBundle mainBundle] shortVersionString]]
		stringByReplacingAllOccurrencesOfString:@" " withString:@"%20"];
	NSString* body = @"Your%20feedback%20here";
	
	NSString* URLString = [NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@", address, subject, body];
	
	NSURL* feedbackMail = [NSURL URLWithString:URLString];
	[[NSWorkspace sharedWorkspace] openURL:feedbackMail];
}

- (IBAction)orderFrontPreferencesPanel:(id)sender {
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[self preferencesWindowController] showWindow:sender];
}

- (IBAction)orderFrontAdvancedPreferencesPanel:(id)sender {
	[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
	[[self preferencesWindowController] showAdvancedPreferences:sender];
}

- (IBAction)orderFrontApplicationWindow:(id)sender {
	[[self applicationWindowController] orderFront:sender];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication*)theApplication hasVisibleWindows:(BOOL)flag {
	if([[NSApplication sharedApplication] modalWindow]) {
		return YES;
	}
	
	if(_preferencesWindowController && [[self preferencesWindowController] isVisible]) {
		return YES;
	}
	
	[self toggleApplicationWindowShown:nil];	
	
	return YES;
}

- (void)_orderFrontNextSongBezel:(id)sender {
	[[SCBezelController sharedController] orderFrontSkippingBezel:sender];
	[[SCBezelController sharedController] scheduleOrderOut:sender];
}

- (void)_orderFrontPreviousSongBezel:(id)sender {
	[[SCBezelController sharedController] orderFrontRewindingBezel:sender];
	[[SCBezelController sharedController] scheduleOrderOut:sender];
}

- (void)_playpause:(id)sender {
	[[self playbackController] refreshImmediately];
	
	[[SCBezelController sharedController] orderFrontPlaypauseBezel:sender];
	[[SCBezelController sharedController] scheduleOrderOut:sender];
}

- (void)_fastForward:(id)sender {
	[_delayActionTimer invalidate], _delayActionTimer = nil;
	[_repeatActionTimer invalidate], _repeatActionTimer = nil;
	
	[[self playbackController] fastForward];
	
	// TODO
}

- (void)_rewind:(id)sender {
	[_delayActionTimer invalidate], _delayActionTimer = nil;
	[_repeatActionTimer invalidate], _repeatActionTimer = nil;
	
	[[self playbackController] rewind];
	
	// TODO
}

- (void)_increaseSoundVolume:(id)sender {
	[_increaseSoundVolumeDelayTimer invalidate], _increaseSoundVolumeDelayTimer = nil;
	[_repeatActionTimer invalidate], _repeatActionTimer = nil;
	
	_repeatActionTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
		target:self
		selector:@selector(increaseSoundVolume:)
		userInfo:nil
		repeats:YES];
}

- (void)_decreaseSoundVolume:(id)sender {
	[_decreaseSoundVolumeDelayTimer invalidate], _decreaseSoundVolumeDelayTimer = nil;
	[_repeatActionTimer invalidate], _repeatActionTimer = nil;
	
	_repeatActionTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
		target:self
		selector:@selector(decreaseSoundVolume:)
		userInfo:nil
		repeats:YES];
}

- (void)_rateUsingSelector:(SEL)selector sender:(id)sender {
	if([((ShortcutEvent*)sender) type] == NSKeyDown) {
		PlayerController* playerController = self.playerController;
		
		if(playerController.iTunesIsRunning && !playerController.iTunesIsBusy) {
			StarRatingController* ratingController = self.currentRatingController;
		
			if(!ratingController) {
				MusicLibraryTrack* track = [[self nowPlayingController] track];
				
				ratingController = [[StarRatingController alloc] initWithTrack:track];
				self.currentRatingController = ratingController;
			}
			
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
			// Rate by using the given selector
			[ratingController performSelector:selector];
#pragma clang diagnostic pop
		}
		
		// Display the star rating bezel
		[[SCBezelController sharedController] orderFrontStarRatingBezel:sender];
	} else {
		[[self currentRatingController] scheduleCommit];
		[[SCBezelController sharedController] scheduleOrderOut:sender];
	}
}

- (void)_rateCurrentSongWith:(NSInteger)rating sender:(id)sender {
	if([self _isShortcutEvent:sender]) {
		if([((ShortcutEvent*)sender) type] == NSKeyDown) {
			[[SCBezelController sharedController] orderFrontStarRatingBezel:sender];
		}
		
		if([((ShortcutEvent*)sender) type] == NSKeyUp) {
			[[SCBezelController sharedController] scheduleOrderOut:sender];
			return;
		}
	} else {
		[[SCBezelController sharedController] orderFrontStarRatingBezel:sender];
		[[SCBezelController sharedController] scheduleOrderOut:sender];
	}
	
	PlayerController* playerController = self.playerController;
		
	if(playerController.iTunesIsRunning && !playerController.iTunesIsBusy) {
		StarRatingController* ratingController = self.currentRatingController;
	
		if(!ratingController) {
			MusicLibraryTrack* track = [[self nowPlayingController] track];

			ratingController = [[StarRatingController alloc] initWithTrack:track];
			self.currentRatingController = ratingController;
		}
		
		ratingController.rating = rating;
		[ratingController scheduleCommit];
	}
}

- (void)_resetPreferencesWindowController {
	_preferencesWindowController = nil;
}

@end
