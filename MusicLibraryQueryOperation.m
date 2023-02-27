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

#import "MusicLibraryQueryOperation.h"

#import "MusicLibrary.h"
#import "MusicLibrary+Private.h"

#import "MusicLibraryQuery.h"
#import "MusicLibraryQuery+Predicates.h"
#import "MusicLibraryQuery+Delegate.h"
#import "MusicLibraryQuery+Private.h"

#import "CoverSutra.h"

#import "MusicLibrary.h"

#import "MusicLibraryItem.h"
#import "MusicLibraryItem+Private.h"

#import "MusicLibraryArtist.h"
#import "MusicLibraryArtist+Private.h"

#import "MusicLibraryAlbum.h"
#import "MusicLibraryAlbum+Private.h"

#import "MusicLibraryRating.h"
#import "MusicLibraryRating+Private.h"

#import "MusicLibraryGroup.h"
#import "MusicLibraryGroup+Private.h"

#import "MusicLibraryPlaylist.h"
#import "MusicLibraryTrack.h"

#import "Utilities.h"

#import "NSArray+Additions.h"

@implementation MusicLibraryQueryOperation

@synthesize
	tag = _tag,
	query = _query,
	searchScopes = _searchScopes,
	groupingKind = _groupingKind,
	predicate = _predicate,
	shouldUpdate = _shouldUpdate,
	completeAlbums = _completeAlbums,
	tracks = _tracks,
	playlists = _playlists,
	results = _results;

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_finished = NO;
	_shouldUpdate = NO;
	_completeAlbums = NO;
	
	_results = [[NSMutableArray alloc] init];
	
	return self;
}


- (BOOL)isFinished {
	return _finished;
}

- (void)main {
	if(self.isCancelled) {
		return;
	}
	
	// ...
	@autoreleasepool {

		NS_DURING
			NSDate* startDate = [NSDate date];
			
			MusicLibraryQuery* query = self.query;
			
			NSPredicate* predicate = self.predicate;
			
			NSMutableArray* items = [NSMutableArray array];
			
			MusicLibrary* musicLibrary = [[CoverSutra self] musicLibrary];
			
			// Do we search for playlists?
			self.playlists = musicLibrary.playlists;
			
			if([self.searchScopes containsObject:MusicLibraryPlaylistsSearchScope] && !IsEmpty(self.playlists)) {
				[items addObjectsFromArray:self.playlists];
			}
			
			// Do we search for tracks?
			self.tracks = musicLibrary.tracks;

			if([self.searchScopes containsObject:MusicLibraryTracksSearchScope] && !IsEmpty(self.tracks)) {
				[items addObjectsFromArray:self.tracks];
			}
			
			// See if we like to ignore all unchecked tracks in the search results
			BOOL showDisabledItems = [[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:@"values.showDisabledMusicLibraryItems"] boolValue];
			
			for(MusicLibraryItem* item in items) {
				if(!self.isCancelled) {
					if(!showDisabledItems && item.disabled) {
						continue;
					}
					
					if(![predicate evaluateWithObject:item]) {
						continue;
					}
					
					// Group the item into our search results
					[self _groupItem:item]; //[[item copy] autorelease]];
					
					// Check if we need to update the UI
					NSTimeInterval secondsSinceStart = -[startDate timeIntervalSinceNow];

					if(!_shouldUpdate && ![self isCancelled] && secondsSinceStart >= 1.0 && !IsEmpty(self.results)) {
						NSMutableArray* resultsCopy = [[NSMutableArray alloc]
							initWithArray:self.results
							copyItems:NO];
						
						resultsCopy = [self _sortResultsInArray:resultsCopy];
						
						[query performSelectorOnMainThread:@selector(_setResultsButKeepGathering:)
							withObject:[self _narrowResultsInArray:resultsCopy]
							waitUntilDone:NO];
						
						
						startDate = [NSDate date];
					}
					
					// [NSThread sleepForTimeInterval:1.0 / 1000.0]; // For testing
				}
			}
			
			if(![self isCancelled]) {
				if(self.completeAlbums && self.groupingKind == MusicLibraryAlbumGroupingKind) {
					NSMutableArray* resultsCopy = [[NSMutableArray alloc]
						initWithArray:self.results
						copyItems:NO];
						
					resultsCopy = [self _sortResultsInArray:resultsCopy];
					resultsCopy = [self _narrowResultsInArray:resultsCopy];
						
					[query performSelectorOnMainThread:@selector(_setResultsButKeepGathering:)
						withObject:[self _narrowResultsInArray:resultsCopy]
						waitUntilDone:NO];
						
					
					for(MusicLibraryAlbum* album in self.results) {
						if(![self isCancelled]) {
							NSPredicate* predicate = [MusicLibraryQuery predicateForAlbumOfTrack:[[album tracks] firstObject]];
							NSArray* albumTracks = [[self tracks] filteredArrayUsingPredicate:predicate];
				
							if(albumTracks.count > album.tracks.count) {
								album.tracks = albumTracks;
							}
						}
					}
				}
				
				NSMutableArray* results = [self _completeResultsInArray:self.results];
				results = [self _sortResultsInArray:results];
				results = [self _narrowResultsInArray:results];
					
				if(![self isCancelled]) {
					if([self.query.delegate respondsToSelector:@selector(musicLibraryQuery:willFinishGathering:)]) {
						[self.query.delegate musicLibraryQuery:self.query willFinishGathering:results];
					}
				}
					
				if(![self isCancelled]) {
					[query performSelectorOnMainThread:@selector(_setResults:)
						withObject:results
						waitUntilDone:NO];
				}
			}
		NS_HANDLER
			NSLog(@"Error in music library query: %@", localException);
			
			[self.query performSelectorOnMainThread:@selector(_setResults:)
				withObject:[NSArray array]
				waitUntilDone:NO];
		NS_ENDHANDLER
		
		_finished = YES;
		
		// Inform the query that we're done
		[[self query] performSelectorOnMainThread:@selector(_resetQueryOperation:)
			withObject:self
			waitUntilDone:NO];
	
	}
}

- (void)_groupItem:(MusicLibraryItem*)item {
	if([item isKindOfClass:[MusicLibraryTrack class]]) {
		[self _groupTrack:(MusicLibraryTrack*)item];
	}
	
	if([item isKindOfClass:[MusicLibraryPlaylist class]]) {
		[self _groupPlaylist:(MusicLibraryPlaylist*)item];
	}
}

- (void)_groupTrack:(MusicLibraryTrack*)track {
	if(self.groupingKind == MusicLibraryArtistGroupingKind) {
		[self _groupTrackToArtist:track];
	} else if(self.groupingKind == MusicLibraryRatingGroupingKind) {
		[self _groupTrackToRating:track];
	} else {
		[self _groupTrackToAlbum:track];
	}
}

- (void)_groupTrackToAlbum:(MusicLibraryTrack*)track {
	NSMutableArray* results = self.results;
	
	for(MusicLibraryItem* item in results) {
		if([item isKindOfClass:[MusicLibraryAlbum class]]) {
			MusicLibraryAlbum* albumItem = (MusicLibraryAlbum*)item;
			
			if([albumItem isTrackPartOfAlbum:track]) {
				[albumItem addTrack:track];
				return;
			}
		}
	}
	
	MusicLibraryAlbum* albumItem = [[MusicLibraryAlbum alloc] init];
	
	NSString* trackAlbum = track.displayAlbum;
	NSString* trackArtist = track.albumArtist;
	
	if(!trackArtist) {
		trackArtist = track.artist;
	}
	
	albumItem.name = trackAlbum;
	
	if(track.compilation) {
		albumItem.artist = nil;
		albumItem.compilation = YES;
	} else {
		albumItem.artist = trackArtist;
	}
	
	[albumItem addTrack:track];
	
	[results addObject:albumItem];
}

- (void)_groupTrackToArtist:(MusicLibraryTrack*)track {
	NSMutableArray* results = self.results;
	
	NSString* artist = track.artist;
	
	for(MusicLibraryItem* item in results) {
		if([item isKindOfClass:[MusicLibraryArtist class]]) {
			MusicLibraryArtist* artistItem = (MusicLibraryArtist*)item;
			
			if([artistItem.name isEqualToString:artist]) {
				[artistItem addTrack:track];
				return;
			}
		}
	}
	
	MusicLibraryArtist* artistItem = [[MusicLibraryArtist alloc] init];
	
	artistItem.name = track.artist;
	
	[artistItem addTrack:track];
	
	[results addObject:artistItem];
}

- (void)_groupTrackToRating:(MusicLibraryTrack*)track {
	NSMutableArray* results = self.results;
	
	for(MusicLibraryItem* item in results) {
		if([item isKindOfClass:[MusicLibraryRating class]]) {
			MusicLibraryRating* ratingItem = (MusicLibraryRating*)item;
			
			if(track.normalizedRating == ratingItem.rating) {
				[ratingItem addTrack:track];
				return;
			}
		}
	}
	
	MusicLibraryRating* ratingItem = [[MusicLibraryRating alloc] init];
	
	ratingItem.rating = track.normalizedRating;
	
	[ratingItem addTrack:track];
	
	[results addObject:ratingItem];
}

- (void)_groupPlaylist:(MusicLibraryPlaylist*)playlist {
	NSMutableArray* results = self.results;
	
	if(playlist.type == MusicLibraryMasterPlaylistType) {
		return;
	}
	
	if(playlist.type == MusicLibraryFolderPlaylistType && IsEmpty(playlist.items)) {
		return;
	}

	for(MusicLibraryItem* item in results) {
		if([item isKindOfClass:[MusicLibraryGroup class]]) {
			MusicLibraryGroup* groupItem = (MusicLibraryGroup*)item;
			
			if(playlist.type == MusicLibraryFolderPlaylistType) {
				if(EqualStrings(groupItem.custom1, playlist.persistentID)) {
					groupItem.name = playlist.displayName;
					groupItem.priority = playlist.priority;
					groupItem.custom3 = @"needsCompletion";

					return;
				}
			}

			if(IsEmpty(playlist.parentPersistentID)) {
				if(EqualStrings(groupItem.custom2, playlist.category)) {
					[groupItem.mutableItems addObject:playlist];
					return;
				}
			} else {
				if(EqualStrings(groupItem.custom1, playlist.parentPersistentID)) {
					[groupItem.mutableItems addObject:playlist];
					return;
				}
			}
		}
	}
	
	MusicLibraryGroup* groupItem = [[MusicLibraryGroup alloc] init];
	
	if(playlist.type == MusicLibraryFolderPlaylistType) {
		groupItem.name = playlist.displayName;
		groupItem.representedObject = playlist;
		groupItem.custom1 = playlist.persistentID;
		groupItem.custom3 = @"needsCompletion";
		groupItem.priority = playlist.priority;
	} else {
		if(IsEmpty(playlist.parentPersistentID)) {
			groupItem.name = playlist.category;
			groupItem.custom2 = playlist.category;
			groupItem.priority = playlist.priority;
		} else {
			groupItem.custom1 = playlist.parentPersistentID;
		}
	
		[groupItem.mutableItems addObject:playlist];
	}
	
	[results addObject:groupItem];
}

- (NSMutableArray*)_completeResultsInArray:(NSMutableArray*)results {
	if(self.groupingKind == MusicLibraryPlaylistCategoryGroupingKind) {
		for(MusicLibraryGroup* groupItem in results) {
			if(IsEmpty(groupItem.name)) {
				// We need to find this folder
				for(MusicLibraryPlaylist* playlist in self.playlists) {
					if(EqualStrings(groupItem.custom1, playlist.persistentID)) {
						groupItem.name = playlist.displayName;
						groupItem.priority = playlist.priority;
					}
				}
			}
			
			if(!IsEmpty(groupItem.custom3)) {
				// We need to complete this folder
				for(MusicLibraryPlaylist* playlist in self.playlists) {
					if(EqualStrings(groupItem.custom1, playlist.parentPersistentID) &&
					   ![groupItem.items containsObject:playlist]) {
						[groupItem.mutableItems addObject:playlist];
					}
				}
			}
		}
	}
	
	if(self.groupingKind == MusicLibraryAlbumGroupingKind) {
		for(MusicLibraryAlbum* album in results) {
			// Fix up the compilation issue
			if(album.compilation) {
				NSArray* distinctArtists = [album valueForKeyPath:@"tracks.@distinctUnionOfObjects.displayAlbumArtist"];
				
				if(distinctArtists.count <= 1) {
					album.compilation = NO;
					album.artist = distinctArtists.firstObject;
				}
			}
		}
	}

	return results;
}

- (NSMutableArray*)_narrowResultsInArray:(NSMutableArray*)results {
	if(self.groupingKind == MusicLibraryRatingGroupingKind && !IsEmpty(results)) {
		for(MusicLibraryRating* rating in results) {
			NSUInteger numberOfTracks = rating.mutableTracks.count;
			NSUInteger maximumNumberOfTracks = 50 / results.count;
			
			if(numberOfTracks <= maximumNumberOfTracks) {
				continue;
			}
			
			[rating.mutableTracks removeObjectsInRange:NSMakeRange(
				maximumNumberOfTracks,
				numberOfTracks - maximumNumberOfTracks)];
		}
		
		return results;
	}
	
	NSUInteger numberOfResults = results.count;
	NSUInteger maximumNumberOfResults = 25;
	
	if(self.groupingKind != MusicLibraryAlbumGroupingKind) {
		maximumNumberOfResults = 30;
	}
	
	if(self.groupingKind != MusicLibraryPlaylistCategoryGroupingKind) {
		maximumNumberOfResults = NSIntegerMax;
	}
	
	if(numberOfResults > maximumNumberOfResults) {
		[results removeObjectsInRange:NSMakeRange(
			maximumNumberOfResults,
			numberOfResults - maximumNumberOfResults)];
	}
	
	return results;
}

- (NSMutableArray*)_sortResultsInArray:(NSMutableArray*)results {
	if(self.groupingKind == MusicLibraryAlbumGroupingKind) {
		NSArray* albumSortDescriptors = [NSArray arrayWithObjects:
//			[[[NSSortDescriptor alloc] initWithKey:@"tracks.@max.dateAdded" ascending:NO] autorelease],
			[[NSSortDescriptor alloc] initWithKey:@"displayArtist" ascending:YES],
			[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES],
			nil];
		[results sortUsingDescriptors:albumSortDescriptors];
	} else if(self.groupingKind == MusicLibraryArtistGroupingKind) {
		NSArray* artistSortDescriptors = [NSArray arrayWithObjects:
//			[[[NSSortDescriptor alloc] initWithKey:@"tracks.@max.dateAdded" ascending:NO] autorelease],
			[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES],
			[[NSSortDescriptor alloc] initWithKey:@"tracks.name" ascending:YES],
			nil];
		[results sortUsingDescriptors:artistSortDescriptors];
	} else if(self.groupingKind == MusicLibraryRatingGroupingKind) {
		NSArray* ratingSortDescriptors = [NSArray arrayWithObjects:
			[[NSSortDescriptor alloc] initWithKey:@"rating" ascending:NO],
			nil];
		[results sortUsingDescriptors:ratingSortDescriptors];
	} else if(self.groupingKind == MusicLibraryPlaylistCategoryGroupingKind) {
		NSArray* groupSortDescriptors = [NSArray arrayWithObjects:
			[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES],
			[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES],
			nil];
		[results sortUsingDescriptors:groupSortDescriptors];
		
		for(MusicLibraryItem* result in results) {
			NSArray* playlistSortDescriptors = [NSArray arrayWithObjects:
				[[NSSortDescriptor alloc] initWithKey:@"priority" ascending:YES],
				[[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES],
				nil];
			[result.mutableItems sortUsingDescriptors:playlistSortDescriptors];
		}
	}
	
	return results;
}

@end
