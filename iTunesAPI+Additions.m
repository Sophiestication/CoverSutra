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

#import "iTunesAPI+Additions.h"

#import "PlayerController.h"
#import "PlaybackController.h"

#import "MusicLibrary.h"
#import "MusicLibrary+Scripting.h"
#import "MusicLibraryTrack.h"

#import "CoverSutra.h"

#import "NSArray+Additions.h"

@implementation SBApplication(iTunesApplicationAdditions)

@dynamic
	applicationBundle,
	playerState2,
	selectedPlaylist;
	
iTunesApplication* CSiTunesApplication(void) {
	NSMutableDictionary* threadDictionary = [[NSThread currentThread] threadDictionary];
	id application = [threadDictionary objectForKey:@"CSiTunesApplication"];
	
	if(!application) {
		application = [SBApplication applicationWithBundleIdentifier:iTunesBundleIdentifier];
		
		[application setLaunchFlags:kLSLaunchDontAddToRecents|kLSLaunchDontSwitch|kLSLaunchAsync];
//		[application setSendMode:kAEProcessNonReplyEvents];
		[application setTimeout:2 * 60.0]; // 2s timeout in ticks
		
		[threadDictionary setObject:application forKey:@"CSiTunesApplication"];
	}
	
	return application;
}
	
- (NSBundle*)applicationBundle {
	NSString* path = [[NSWorkspace sharedWorkspace]
		absolutePathForAppBundleWithIdentifier:iTunesBundleIdentifier];
	NSBundle* applicationBundle = [NSBundle bundleWithPath:path];
	
	return applicationBundle;
}

- (NSString*)playerState2 {
	iTunesApplication* application = (id)self;
	iTunesEPlS playerState = application.playerState;

	switch(playerState) {
		case iTunesEPlSPlaying:
			return PlayingPlayerState;
		break;
		
		case iTunesEPlSPaused:
			return PausedPlayerState;
		break;
		
		case iTunesEPlSFastForwarding:
			return FastForwardingPlayerState;
		break;
		
		case iTunesEPlSRewinding:
			return RewindingPlayerState;
		break;
		
		case iTunesEPlSStopped:
			return StoppedPlayerState;
		break;
	}
	
	return StoppedPlayerState;
}

- (iTunesPlaylist*)selectedPlaylist {
	iTunesApplication* application = (id)self;
	return [(iTunesBrowserWindow*)[[application browserWindows] firstObject] view];
}

- (iTunesPlaylist*)musicSearchPlaylist {
	NSString* playlistName = @"CoverSutra";
		
	iTunesSource* library = [[[CoverSutra self] musicLibrary] scriptingObject];
	iTunesPlaylist* playlist = [[library playlists] objectWithName:playlistName];

	if(![playlist exists]) {
		Class playlistClass = [self classForScriptingClass:@"user playlist"];
		NSDictionary* properties = [NSDictionary dictionaryWithObjectsAndKeys:
			playlistName, @"name",
			nil];
		playlist = [[playlistClass alloc] initWithProperties:properties];

		[[library userPlaylists] insertObject:playlist atIndex:0];
	}
	
	return playlist;
}

@end

@implementation SBObject(iTunesPlaylistAdditions)

- (iTunesTrack*)trackWithPersistentID:(NSString*)persistentID {
	iTunesTrack* track = nil;
	
	NS_DURING
		if(persistentID) {
			NSPredicate* filterPredicate = [NSPredicate predicateWithFormat:@"persistentID == %@", persistentID];

			track = [[[[(iTunesPlaylist*)self tracks]
				filteredArrayUsingPredicate:filterPredicate]
				firstObject]
				get];
		}
	NS_HANDLER
//		NSLog(@"%@", localException);
	NS_ENDHANDLER
	
	return track;
}

- (iTunesTrack*)scriptingObjectForTrack:(MusicLibraryTrack*)track {
	return [self trackWithPersistentID:[track persistentID]];
}

- (void)selectInBrowserWindow {
	NS_DURING
		iTunesPlaylist* playlist = [self get];
		[(iTunesBrowserWindow*)[[CSiTunesApplication() browserWindows] firstObject] setView:playlist]; // Leaky?
	NS_HANDLER
	NS_ENDHANDLER
}

@end
