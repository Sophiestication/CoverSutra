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

#import "MusicLibraryTrack+Scripting.h"

#import "MusicLibraryPlaylist.h"
#import "MusicLibraryPlaylist+Scripting.h"

#import "MusicLibrary.h"
#import "MusicLibrary+Scripting.h"
#import "MusicLibrary+Private.h"

#import "PlaybackController.h"
#import "PlaybackController+Private.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "CoverSutra.h"

#import "NSArray+Additions.h"

#import "Utilities.h"

@implementation MusicLibraryTrack(Scripting)

- (NSDictionary*)scriptingObjects {
	/*NS_DURING
		iTunesPlaylist* currentPlaylist = [[CSiTunesApplication() currentPlaylist] get];
		iTunesTrack* track = [currentPlaylist scriptingObjectForTrack:self];
		
		if(track) {
			NSDictionary* scriptingObjects = [NSDictionary dictionaryWithObjectsAndKeys:
				track, @"track",
				currentPlaylist, @"playlist",
				nil];
		
			NS_VALUERETURN(scriptingObjects, NSDictionary);
		}
	NS_HANDLER
	NS_ENDHANDLER*/
	
	return [self sourceScriptingObjects];
}

- (iTunesTrack*)scriptingObject {
	return [[self scriptingObjects] objectForKey:@"track"];
}

- (NSDictionary*)sourceScriptingObjects {
	NS_DURING
		iTunesSource* source = [[[CoverSutra self] musicLibrary] scriptingObject];
		iTunesESpK specialKind = iTunesESpKMusic;
		
		if(self.movie) { specialKind = iTunesESpKMovies; }
		if(self.podcast) { specialKind = iTunesESpKPodcasts; }
		if(self.TVShow) { specialKind = iTunesESpKTVShows; }
		
		NSArray* specialKinds = [[source playlists] arrayByApplyingSelector:@selector(specialKind)];
		NSInteger playlistIndex = 0;
		
		iTunesPlaylist* playlist = nil;
		
		for(NSAppleEventDescriptor* descriptor in specialKinds) {
			if([descriptor enumCodeValue] == specialKind) {
				playlist = [[source playlists] objectAtIndex:playlistIndex];
				break;
			}
			
			++playlistIndex;
		}
		
		iTunesTrack* track = [playlist scriptingObjectForTrack:self];
		
		if(track) {
			NSDictionary* scriptingObjects = [NSDictionary dictionaryWithObjectsAndKeys:
				track, @"track",
				playlist, @"playlist",
				nil];
		
			NS_VALUERETURN(scriptingObjects, NSDictionary);
		}
	NS_HANDLER
	NS_ENDHANDLER
	
	return nil;
}

- (void)play {
	NS_DURING
		NSDictionary* scriptingObjects = [self scriptingObjects];
			
		// selectInBrowserWindow leaks memory :-|
		// Select the playlist in the main browser window
		// iTunesPlaylist* playlist = [scriptingObjects objectForKey:@"playlist"];
		// [playlist selectInBrowserWindow];
			
		// Tell our playback controller to ignore the next player notification
		[[[CoverSutra self] playbackController] setShouldNotNotifyAboutTrackChanges:YES];
		
		// Play the track
		iTunesTrack* track = [scriptingObjects objectForKey:@"track"];
		[track playOnce:NO];
	NS_HANDLER
		NSLog(@"Error in music library track: %@", localException);
	NS_ENDHANDLER
}

- (void)playNextInPartyShuffle {
	NS_DURING
		// TODO
	NS_HANDLER
		NSLog(@"Error in music library track: %@", localException);
	NS_ENDHANDLER
}

- (void)addToPlaylist:(iTunesPlaylist*)playlist {
	NS_DURING
		[[self scriptingObject] duplicateTo:playlist];
	NS_HANDLER
		NSLog(@"Error in music library track: %@", localException);
	NS_ENDHANDLER
}

- (void)show {
	NS_DURING
		[CSiTunesApplication() activate];
		[[self scriptingObject] reveal];
	NS_HANDLER
		NSLog(@"Error in music library track: %@", localException);
	NS_ENDHANDLER
}

- (void)showInFinder {
	NSURL* locationURL = self.locationURL;
	
	if(!locationURL) { return; }
	
	[[NSWorkspace sharedWorkspace]
		activateFileViewerSelectingURLs:[NSArray arrayWithObject:locationURL]];
}

@end
