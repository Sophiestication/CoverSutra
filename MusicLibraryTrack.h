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

#import "MusicLibraryItem.h"

@interface MusicLibraryTrack : MusicLibraryItem {
@private
	NSUInteger _trackID;
	NSString* _persistentID;
	
	NSString* _libraryPersistentID;
	
	BOOL _movie;
	BOOL _podcast;
	BOOL _TVShow;
	
	BOOL _disabled;
	
	NSString* _name;
	NSString* _album;
	NSString* _artist;
	NSString* _albumArtist;
	NSString* _composer;
	NSString* _grouping;
	
	NSString* _genre;
	
	NSString* _comments;
	NSString* _lyrics;
	
	NSDate* _dateAdded;
	NSDate* _releaseDate;
	
	BOOL _compilation;
	
	NSInteger _rating;
	BOOL _ratingComputed;

	NSInteger _albumRating;
	BOOL _albumRatingComputed;
	
	NSUInteger _playCount;
	
	NSInteger _trackNumber;
	NSInteger _trackCount;
	
	NSInteger _discNumber;
	NSInteger _discCount;
	
	NSUInteger _duration;
	
	NSInteger _recordingYear;
	
	NSInteger _artworkCount;
	
	NSString* _custom1;
	
	NSString* _location;
}

- (id)initWithTrackID:(NSUInteger)trackID;

@property(readonly) NSUInteger trackID;
@property(readonly, retain) NSString* persistentID;

@property(readonly, retain) NSString* libraryPersistentID;

@property(readonly, getter=isMovie) BOOL movie;
@property(readonly, getter=isPodcast) BOOL podcast;
@property(readonly, getter=isTVShow) BOOL TVShow;

@property(readonly, getter=isShared) BOOL shared;
@property(readonly, getter=isStreamed) BOOL streamed;

@property(readonly, getter=isDisabled) BOOL disabled;

@property(unsafe_unretained, readonly) NSString* displayName;
@property(unsafe_unretained, readonly) NSString* displayArtist;
@property(unsafe_unretained, readonly) NSString* displayAlbum;
@property(unsafe_unretained, readonly) NSString* displayAlbumArtist;

@property(readonly, retain) NSString* name;
@property(readonly, retain) NSString* album;
@property(readonly, retain) NSString* artist;
@property(readonly, retain) NSString* albumArtist;
@property(readonly, retain) NSString* composer;
@property(readonly, retain) NSString* grouping;

@property(readonly, retain) NSString* genre;

@property(readonly, retain) NSString* comments;
@property(readonly, retain) NSString* lyrics;

@property(readonly, retain) NSDate* dateAdded;
@property(readonly, retain) NSDate* releaseDate;

@property(readonly, getter=isCompilation) BOOL compilation;

@property(readonly) NSInteger rating;
@property(readonly, getter=isRatingComputed) BOOL ratingComputed;

@property(readonly) NSInteger albumRating;
@property(readonly, getter=isAlbumRatingComputed) BOOL albumRatingComputed;

@property(readonly) NSInteger normalizedRating;

@property(unsafe_unretained, readonly) NSString* displayAlbumRating;
@property(unsafe_unretained, readonly) NSString* displayRating;

@property(readonly) NSUInteger playCount;

@property(readonly, retain) NSString* displayTrackNumber;

@property(readonly) NSInteger trackNumber;
@property(readonly) NSInteger trackCount;

@property(readonly) NSInteger discNumber;
@property(readonly) NSInteger discCount;

@property(readonly) NSUInteger duration;
@property(readonly) NSUInteger durationInSeconds;

@property(readonly, retain) NSString* time;

@property(readonly) NSInteger recordingYear;

@property(readonly) NSInteger artworkCount;

@property(readonly, retain) NSString* custom1;

@property(readonly, retain) NSString* location;
@property(readonly, retain) NSURL* locationURL;

@property(getter=isStorePreview) BOOL storePreview;

@end

/*!
    @function	EqualTracks
    @abstract   <#(description)#>
    @discussion <#(description)#>
    @param      <#(name) (description)#>
    @result     <#(description)#>
*/
BOOL EqualTracks(MusicLibraryTrack* first, MusicLibraryTrack* second);

/*!
 @function	EqualAlbums
 @abstract   <#(description)#>
 @discussion <#(description)#>
 @param      <#(name) (description)#>
 @result     <#(description)#>
 */
BOOL EqualAlbums(MusicLibraryTrack* first, MusicLibraryTrack* second);
