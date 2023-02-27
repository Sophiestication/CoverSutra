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

#import "PreferencesWindowController+General.h"
#import "PreferencesWindowController+Private.h"

#import "CoverSutra.h"
#import "CoverSutra+LoginItems.h"

#import "SCApplication.h"

#import "DesktopWindowController.h"

#import "NSBundle+Additions.h"

@implementation PreferencesWindowController(General)

- (IBAction)launchCoverSutraOnLogin:(id)sender {
	BOOL shouldLaunch = [sender state] == NSOnState;
	[[CoverSutra self] setLaunchAtLogin:shouldLaunch];
}

- (IBAction)launchCoverSutraWithiTunes:(id)sender {
	BOOL shouldLaunch = [sender state] == NSOnState;
	[[CoverSutra self] setLaunchWithPlayer:shouldLaunch];
}

- (IBAction)updateDockItem:(id)sender {
	BOOL dockItemShown = [sender state] == NSOnState;

	[[NSUserDefaultsController sharedUserDefaultsController]
		setValue:[NSNumber numberWithBool:dockItemShown]
		forKeyPath:@"values.dockItemShown"];
	
	// Allow to restart
	NSAlert* alert = [NSAlert alertWithMessageText:NSLocalizedString(@"RESTARTREQUIRED_TEXT", @"")
		defaultButton:NSLocalizedString(@"RESTARTNOW_BUTTONTEXT", @"")
		alternateButton:NSLocalizedString(@"LATER_BUTTONTEXT", @"")
		otherButton:nil
		informativeTextWithFormat:NSLocalizedString(@"RESTART_APPLICATION_INFORMATIVETEXT", @"")];
	
	if([alert runModal] == NSAlertDefaultReturn) {
		[[CoverSutra self] relaunch];
	}
}

- (IBAction)updateStatusItem:(id)sender {
	BOOL statusItemShown = [sender state] == NSOnState;
	
	[[NSUserDefaultsController sharedUserDefaultsController]
		setValue:[NSNumber numberWithBool:statusItemShown]
		forKeyPath:@"values.statusItemShown"];
}

- (IBAction)updateDesktopWindow:(id)sender {
	DesktopWindowController* desktopWindowController = [[CoverSutra self] valueForKeyPath:@"desktopWindowController"];
	[desktopWindowController updateFromUserDefaults];
}

- (void)_initGeneralPreferences {
	// Setup launch at login option
	[launchAtLogin setState:
		[[CoverSutra self] launchAtLogin] ? NSOnState : NSOffState];
		
	// Setup launch with iTunes option
	[launchWithiTunes setState:
		[[CoverSutra self] launchWithPlayer] ? NSOnState : NSOffState];
		
	// Setup status item option
	[showStatusItem setState:
		[[CoverSutra self] statusItemShown] ? NSOnState : NSOffState];
	
	// Setup dock item option
	[showDockItem setState:
		[[CoverSutra self] dockItemShown] ? NSOnState : NSOffState];

//	BOOL isApplicationBundleWriteable = [[NSFileManager defaultManager] isWritableFileAtPath:
//		[[NSBundle mainBundle] infoDictionaryPath]];
	[showDockItem setEnabled:YES];
}

@end
