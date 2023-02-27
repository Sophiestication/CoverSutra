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

#import "MPMediaLibraryImporter.h"
#import "MPMediaLibraryImporter+Private.h"

#import "MPMediaLibraryParser.h"

#import "NSArray+Additions.h"
#import "NSString+Additions.h"

@implementation MPMediaLibraryImporter

@synthesize tracks = _tracks;
@synthesize playlists = _playlists;
@synthesize currentPlaylistID = _currentPlaylistID;

#pragma mark -
#pragma mark Construction & Destruction

- (id)init {
	if(self = [super init]) {
		self.tracks = [NSMutableArray arrayWithCapacity:2000];
		self.playlists = [NSMutableArray arrayWithCapacity:25];

		// ...
		self.currentPlaylistID = 0;
		_threshold = 0;
	}
	
	return self;
}

#pragma mark -
#pragma mark MPMediaLibraryImporter

- (BOOL)importFromPropertyList:(NSURL*)propertyListURL {
	BOOL result = YES;
	
	@autoreleasepool {
	
		NSError* error = nil;
		MPMediaLibraryParser* parser = [[MPMediaLibraryParser alloc] initWithURL:propertyListURL delegate:self error:&error];
	
		// Check for errors
		if(!parser || error) {
			if([[error domain] isEqualToString:NSXMLParserErrorDomain] && error.code == NSXMLParserInvalidCharacterError) {
				NSLog(@"iTunes Media Library file is corrupt. Try to delete %@ and restart iTunes to resolve.", [propertyListURL path]);
			} else {
				NSLog(@"Error in %@: %@", NSStringFromClass([self class]), error);
			}

			result = NO;
		}

//	// Drain the internal autorelease pool if needed
//	[_pool drain], _pool = nil;
	
	}

	return result;
}

#pragma mark -
#pragma mark MPMediaLibraryParserDelegate

- (void)musicLibraryParserWillStartParsingTrack:(MPMediaLibraryParser*)parser {
//	if(!_pool || _threshold >= 100) {
//		[_pool drain], _pool = [[NSAutoreleasePool alloc] init];
//		_threshold = 0;
//	}
	
	_currentTrack = [[MusicLibraryTrack alloc] initWithTrackID:-1]; // We parse the track ID later on
	
//	_currentTrack.libraryPersistentID = nil; // TODO
	
//	++_threshold;
}

- (void)musicLibraryParser:(MPMediaLibraryParser*)parser parsedTrackProperty:(NSString*)property value:(NSString*)value {
	if(SFEqualStrings(property, @"Track ID")) {
		_currentTrack.trackID = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Persistent ID")) {
		_currentTrack.persistentID = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Name")) {
		_currentTrack.name = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Artist")) {
		_currentTrack.artist = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Album")) {
		_currentTrack.album = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Album Artist")) {
		_currentTrack.albumArtist = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Composer")) {
		_currentTrack.composer = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Grouping")) {
		_currentTrack.grouping = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Comments")) {
		_currentTrack.comments = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Rating")) {
		_currentTrack.rating = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Rating Computed")) {
		_currentTrack.ratingComputed = [self parseBooleanValue:value];
	} else if(SFEqualStrings(property, @"Album Rating")) {
		_currentTrack.albumRating = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Album Rating Computed")) {
		_currentTrack.albumRatingComputed = [self parseBooleanValue:value];
	} else if(SFEqualStrings(property, @"Play Count")) {
		_currentTrack.playCount = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Location")) {
		_currentTrack.location = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Track Number")) {
		_currentTrack.trackNumber = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Track Count")) {
		_currentTrack.trackCount = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Disc Number")) {
		_currentTrack.discNumber = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Disc Count")) {
		_currentTrack.discCount = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Artwork Count")) {
		_currentTrack.artworkCount = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Compilation")) {
		_currentTrack.compilation = [self parseBooleanValue:value];
	} else if(SFEqualStrings(property, @"Total Time")) {
		_currentTrack.duration = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Movie")) {
		_currentTrack.movie = [self parseBooleanValue:value];
	} else if(SFEqualStrings(property, @"Podcast")) {
		_currentTrack.podcast = [self parseBooleanValue:value];
	} else if(SFEqualStrings(property, @"TV Show")) {
		_currentTrack.TVShow = [self parseBooleanValue:value];
	} else if(SFEqualStrings(property, @"Disabled")) {
		_currentTrack.disabled = [self parseBooleanValue:value];
	}/* else if(SFEqualStrings(property, @"Date Added")) {
		_currentTrack.dateAdded = [self parseDateValue:value];
	}*/
}

- (void)musicLibraryParserDidStopParsingTrack:(MPMediaLibraryParser*)parser {
	if(_currentTrack) {
		if(!_currentTrack.podcast && !_currentTrack.movie && !_currentTrack.TVShow) {
			[[self tracks] addObject:_currentTrack];
		}
		
		_currentTrack = nil;
	}
}

- (void)musicLibraryParserWillStartParsingPlaylist:(MPMediaLibraryParser*)parser {
//	if(!_pool || _threshold >= 100) {
//		[_pool drain], _pool = [[NSAutoreleasePool alloc] init];
//		_threshold = 0;
//	}
	
	_currentPlaylist = [[MusicLibraryPlaylist alloc] init];
	
//	++_threshold;
}

- (void)musicLibraryParser:(MPMediaLibraryParser*)parser parsedPlaylistProperty:(NSString*)property value:(NSString*)value {
	if(SFEqualStrings(property, @"Playlist ID")) {
		_currentPlaylist.playlistID = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Playlist Persistent ID")) {
		_currentPlaylist.persistentID = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Parent Persistent ID")) {
		_currentPlaylist.parentPersistentID = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Name")) {
		_currentPlaylist.name = [self parseStringValue:value];
	} else if(SFEqualStrings(property, @"Distinguished Kind")) {
		_currentPlaylist.distinguishedKind = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Genius Track ID")) {
		_currentPlaylist.geniusTrackID = [self parseIntegerValue:value];
	} else if(SFEqualStrings(property, @"Music")) {
		_currentPlaylist.type = MusicLibraryMusicPlaylistType;
	} else if(SFEqualStrings(property, @"Master")) {
		_currentPlaylist.type = MusicLibraryMasterPlaylistType;
	} else if(SFEqualStrings(property, @"Movies")) {
		_currentPlaylist.type = MusicLibraryMoviesPlaylistType;
	} else if(SFEqualStrings(property, @"TV Shows")) {
		_currentPlaylist.type = MusicLibraryTVShowsPlaylistType;
	} else if(SFEqualStrings(property, @"Podcasts")) {
		_currentPlaylist.type = MusicLibraryPodcastsPlaylistType;
	} else if(SFEqualStrings(property, @"iTunesU")) {
		_currentPlaylist.type = MusicLibraryiTunesUPlaylistType;
	} else if(SFEqualStrings(property, @"Audiobooks")) {
		_currentPlaylist.type = MusicLibraryAudiobooksPlaylistType;
	} else if(SFEqualStrings(property, @"Games")) {
		_currentPlaylist.type = MusicLibraryGamesPlaylistType;
	} else if(SFEqualStrings(property, @"Radio")) {
		_currentPlaylist.type = MusicLibraryRadioPlaylistType;
	} else if(SFEqualStrings(property, @"Ringtones")) {
		_currentPlaylist.type = MusicLibraryRingtonesPlaylistType;
	} else if(SFEqualStrings(property, @"Purchased Music")) {
		_currentPlaylist.type = MusicLibraryPurchasesPlaylistType;
	} else if(SFEqualStrings(property, @"Party Shuffle")) {
		_currentPlaylist.type = MusicLibraryPartyShufflePlaylistType;
	} else if(SFEqualStrings(property, @"Folder")) {
		_currentPlaylist.type = MusicLibraryFolderPlaylistType;
	} else if(SFEqualStrings(property, @"Smart Info")) {
		if(_currentPlaylist.type == MusicLibraryUnknownPlaylistType) {
			_currentPlaylist.type = MusicLibrarySmartPlaylistType;
		}
	} else if(SFEqualStrings(property, @"Visible")) {
		_currentPlaylist.visible = [self parseBooleanValue:value];
	}
}

- (void)musicLibraryParser:(MPMediaLibraryParser*)parser parsedPlaylistTrack:(NSString*)trackID {
//	if(!_pool || _threshold >= 200) {
//		[_pool drain], _pool = [[NSAutoreleasePool alloc] init];
//		_threshold = 0;
//	}
	
	// TODO
	
//	++_threshold;
}

- (void)musicLibraryParserDidStopParsingPlaylist:(MPMediaLibraryParser*)parser {
	if(_currentPlaylist) {
		if(_currentPlaylist.type == MusicLibraryUnknownPlaylistType) {
			_currentPlaylist.type = MusicLibraryUserPlaylistType;
		}
		
		[[self playlists] addObject:_currentPlaylist];
		_currentPlaylist = nil;
	}
}

#pragma mark -
#pragma mark Private

- (NSString*)parseStringValue:(NSString*)buffer {
//	NSString* stringValue = [[[NSString alloc] initWithData:buffer encoding:NSUTF8StringEncoding] autorelease];
//	return stringValue;

	return buffer;
}

- (NSInteger)parseIntegerValue:(NSString*)buffer {
//	NSInteger integerValue;
//	
//	NSString* stringValue = [[NSString alloc] initWithBytesNoCopy:(void*)[buffer bytes] length:[buffer length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
//	
//	integerValue = [stringValue integerValue];
//	
//	[stringValue release];
//	
//	return integerValue;

	return [buffer integerValue];
}

- (NSDate*)parseDateValue:(NSString*)buffer {
	return nil;
}

- (BOOL)parseBooleanValue:(NSString*)buffer {
	return YES;

/*
	BOOL booleanValue;
	
	NSString* stringValue = [[NSString alloc] initWithBytesNoCopy:(void*)[buffer bytes] length:[buffer length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
	
	booleanValue = [stringValue isEqualToString:@"true"];
	
	[stringValue release];
	
	return booleanValue;
*/
}

@end
