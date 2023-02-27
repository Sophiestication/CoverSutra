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

#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Scripting.h"
#import "MusicLibraryTrack+Private.h"

#import "MusicLibraryPlaylist.h"

#import "MusicLibrary.h"

#import "CoverSutra.h"

#import "NSString+Additions.h"
#import "NSString+iTunesRating.h"

#import "Utilities.h"

@implementation MusicLibraryTrack

@dynamic shared;
@dynamic streamed;

@dynamic displayAlbum;
@dynamic displayArtist;
@dynamic displayAlbumArtist;
@dynamic displayName;
@dynamic normalizedRating;
@dynamic displayRating;
@dynamic displayAlbumRating;
@dynamic displayTrackNumber;
@dynamic durationInSeconds;
@dynamic time;
@dynamic locationURL;

@synthesize
	trackID = _trackID,
	persistentID = _persistentID,
	libraryPersistentID = _libraryPersistentID,
	movie = _movie,
	podcast = _podcast,
	TVShow = _TVShow,
	disabled = _disabled,
	name = _name,
	album = _album,
	artist = _artist,
	albumArtist = _albumArtist,
	composer = _composer,
	grouping = _grouping,
	genre = _genre,
	comments = _comments,
	lyrics = _lyrics,
	dateAdded = _dateAdded,
	releaseDate = _releaseDate,
	compilation = _compilation,
	rating = _rating,
	ratingComputed = _ratingComputed,
	albumRating = _albumRating,
	albumRatingComputed = _albumRatingComputed,
	playCount = _playCount,
	trackNumber = _trackNumber,
	trackCount = _trackCount,
	discNumber = _discNumber,
	discCount = _discCount,
	duration = _duration,
	recordingYear = _recordingYear,
	artworkCount = _artworkCount,
	custom1 = _custom1,
	location = _location,
	storePreview = _storePreview;

+ (NSSet*)keyPathsForValuesAffectingNormalizedRating { return [NSSet setWithObject:@"rating"]; }
+ (NSSet*)keyPathsForValuesAffectingDisplayRating { return [NSSet setWithObjects:@"rating", @"ratingComputed", nil]; }
+ (NSSet*)keyPathsForValuesAffectingDisplayAlbumRating { return [NSSet setWithObjects:@"albumRating", @"albumRatingComputed", nil]; }

- (id)initWithTrackID:(NSUInteger)trackID {
	if((self = [super init])) {
		_trackID = trackID;
	
		_movie = _podcast = _TVShow = NO;
		_disabled = NO;
	
		_rating = 0;
		_ratingComputed = NO;
	
		_albumRating = 0;
		_albumRatingComputed = NO;
	
		_playCount = 0;
	
		_compilation = NO;
	
		_trackNumber = -1;
		_trackCount = -1;
	
		_discNumber = -1;
		_discCount = -1;
	
		_duration = 0;
	
		_recordingYear = -1;
	
		_artworkCount = 0;
		
		_storePreview = NO;
	}

	return self;
}

- (id)copyWithZone:(NSZone*)zone {
	MusicLibraryTrack* copy = [[[self class] alloc] initWithTrackID:self.trackID];
	
	copy.persistentID = self.persistentID;
	
	copy.libraryPersistentID = self.libraryPersistentID;
	
	copy.movie = self.movie;
	copy.podcast = self.podcast;
	copy.TVShow = self.TVShow;
	
	copy.disabled = self.disabled;
	
	copy.name = self.name;
	copy.album = self.album;
	copy.artist = self.artist;
	copy.albumArtist = self.albumArtist;
	copy.composer = self.composer;
	copy.grouping = self.grouping;
	
	copy.genre = self.genre;
	
	copy.comments = self.comments;
	copy.lyrics = self.lyrics;
	
	copy.dateAdded = self.dateAdded;
	copy.releaseDate = self.releaseDate;
	
	copy.compilation = self.compilation;
	
	copy.rating = self.rating;
	copy.ratingComputed = self.ratingComputed;
	
	copy.albumRating = self.albumRating;
	copy.albumRatingComputed = self.albumRatingComputed;
	
	copy.playCount = self.playCount;
	
	copy.trackNumber = self.trackNumber;
	copy.trackCount = self.trackCount;
	
	copy.discNumber = self.discNumber;
	copy.discCount = self.discCount;
	
	copy.duration = self.duration;
	
	copy.recordingYear = self.recordingYear;
	
	copy.artworkCount = self.artworkCount;
	
//	copy.custom1 = self.custom1;
	
	copy.location = self.location;

	return copy;
}


- (BOOL)isShared {
	return NO;
}

- (BOOL)isStreamed {
	return NO;
}

- (NSString*)displayName {
//	NSInteger trackNumber = self.trackNumber;
//	
//	if(trackNumber >= 0) {
//		return [NSString stringWithFormat:@"%02ld %@", (long)trackNumber, self.name];
//	}

	if(!IsEmpty(self.name)) {
		return self.name;
	}
	
	return NSLocalizedString(@"MEDIALIBRARY_NO_TITLE", @"Missing track title description");
}

- (NSString*)displayArtist {
	if(!IsEmpty(self.artist)) {
		return self.artist;
	}
	
	if(self.streamed) {
		return NSLocalizedString(@"MEDIALIBRARY_NO_STREAMURL", @"Missing stream URL description");
	}
	
	return NSLocalizedString(@"MEDIALIBRARY_NO_ARTIST", @"Missing artist description");
}

- (NSString*)displayAlbum {
	if(!IsEmpty(self.album)) {
		return self.album;
	}
	
	if(!IsEmpty(self.grouping)) {
		return self.grouping;
	}
	
	return NSLocalizedString(@"MEDIALIBRARY_NO_ALBUM", @"Missing album description");
}

- (NSString*)displayAlbumArtist {
	if(!IsEmpty(self.albumArtist)) {
		return self.albumArtist;
	}
	
	return self.displayArtist;
}

- (NSInteger)normalizedRating {
	NSInteger rating = self.rating;
	
	if(rating == 100) { return 100; }
	if(rating >= 90) { return 90; }
	if(rating >= 80) { return 80; }
	if(rating >= 70) { return 70; }
	if(rating >= 60) { return 60; }
	if(rating >= 50) { return 50; }
	if(rating >= 40) { return 40; }
	if(rating >= 30) { return 30; }
	if(rating >= 20) { return 20; }
	if(rating >= 10) { return 10; }
	
	return 0;
}

- (NSString*)displayRating {
	if(self.ratingComputed) {
		return [NSString stringWithComputedUserRating:self.rating];
	}
	
	return [NSString stringWithUserRating:self.rating];
}

- (NSString*)displayAlbumRating {
	if(self.albumRatingComputed) {
		[NSString stringWithComputedUserRating:self.albumRating];
	}
	
	return [NSString stringWithUserRating:self.albumRating];
}

- (NSString*)displayTrackNumber {
	NSInteger trackNumber = self.trackNumber;
	
	if(trackNumber < 0) {
		return @"";
	}
	
	NSString* displayTrackNumber = nil;
	NSInteger trackCount = self.trackCount;
	
	if(trackCount > 0) { 
		displayTrackNumber = [NSString stringWithFormat:NSLocalizedString(@"MEDIALIBRARY_TRACKNUMBERANDCOUNT_TEMPLATE", @"Track number and track count on source"),
			(long)trackNumber,
			(long)trackCount];
	} else {
		if(trackNumber <= 0) {
			return @"";
		}
		
		displayTrackNumber = [NSString stringWithFormat:NSLocalizedString(@"MEDIALIBRARY_TRACKNUMBER_TEMPLATE", @"Track number with unknown track count"),
			(long)trackNumber];
	}
	
	return displayTrackNumber;
}

- (NSUInteger)durationInSeconds {
//	return llrint(self.duration / 1000.0);
	return self.duration / 1000.0;
}

- (NSString*)time {
	NSUInteger duration = self.durationInSeconds;
	
	NSUInteger seconds = duration % 60;
	NSUInteger minutes = (duration / 60) % 60;
	NSUInteger hours = duration / 3600;
	
	if(hours >= 10) {
		return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hours, minutes, seconds];
	} else if(hours > 0) {
		return [NSString stringWithFormat:@"%ld:%02ld:%02ld", hours, minutes, seconds];
	} else if(minutes >= 10) {
		return [NSString stringWithFormat:@"%02ld:%02ld", minutes, seconds];
	} else {
		return [NSString stringWithFormat:@"%ld:%02ld", minutes, seconds];
	}
	
	return @"";
}

- (NSURL*)locationURL {
	if(IsEmpty(self.location)) {
		return nil;
	}
	
	NSURL* locationURL = nil;
	
	NS_DURING
		locationURL = [NSURL URLWithString:[self location]];
	NS_HANDLER
	NS_ENDHANDLER

	return locationURL;
}

/*
- (NSUInteger)hash {
	return self.trackID;
}

- (BOOL)isEqual:(id)other {
	if([other isKindOfClass:[MusicLibraryTrack class]]) {
		return self.trackID == ((MusicLibraryTrack*)other).trackID;
	}
	
	if([other isKindOfClass:[NSNumber class]]) {
		return self.trackID == [other unsignedIntegerValue];
	}
	
	return NO;
}
*/

@end

BOOL EqualTracks(MusicLibraryTrack* first, MusicLibraryTrack* second) {
	if(first == second) { return YES; }
	if(!first || !second) { return NO; }
	
	NSString* firstID = first.persistentID;
	NSString* secondID = second.persistentID;
	
	if(!firstID && !secondID) {
		firstID = first.location;
		secondID = second.location;
	}
	
	return [(firstID ? firstID : secondID) isEqualToString:(firstID ? secondID : firstID)];
}

BOOL EqualAlbums(MusicLibraryTrack* first, MusicLibraryTrack* second) {
	if(first.streamed && second.streamed) {
		return EqualStrings(first.displayName, second.displayName);
	}
	
	if(first.compilation && second.compilation) {
		return EqualStrings(first.displayAlbum, second.displayAlbum);
	}
	
	if(EqualStrings(first.displayAlbum, second.displayAlbum) &&
	   EqualStrings(first.displayAlbumArtist, second.displayAlbumArtist)) {
		return YES;
	}
	
	return NO;
}
