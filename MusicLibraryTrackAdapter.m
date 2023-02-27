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

#import "MusicLibraryTrackAdapter.h"

#import "MusicLibraryTrack+Scripting.h"
#import "MusicLibraryTrack+Private.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "NSArray+Additions.h"
#import "NSString+Additions.h"

@implementation MusicLibraryTrackAdapter

@synthesize
	scriptingObject = _scriptingObject,
	playlistScriptingObject = _playlistScriptingObject,
	sourceScriptingObject = _sourceScriptingObject,
	shared = _shared,
	streamed = _streamed;

+ (MusicLibraryTrackAdapter*)adapterForScriptingObject:(iTunesTrack*)scriptingObject {
	MusicLibraryTrackAdapter* adapter = nil;
	
	iTunesTrack* track = nil;
	
	NS_DURING
		// Evaluate if the track exists
		if(![scriptingObject exists]) {
			return nil;
		}
		
		track = [scriptingObject get]; // TODO This should be in NowPlayingController
	
		NSInteger databaseID = track.databaseID;

		adapter = [[MusicLibraryTrackAdapter alloc] initWithTrackID:databaseID];
		
		adapter.persistentID = track.persistentID;
		
		adapter.name = track.name;
		
		adapter.album = track.album;
		adapter.albumArtist = track.albumArtist;
		adapter.artist = track.artist;
		
		adapter.compilation = track.compilation;
		
		adapter.rating = track.rating;
		adapter.ratingComputed = track.ratingKind == iTunesERtKComputed;
		
		adapter.albumRating = track.albumRating;
		adapter.albumRatingComputed = track.albumRatingKind == iTunesERtKComputed;
		
		adapter.trackNumber = track.trackNumber;
		adapter.trackCount = track.trackCount;
		
		adapter.discNumber = track.discNumber;
		adapter.discCount = track.discCount;
		
		adapter.duration = track.duration * 1000.0;
		
		adapter.artworkCount = track.artworks.count;
		
		adapter.podcast = track.podcast;
		
		adapter.lyrics = track.lyrics;
		
		// Set video kinds
		iTunesEVdK videoKind = track.videoKind;
		adapter.TVShow = videoKind == iTunesEVdKTVShow;
		adapter.movie = videoKind == iTunesEVdKMovie;

		adapter.scriptingObject = track;
		adapter.playlistScriptingObject = [[track container] get];
		adapter.sourceScriptingObject = [[[adapter sourceScriptingObject] container] get];
		
//		adapter.libraryPersistentID = adapter.sourceScriptingObject.persistentID;
		
		iTunesApplication* application = CSiTunesApplication();
	
		adapter.shared = [track isKindOfClass:[application classForScriptingClass:@"shared track"]];
		adapter.streamed = [track isKindOfClass:[application classForScriptingClass:@"URL track"]];

		if([track respondsToSelector:@selector(location)]) {
			adapter.location = [[(iTunesAudioCDTrack*)track location] absoluteString];
		}
		
		if(adapter.streamed) {
			[adapter refreshStream];
		}
	
	NS_HANDLER
		NSLog(@"Error in MusicLibraryTrackAdapter: %@", localException);
	NS_ENDHANDLER

	return adapter;
}

+ (MusicLibraryTrackAdapter*)adapterForPlayerNotification:(NSNotification*)playerNotification {
//	NSLog(@"%@", playerNotification);
	
	NSDictionary* userInfo = [playerNotification userInfo];
	MusicLibraryTrackAdapter* adapter = [[MusicLibraryTrackAdapter alloc] initWithTrackID:-1];
		
	adapter.name = [userInfo objectForKey:@"Name"];
	
	adapter.album = [userInfo objectForKey:@"Album"];
	adapter.albumArtist = [userInfo objectForKey:@"Album Artist"];
	adapter.artist = [userInfo objectForKey:@"Artist"];
		
	adapter.compilation = [[userInfo objectForKey:@"Compilation"] boolValue];
		
	adapter.rating = [[userInfo objectForKey:@"Rating"] integerValue];
		
	adapter.duration = [[userInfo objectForKey:@"Total Time"] integerValue];
	
	adapter.trackNumber = [[userInfo objectForKey:@"Track Number"] integerValue];
	adapter.trackCount = [[userInfo objectForKey:@"Track Count"] integerValue];
	
	adapter.discNumber = [[userInfo objectForKey:@"Disc Number"] integerValue];
	adapter.discCount = [[userInfo objectForKey:@"Disc Count"] integerValue];
	
	adapter.location = [userInfo objectForKey:@"Location"];
	
	NSString* streamURL = [userInfo objectForKey:@"Stream URL"];
	NSString* streamTitle = [userInfo objectForKey:@"Stream Title"];
	
	if(!IsEmpty(streamTitle)) {
		NSArray* streamingInfo = [streamTitle componentsSeparatedByString:@" - "];
		
		adapter.artist = [streamingInfo firstObject];
		adapter.name = streamingInfo.count >= 2 ? [streamingInfo objectAtIndex:1] : nil;
		adapter.album = streamingInfo.count >= 3 ? [streamingInfo objectAtIndex:2] : nil;
	}
	
	adapter.streamed = !IsEmpty(streamTitle) || !IsEmpty(streamURL);
	
	return adapter;
}

- (NSDictionary*)scriptingObjects {
	NSDictionary* scriptingObjects = [NSDictionary dictionaryWithObjectsAndKeys:
		self.scriptingObject, @"track",
		self.playlistScriptingObject, @"playlist",
		self.sourceScriptingObject, @"source",
		nil];
				
	return scriptingObjects;
}


- (void)refresh {
	NS_DURING
		iTunesTrack* scriptingObject = self.scriptingObject;
		
		self.rating = scriptingObject.rating;
		self.ratingComputed = scriptingObject.ratingKind == iTunesERtKComputed;
		
		self.albumRating = scriptingObject.albumRating;
		self.albumRatingComputed = scriptingObject.albumRatingKind == iTunesERtKComputed;
	
		[self refreshStream];
	NS_HANDLER
	NS_ENDHANDLER
}

- (void)refreshStream {
	NS_DURING
		if(self.streamed) {
			self.album = self.name;
			self.name = [CSiTunesApplication() currentStreamTitle];
			self.artist = [CSiTunesApplication() currentStreamURL];
		}
	NS_HANDLER
	NS_ENDHANDLER
}

@end
