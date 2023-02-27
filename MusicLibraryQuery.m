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

#import "MusicLibraryQuery.h"
#import "MusicLibraryQuery+Delegate.h"
#import "MusicLibraryQuery+Private.h"

#import "MusicLibrary.h"
#import "MusicLibrary+Private.h"

#import "MusicLibraryTrack.h"

#import "MusicLibraryQueryOperation.h"

#import "MusicLibraryItem.h"

#import "NSArray+Additions.h"

#import "CoverSutra.h"

#import "Utilities.h"

NSString* const MusicLibraryTracksSearchScope = @"tracksSearchScope";
NSString* const MusicLibraryPlaylistsSearchScope = @"playlistsSearchScope";

NSString* const MusicLibraryAlbumGroupingKind = @"albumGroupingKind";
NSString* const MusicLibraryArtistGroupingKind = @"artistGroupingKind";
NSString* const MusicLibraryRatingGroupingKind = @"ratingGroupingKind";
NSString* const MusicLibraryPlaylistCategoryGroupingKind = @"playlistCategoryGroupingKind";

@implementation MusicLibraryQuery

@synthesize
	delegate = _delegate,
	started = _started,
	gathering = _gathering,
	queryOperation = _queryOperation,
	groupingKind = _groupingKind,
	searchScopes = _searchScopes,
	completeAlbums = _completeAlbums;

@dynamic predicate;
@dynamic results;

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	self.groupingKind = MusicLibraryAlbumGroupingKind;
	self.searchScopes = [NSArray arrayWithObject:MusicLibraryTracksSearchScope];
	
	_started = NO;
	_gathering = NO;
	_completeAlbums = NO;
	
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_musicLibraryDidUpdate:)
		name:MusicLibraryDidUpdateNotification
		object:nil];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_musicLibraryNeedsUpdate:)
		name:MusicLibraryNeedsUpdateNotification
		object:nil];
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	
	
	
}

- (BOOL)isStopped {
	return !self.started;
}

- (void)setStopped:(BOOL)stopped {
	self.started = !stopped;
	self.gathering = NO;
}

- (NSPredicate*)predicate {
	return _predicate;
}

- (void)setPredicate:(NSPredicate*)predicate {
	if(_predicate != predicate) {
		// [self _queryWithPredicate] will cancel the current operation if needed
		// [self.queryOperation cancel];
		// self.queryOperation = nil;
		
		_predicate = predicate;
		
//		[self.results removeAllObjects];
		
		if(self.started) {
			// We're now in the gathering phase
			self.gathering = YES;
			[self _queryWithPredicate:_predicate shouldUpdate:NO];
		}
	}
}

- (id)results {
	return _results;
}

- (void)setResults:(id)results {
	if(results != _results) {
		_results = results;
		
		// self.scriptingObjects = nil;
		
//		if([self.delegate respondsToSelector:@selector(musicLibraryQuery:foundItems:)]) {
			[[self delegate] musicLibraryQuery:self foundItems:results];
//		}
	}
}

- (void)startQuery {
	// [self _queryWithPredicate] will cancel the current operation if needed
//	[self.queryOperation cancel];
//	self.queryOperation = nil;

	self.started = YES;
	
	// We're now in the gathering phase
	self.gathering = YES;
	[self _queryWithPredicate:self.predicate shouldUpdate:NO];
}

- (void)stopQuery {
	[self.queryOperation cancel];
	self.queryOperation = nil;
	
	self.stopped = YES;
	
	self.results = [NSMutableArray array];
}

- (void)_queryWithPredicate:(NSPredicate*)predicate shouldUpdate:(BOOL)shouldUpdate {
	// Check first if we need to refresh the music library
	MusicLibrary* musicLibrary = [[CoverSutra self] musicLibrary];
	
	[musicLibrary refreshIfNeeded];
	
	// Query after the library finsihed parsing
	if(musicLibrary.refreshOperation) {
		return;
	}
	
	NSOperationQueue* operationQueue = musicLibrary.operationQueue;
	
//	[operationQueue setSuspended:YES];
	
	// Make a new query operation
	MusicLibraryQueryOperation* operation = [[MusicLibraryQueryOperation alloc] init];
	
//	operation.queuePriority = NSOperationQueuePriorityVeryLow;
	operation.query = self;
	operation.searchScopes = self.searchScopes;
	operation.groupingKind = self.groupingKind;
	operation.predicate = predicate;
	operation.shouldUpdate = shouldUpdate;
	operation.completeAlbums = self.completeAlbums;
		
	// and wait for the previous query operation
	NSOperation* previousQueryOperation = self.queryOperation;

	if(previousQueryOperation) {
		// Cancel the previous operation
		[previousQueryOperation cancel];

		[operation addDependency:previousQueryOperation];
	}
	
	self.queryOperation = operation;
	
	// Start the new query operation
	[operationQueue addOperation:operation];
//	[operationQueue setSuspended:NO];
}

- (void)_setResults:(id)results {
	self.results = results;
	self.gathering = NO;
	
//	if([self.delegate respondsToSelector:@selector(musicLibraryQuery:didFinishGathering:)]) {
		[self.delegate musicLibraryQuery:self didFinishGathering:self.results];
//	}
}

- (void)_setResultsButKeepGathering:(id)results {
	self.results = results;
//	self.scriptingObjects = nil;
}

- (void)_resetQueryOperation:(NSOperation*)queryOperation {
	if(self.queryOperation == queryOperation) {
		self.queryOperation = nil;
	}
}

- (void)_musicLibraryNeedsUpdate:(NSNotification*)notification {
	if(self.started) {
		MusicLibrary* musicLibrary = [notification object];
		[musicLibrary refreshIfNeeded];
	}
}

- (void)_musicLibraryDidUpdate:(NSNotification*)notification {
	if(self.started) {
		[self _queryWithPredicate:self.predicate shouldUpdate:YES];
	}
}

@end
