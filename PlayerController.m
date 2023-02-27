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

#import "PlayerController.h"
#import "PlayerController+Private.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "NSString+Additions.h"

NSString* const iTunesBundleIdentifier = @"com.apple.iTunes";
NSString* const QuicktimePlayerBundleIdentifier = @"com.apple.quicktimeplayer";
NSString* const QuicktimePlayerXBundleIdentifier = @"com.apple.QuickTimePlayerX";
NSString* const FrontRowBundleIdentifier = @"com.apple.frontrow";
NSString* const DVDPlayerBundleIdentifier = @"com.apple.DVDPlayer";
NSString* const iPhotoBundleIdentifier = @"com.apple.iPhoto";

NSString* const iTunesWillFinishLaunchingNotification = @"com.sophiestication.CoverSutra.iTunesWillFinishLaunching";
NSString* const iTunesDidTerminateNotification = @"com.sophiestication.CoverSutra.iTunesDidTerminate";

NSString* const FrontRowWillFinishLaunchingNotification = @"TODO";
NSString* const FrontRowDidTerminateNotification  = @"TODO";

@implementation PlayerController

@synthesize
	iTunesIsBusy = _iTunesIsBusy,
	iTunesIsCurrentPlayer = _iTunesIsCurrentPlayer;

@synthesize frontmostApplication = _frontmostApplication;

@dynamic iTunesIsRunning;
@dynamic iTunesIsFrontmost;

- (id)init {
	if(![super init]) {
		return nil;
	}

	_iTunesIsBusy = NO;
	_iTunesIsCurrentPlayer = YES;
	
	self.frontmostApplication = [NSRunningApplication currentApplication];
	
	[self refreshCurrentPlayer:self];

	[[[NSWorkspace sharedWorkspace] notificationCenter]
		addObserver:self
		selector:@selector(workspaceDidLaunchApplication:)
		name:NSWorkspaceDidLaunchApplicationNotification
		object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter]
		addObserver:self
		selector:@selector(workspaceDidTerminateApplication:)
		name:NSWorkspaceDidTerminateApplicationNotification
		object:nil];
		
	[[[NSWorkspace sharedWorkspace] notificationCenter]
		addObserver:self
		selector:@selector(workspaceDidActivateApplication:)
		name:NSWorkspaceDidActivateApplicationNotification
		object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter]
		addObserver:self
		selector:@selector(workspaceDidDeactivateApplication:)
		name:NSWorkspaceDidDeactivateApplicationNotification
		object:nil];

	[[NSDistributedNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(dialogInfoDidChange:)
		name:@"com.apple.iTunes.dialogInfo"
		object:@"com.apple.iTunes.dialog"
		suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately];
	
	return self;
}

- (void)dealloc {

	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	
}

- (BOOL)iTunesIsRunning {
	NSArray* applications = [NSRunningApplication runningApplicationsWithBundleIdentifier:iTunesBundleIdentifier];
	return [applications count] > 0;
}

- (BOOL)iTunesIsFrontmost {
	return EqualStrings([[self frontmostApplication] bundleIdentifier], iTunesBundleIdentifier);
}

- (void)setITunesIsFrontmost:(BOOL)frontmost {
	NSArray* applications = [NSRunningApplication runningApplicationsWithBundleIdentifier:iTunesBundleIdentifier];
	
	for(NSRunningApplication* application in applications) {
		if(frontmost) {
			[application activateWithOptions:NSApplicationActivateAllWindows|NSApplicationActivateIgnoringOtherApps];
		} else {
			[application hide];
		}
	}
	
	if(frontmost && !self.iTunesIsBusy) {
		NS_DURING
			iTunesApplication* application = CSiTunesApplication();
			[[[application browserWindows] objectAtIndex:0] setVisible:YES];
		NS_HANDLER
		NS_ENDHANDLER
	}
}

- (void)refreshCurrentPlayer:(id)sender {
	NSString* bundleIdentifier = [[self frontmostApplication] bundleIdentifier];
	
	if(EqualStrings(bundleIdentifier, iTunesBundleIdentifier)) {
		self.iTunesIsCurrentPlayer = YES;
		return;
	}
		
	if(EqualStrings(bundleIdentifier, QuicktimePlayerBundleIdentifier) ||
	   EqualStrings(bundleIdentifier, QuicktimePlayerXBundleIdentifier) ||
	   EqualStrings(bundleIdentifier, FrontRowBundleIdentifier) ||
	   EqualStrings(bundleIdentifier, DVDPlayerBundleIdentifier) ||
	   EqualStrings(bundleIdentifier, iPhotoBundleIdentifier)) {
		self.iTunesIsCurrentPlayer = NO;
		return;
	}
}

- (void)workspaceDidLaunchApplication:(NSNotification*)notification {
	NSString* applicationBundleIdentifier = [[notification userInfo]
		objectForKey:@"NSApplicationBundleIdentifier"];
	
	if([applicationBundleIdentifier isEqualToString:iTunesBundleIdentifier]) {
		[self willChangeValueForKey:@"iTunesIsRunning"];
		[self didChangeValueForKey:@"iTunesIsRunning"];
		
		[[NSNotificationCenter defaultCenter]
			postNotificationName:iTunesWillFinishLaunchingNotification
			object:self];
	}
}

- (void)workspaceDidTerminateApplication:(NSNotification*)notification {
	NSString* applicationBundleIdentifier = [[notification userInfo]
		objectForKey:@"NSApplicationBundleIdentifier"];
	
	if([applicationBundleIdentifier isEqualToString:iTunesBundleIdentifier]) {
		[self willChangeValueForKey:@"iTunesIsRunning"];
		[self didChangeValueForKey:@"iTunesIsRunning"];
		
		[[NSNotificationCenter defaultCenter]
			postNotificationName:iTunesDidTerminateNotification
			object:self];
	}
}

- (void)workspaceDidActivateApplication:(NSNotification*)notification {
	self.frontmostApplication = [[notification userInfo] objectForKey:NSWorkspaceApplicationKey];

	[self refreshCurrentPlayer:notification];
}

- (void)workspaceDidDeactivateApplication:(NSNotification*)notification {
	[self refreshCurrentPlayer:notification];
}

- (void)dialogInfoDidChange:(NSNotification*)notification {
	NSDictionary* dialogInfo = [notification userInfo];
	
	BOOL iTunesIsModal = [[dialogInfo objectForKey:@"Showing Dialog"] boolValue];
	self.iTunesIsBusy = iTunesIsModal;
}

@end
