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

#import "MusicLibraryQuery+Scripting.h"
#import "MusicLibraryQuery+Private.h"

#import "MusicLibraryTrack.h"

#import "PlaybackController.h"
#import "PlaybackController+Private.h"

#import "CoverSutra.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

@implementation MusicLibraryQuery(Scripting)

- (NSArray*)scriptingObjects {
	NSArray* scriptingObjects = nil;
//	
//	if(!scriptingObjects) {
		NSArray* allLocationURLs = [[self results] valueForKeyPath:@"tracks.@unionOfArrays.locationURL"];
		
		NSMutableArray* locationURLs = [NSMutableArray arrayWithArray:allLocationURLs];
		
		for(NSURL* locationURL in allLocationURLs) {
			if([locationURL isFileURL]) {
				if(![[NSFileManager defaultManager] fileExistsAtPath:[locationURL relativePath]]) {
					[locationURLs removeObject:locationURL];
				}
			}
		}
		
		iTunesApplication* application = CSiTunesApplication();
		iTunesPlaylist* musicSearchPlaylist = [application musicSearchPlaylist];
		
		if(musicSearchPlaylist) {
			[[musicSearchPlaylist tracks] removeAllObjects];
			
			scriptingObjects = (id)[application  add:locationURLs to:musicSearchPlaylist];
			
			if(![scriptingObjects isKindOfClass:[NSArray class]]) {
				scriptingObjects = [NSArray arrayWithObject:scriptingObjects];
			}
		}
		
//		self.scriptingObjects = scriptingObjects;
//	}
	
	return scriptingObjects;
}

- (void)playTrack:(MusicLibraryTrack*)trackToPlay {
	NS_DURING
		// Don't notify
		[[[CoverSutra self] playbackController] setShouldNotNotifyAboutTrackChanges:YES];
		
		// Find the index of this track in our iTunes playlist
		NSArray* trackIDs = [[self results] valueForKeyPath:@"tracks.@unionOfArrays.persistentID"];
		NSUInteger indexOfTrackToPlay = [trackIDs indexOfObject:[trackToPlay persistentID]];
		
		// Retrieve the scripting objects for all search results
		NSArray* scriptingObjects = [self scriptingObjects];
		
		// Find the track we wanna play
		iTunesTrack* scriptingObject = [scriptingObjects objectAtIndex:indexOfTrackToPlay];
		
		// And play it
		[scriptingObject playOnce:NO];
	NS_HANDLER
	NS_ENDHANDLER
}

@end
