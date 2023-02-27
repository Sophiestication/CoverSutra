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

#import "CoverSutra+LoginItems.h"
#import <ServiceManagement/ServiceManagement.h>

@implementation CoverSutra(LoginItems)

- (BOOL)launchAtLogin {
	NSString* appIdentifier = [[NSBundle mainBundle]
		objectForInfoDictionaryKey:(id)kCFBundleNameKey];
	NSString* scriptString = [NSString stringWithFormat:
		@"tell application \"System Events\" \n"
		@"	get the name of every login item \n"
		@"	if login item \"%@\" exists then \n"
		@"		return true \n"
		@"	end if \n"
		@"	return false \n"
		@"end tell \n",
		appIdentifier];
		
	NSAppleScript* script = [[NSAppleScript alloc] initWithSource:scriptString];
	NSDictionary* error = nil;
		
	NSAppleEventDescriptor* result = [script executeAndReturnError:&error];
		
	if(error) {
		NSLog(@"Could not access login items: %@", error);
	}
	
	return [result booleanValue];
}

- (void)setLaunchAtLogin:(BOOL)launchAtLogin {
	NSString* scriptString = nil;
	
	if(launchAtLogin) {
		NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
		scriptString = [NSString stringWithFormat:
			@"tell application \"System Events\" \n"
			@"	make login item at end with properties {path:\"%@\", kind:application} \n"
			@"end tell \n",
			bundlePath];
		
	} else {
		NSString* appIdentifier = [[NSBundle mainBundle]
			objectForInfoDictionaryKey:(id)kCFBundleNameKey];
		scriptString = [NSString stringWithFormat:
			@"tell application \"System Events\" \n"
			@"	get the name of every login item \n"
			@"	if login item \"%@\" exists then \n"
			@"		delete login item \"%@\" \n"
			@"	end if \n"
			@"end tell \n",
			appIdentifier, appIdentifier];
	}
	
	NSAppleScript* script = [[NSAppleScript alloc] initWithSource:scriptString];
	NSDictionary* error = nil;
		
	[script executeAndReturnError:&error];
		
	if(error) {
		NSLog(@"Could not access login items: %@", error);
	}
}

- (BOOL)launchWithPlayer {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"launchWithPlayer"];
}

- (void)setLaunchWithPlayer:(BOOL)launchWithPlayer {
	NSString* bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
	NSString* agentBundleIdentifier = [bundleIdentifier stringByAppendingString:@".agent"];
	
	if(launchWithPlayer) {
		NSURL* agentURL = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:@"Contents/Library/LoginItems/CoverSutraAgent.app" isDirectory:YES];
		OSStatus status = LSRegisterURL((__bridge CFURLRef)agentURL, FALSE);
	
		if(status != noErr) {
//			NSLog(@"Could not register URL %@: %jd", agentURL, status);
		}
	}

	if(!SMLoginItemSetEnabled((__bridge CFStringRef)agentBundleIdentifier, launchWithPlayer)) {
		if(launchWithPlayer) {
			NSLog(@"Could not enable CoverSutra agent.");
		}

//		launchWithPlayer = NO;
	}
	
	[[NSUserDefaults standardUserDefaults] setBool:launchWithPlayer forKey:@"launchWithPlayer"];
}

@end
