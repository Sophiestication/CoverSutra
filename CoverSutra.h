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

@class
	iTunes,
	MusicLibrary,
	PlayerNotificationController,
	ApplicationWindowController,
	PreferencesWindowController,
	DesktopWindowController,
	StatusItemController,
	MusicSearchWindowController,
	DockTileController,
	PlayerController,
	PlaybackController,
	NowPlayingController,
	LastDotFMController,
	SkinController,
	StarRatingController;

@interface CoverSutra : NSObject {
	IBOutlet NSMenu* dockMenu;
	IBOutlet NSMenu* statusMenu;
	IBOutlet NSMenu* actionMenu;

@private
	NSOperationQueue* _operationQueue;

	PlayerNotificationController* _playerNotificationController;

	MusicLibrary* _musicLibrary;

	ApplicationWindowController* _applicationWindowController;
	PreferencesWindowController* _preferencesWindowController;
	DesktopWindowController* _desktopWindowController;
	StatusItemController* _statusItemController;
	MusicSearchWindowController* _musicSearchWindowController;
	
	DockTileController* _dockTileController;
	PlayerController* _playerController;
	PlaybackController* _playbackController;
	NowPlayingController* _nowPlayingController;
	
	LastDotFMController* _lastDotFMController;
	
	SkinController* _skinController;

	NSTimer* _repeatActionTimer;
	NSTimer* _delayActionTimer;
	NSTimer* _increaseSoundVolumeDelayTimer;
	NSTimer* _decreaseSoundVolumeDelayTimer;
	
	StarRatingController* _currentRatingController;
}

+ (CoverSutra*)self;

+ (void)setupUserDefaults;

@property(readonly) NSOperationQueue* operationQueue;

@property(readonly) MusicLibrary* musicLibrary;

@property(readonly) PlayerController* playerController;
@property(readonly) PlaybackController* playbackController;
@property(readonly) NowPlayingController* nowPlayingController;
@property(readonly) DockTileController* dockTileController;

@property(readonly) PlayerNotificationController* playerNotificationController;

@property(readonly) SkinController* skinController;

- (void)relaunch;

- (ApplicationWindowController*)applicationWindowController;
- (PreferencesWindowController*)preferencesWindowController;
- (DesktopWindowController*)desktopWindowController;
- (StatusItemController*)statusItemController;
- (MusicSearchWindowController*)musicSearchWindowController;

- (LastDotFMController*)lastDotFMController;

- (NSString*)applicationPreferencesFolder;
- (NSString*)applicationSupportFolder;
- (NSString*)applicationCacheFolder;

- (NSArray*)applicationPlugInFolders;

- (BOOL)dockItemShown;
- (BOOL)statusItemShown;

- (IBAction)orderFrontPurchasePage:(id)sender;
- (IBAction)orderFrontLatestNewsPage:(id)sender;
- (IBAction)orderFrontFeedbackMail:(id)sender;

- (IBAction)orderFrontPreferencesPanel:(id)sender;
- (IBAction)orderFrontAdvancedPreferencesPanel:(id)sender;

- (IBAction)orderFrontApplicationWindow:(id)sender;

@end

// The global CoverSutra applicatioon delegate
extern  CoverSutra* CoverSutraApp;
