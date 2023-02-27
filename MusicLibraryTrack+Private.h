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

@interface MusicLibraryTrack()

@property(readwrite) NSUInteger trackID;
@property(readwrite, retain) NSString* persistentID;

@property(readwrite, retain) NSString* libraryPersistentID;

@property(readwrite) BOOL movie;
@property(readwrite) BOOL podcast;
@property(readwrite) BOOL TVShow;

@property(readwrite) BOOL disabled;

@property(readwrite, retain) NSString* name;
@property(readwrite, retain) NSString* album;
@property(readwrite, retain) NSString* artist;
@property(readwrite, retain) NSString* albumArtist;
@property(readwrite, retain) NSString* composer;
@property(readwrite, retain) NSString* grouping;

@property(readwrite, retain) NSString* genre;

@property(readwrite, retain) NSString* comments;
@property(readwrite, retain) NSString* lyrics;

@property(readwrite, retain) NSDate* dateAdded;
@property(readwrite, retain) NSDate* releaseDate;

@property(readwrite) BOOL compilation;

@property(readwrite) NSInteger rating;
@property(readwrite) BOOL ratingComputed;

@property(readwrite) NSInteger albumRating;
@property(readwrite) BOOL albumRatingComputed;

@property(readwrite) NSUInteger playCount;

@property(readwrite) NSInteger trackNumber;
@property(readwrite) NSInteger trackCount;

@property(readwrite) NSInteger discNumber;
@property(readwrite) NSInteger discCount;

@property(readwrite) NSUInteger duration;

@property(readwrite) NSInteger recordingYear;

@property(readwrite) NSInteger artworkCount;

@property(readwrite, retain) NSString* custom1;

@property(readwrite, retain) NSString* location;

@end
