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

#import <Cocoa/Cocoa.h>

extern NSString* const MusicLibraryTracksSearchScope;
extern NSString* const MusicLibraryPlaylistsSearchScope;

extern NSString* const MusicLibraryAlbumGroupingKind;
extern NSString* const MusicLibraryArtistGroupingKind;
extern NSString* const MusicLibraryRatingGroupingKind;
extern NSString* const MusicLibraryPlaylistCategoryGroupingKind;

@interface MusicLibraryQuery : NSObject {
@private
	id __unsafe_unretained _delegate;

	NSPredicate* _predicate;
	
	NSArray* _searchScopes;
	NSString* _groupingKind;

	BOOL _started;
	BOOL _gathering;
	BOOL _completeAlbums;

	NSOperation* __unsafe_unretained _queryOperation;

	id _results;
}

@property(readwrite, unsafe_unretained) id delegate;

@property(readonly, getter=isStarted) BOOL started;
@property(readonly, getter=isStopped) BOOL stopped;
@property(readonly, getter=isGathering) BOOL gathering;

@property(readwrite, strong) NSPredicate* predicate;

@property(readwrite, strong) NSArray* searchScopes;
@property(readwrite, strong) NSString* groupingKind;

@property BOOL completeAlbums;

@property(readonly, strong) id results;

- (void)startQuery;
- (void)stopQuery;

@end
