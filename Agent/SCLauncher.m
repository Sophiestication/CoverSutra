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

#import "SCLauncher.h"

// iTunes Bundle Identifier
NSString* const iTunesBundleIdentifier = @"com.apple.iTunes";

// CoverSutra Bundle Identifier
NSString* const CoverSutraBundleIdentifier = @"com.sophiestication.mac.CoverSutra";

// App Store Bundle Identifier
NSString* const AppStoreBundleIdentifier = @"com.apple.appstore";

@implementation SCLauncher

@synthesize needsToTerminateAgent = _needsToTerminateAgent;

@dynamic launchAutomatically;
@dynamic terminateAutomatically;

#pragma mark -
#pragma mark Construction & Destruction

- (id)init {
	if((self = [super init])) {
		_needsToTerminateAgent = NO;
	
//		[[NSUserDefaults standardUserDefaults] addSuiteNamed:CoverSutraBundleIdentifier];
		
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
			
		[[NSDistributedNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(appstoreDownloadStatusChanged:)
			name:@"SSNotificationDownloadStatusChanged"
			object:AppStoreBundleIdentifier];
			
		dispatch_async(dispatch_get_main_queue(), ^{
			NSArray* runningApplications = [NSRunningApplication runningApplicationsWithBundleIdentifier:iTunesBundleIdentifier];
			
			if(runningApplications.count > 0) {
				[self launchCoverSutraIfNeeded];
			}
		});
	}
	
	return self;
}

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	
}

#pragma mark -
#pragma mark SCLauncher

- (BOOL)launchAutomatically {
	return YES;
}

- (BOOL)terminateAutomatically {
	return self.launchAutomatically;
}

- (void)launchCoverSutraIfNeeded {
	if(!self.launchAutomatically) { return; }
	
	// Launch CoverSutra if needed
	NSArray* runningApplications = [NSRunningApplication runningApplicationsWithBundleIdentifier:CoverSutraBundleIdentifier];

	if(runningApplications.count > 0) {
		return;
	}
	
	NSURL* CoverSutraBundleURL = [[[[[[NSBundle mainBundle] bundleURL]
		URLByDeletingLastPathComponent]
		URLByDeletingLastPathComponent]
		URLByDeletingLastPathComponent]
		URLByDeletingLastPathComponent];
		
	NSLog(@"%@", [CoverSutraBundleURL path]);
	
	NSString* scriptString = [NSString
		stringWithFormat:@"tell application \"Finder\" to open (POSIX file \"%@\") as alias",
		[CoverSutraBundleURL path]];
	NSAppleScript* script = [[NSAppleScript alloc] initWithSource:scriptString];
	NSDictionary* scriptError = nil;
	
	if(![script executeAndReturnError:&scriptError]) {
		NSLog(@"Could not launch CoverSutra: %@", scriptError);
	}

//	NSError* error = nil;
//
//	NSRunningApplication* application = [[NSWorkspace sharedWorkspace]
//		launchApplicationAtURL:CoverSutraBundleURL
//		options:NSWorkspaceLaunchDefault|NSWorkspaceLaunchWithoutAddingToRecents|NSWorkspaceLaunchWithoutActivation
//		configuration:nil
//		error:&error];
	
//	BOOL launched = [[NSWorkspace sharedWorkspace]
//		launchAppWithBundleIdentifier:CoverSutraBundleIdentifier
//		options:NSWorkspaceLaunchDefault|NSWorkspaceLaunchWithoutAddingToRecents|NSWorkspaceLaunchWithoutActivation
//		additionalEventParamDescriptor:nil
//		launchIdentifier:NULL];
			
//	if(!application || error) {
//		NSLog(@"Could not launch CoverSutra: %@", error);
//	}
}

#pragma mark -
#pragma mark NSWorkspace Notifications

- (void)workspaceDidLaunchApplication:(NSNotification*)notification {
	// Check if iTunes launched
	NSString* applicationBundleIdentifier = [[notification userInfo]
		objectForKey:@"NSApplicationBundleIdentifier"];

	if([applicationBundleIdentifier isEqualToString:iTunesBundleIdentifier]) {
		[self launchCoverSutraIfNeeded];
	}
}

- (void)workspaceDidTerminateApplication:(NSNotification*)notification {
	// Check if iTunes terminated
	NSString* applicationBundleIdentifier = [[notification userInfo]
		objectForKey:@"NSApplicationBundleIdentifier"];

	// Terminate CoverSutra if needed
	if([applicationBundleIdentifier isEqualToString:iTunesBundleIdentifier] && self.terminateAutomatically) {
		NSArray* runningApplications = [NSRunningApplication runningApplicationsWithBundleIdentifier:CoverSutraBundleIdentifier];

		for(NSRunningApplication* application in runningApplications) {
			[application terminate];
		}
	}
}

#pragma mark -
#pragma mark Distributed Notifications

- (void)appstoreDownloadStatusChanged:(NSNotification*)notification {
	NSString* bundleIdentifier = [[notification userInfo] objectForKey:@"bundleidentifier"];
	
	if([bundleIdentifier isEqualToString:CoverSutraBundleIdentifier]) {
		// Quit our agent
		self.needsToTerminateAgent = YES;
	}
}

@end
