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

#import "MusicLibrary.h"
#import "MusicLibrary+Private.h"

#import "MusicLibraryPlaylist.h"
#import "MusicLibraryAlbum.h"
#import "MusicLibraryTrack.h"

#import "MPMediaLibraryImporter.h"

#import "CoverSutra.h"

#import "NSArray+Additions.h"

#import "Utilities.h"

NSString* const MusicLibraryNeedsUpdateNotification = @"com.sophiestication.CoverSutra.MusicLibraryNeedsUpdate";
NSString* const MusicLibraryDidUpdateNotification = @"com.sophiestication.CoverSutra.MusicLibraryDidUpdate";

@implementation MusicLibrary

@dynamic operationQueue;
@synthesize
	refreshOperation = _refreshOperation,
	needsRefresh = _needsRefresh,
	tracks = _tracks,
	playlists = _playlists,
	libraryURL = _libraryURL,
	libraryFileModificationDate = _libraryFileModificationDate,
	lastRefreshDate = _lastRefreshDate;

+ (NSURL*)defaultLibraryURL {
	NSArray* recentDatabaseURLStrings = [[[NSUserDefaults standardUserDefaults]
		persistentDomainForName:@"com.apple.iApps"]
		objectForKey:@"iTunesRecentDatabases"];
	
	for(NSString* URLString in recentDatabaseURLStrings) {
		NSURL* URL = [NSURL URLWithString:URLString];
		
		if([URL checkResourceIsReachableAndReturnError:nil]) {
			return URL;
		}
	}
	
	// try "iTunes Music Library.xml"
	NSURL* URL = [NSURL fileURLWithPath:[@"~/Music/iTunes/iTunes Music Library.xml" stringByExpandingTildeInPath]];
	
	if([URL checkResourceIsReachableAndReturnError:nil]) {
		return URL;
	}
	
	// now try "iTunes Library.xml"
	URL = [NSURL fileURLWithPath:[@"~/Music/iTunes/iTunes Library.xml" stringByExpandingTildeInPath]];
	
	if([URL checkResourceIsReachableAndReturnError:nil]) {
		return URL;
	}

	
	return nil;
}

- (id)init {
	if((self = [super init])) {
		_needsRefresh = YES;

		[[NSDistributedNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(_iTunesSavedSource:)
			name:@"com.apple.iTunes.sourceSaved"
			object:@"com.apple.iTunes.sources"];
	}

	return self;
}


- (NSOperationQueue*)operationQueue {
	return [[CoverSutra self] operationQueue];
}

- (MusicLibraryPlaylist*)playlistForType:(NSString*)type {
	for(MusicLibraryPlaylist* playlist in self.playlists) {
		if(EqualStrings(playlist.type, type)) {
			return playlist;
		}
	}
	
	return nil;
}

- (void)refreshIfNeeded {
	if(self.needsRefresh) {
		[self refresh];
	}
}

- (void)refresh {
	self.needsRefresh = NO;

	// Make a new parse operation	
	NSURL* libraryURL = [[self class] defaultLibraryURL];
	
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		libraryURL, @"libraryURL",
		nil];
	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self
		selector:@selector(refreshOperation:)
		object:userInfo];

//	[operation setQueuePriority:NSOperationQueuePriorityVeryLow];
	
	// Wait for the current refresh operation to stop
	NSOperation* refreshOperation = self.refreshOperation;
	
	if(refreshOperation) {
		[operation addDependency:refreshOperation];
		[refreshOperation cancel];
	}

	self.libraryURL = libraryURL;
	self.refreshOperation = operation;

	[[self operationQueue] addOperation:operation];
}

- (void)refreshOperation:(NSDictionary*)userInfo {
	@autoreleasepool {
	
		NSURL* libraryURL = [userInfo objectForKey:@"libraryURL"];
		
		NS_DURING
			MPMediaLibraryImporter* importer = [[MPMediaLibraryImporter alloc] init];
			[importer importFromPropertyList:libraryURL];

			if(![[NSThread currentThread] isCancelled]) {
				NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					importer.tracks, @"tracks",
					importer.playlists, @"playlists",
					nil];

				[self performSelectorOnMainThread:@selector(musicLibraryDidFinishParsing:)
					withObject:userInfo
					waitUntilDone:NO];
			}
		NS_HANDLER
			NSLog(@"Error while parsing library %@: %@", libraryURL, [localException reason]);
		NS_ENDHANDLER
	}
}

- (void)musicLibraryDidFinishParsing:(NSDictionary*)userInfo {
//	NSOperation* refreshOperation = [userInfo objectForKey:@"operation"];
//	
//	// Check if this operation is still valid
//	if(self.refreshOperation != refreshOperation || [refreshOperation isCancelled]) {
//		return;
//	}
	
	self.refreshOperation = nil;
	
	// Update from our operation
	self.playlists = [userInfo objectForKey:@"playlists"];
	self.tracks = [userInfo objectForKey:@"tracks"];
	
	// Mark the last refresh date
	_refreshTimer = nil;
	self.lastRefreshDate = [NSDate date];
	
	// Send out the update notification
	[[NSNotificationCenter defaultCenter]
		postNotificationName:MusicLibraryDidUpdateNotification
		object:self
		userInfo:nil];
}

- (void)_iTunesSavedSource:(NSNotification*)notification {
	// Check if we need to parse a different library file
	NSURL* defaultLibraryURL = [[self class] defaultLibraryURL];
	
	if(![defaultLibraryURL isEqual:[self libraryURL]]) {
		self.libraryURL = defaultLibraryURL;
		self.needsRefresh = YES;
	}
	
	// Do we like to automatically refresh at all?
//	BOOL reloadAutomatically = [[[NSUserDefaultsController sharedUserDefaultsController] valueForKeyPath:@"values.automaticallyReloadMusicLibrary"] boolValue];

	BOOL reloadAutomatically = YES;
	
	if(!reloadAutomatically && !self.needsRefresh) {
		return;
	}
	
	if(!self.lastRefreshDate) {
		self.needsRefresh = YES;
	}
	
	CGFloat latency = [self refreshLatency];
	
	if(self.lastRefreshDate && [self.lastRefreshDate timeIntervalSinceNow] >= latency) {
		self.needsRefresh = YES;
	}
	
	if(!_refreshTimer && !self.needsRefresh) {
		NSTimer* refreshTimer = [NSTimer scheduledTimerWithTimeInterval:latency
			target:self
			selector:@selector(setRefreshIfNeeded)
			userInfo:nil
			repeats:NO];
		
		_refreshTimer = refreshTimer;
	}
}

- (void)setRefreshIfNeeded {
	self.needsRefresh = YES;
	_refreshTimer = nil;
	
	// Send out the needs update notification
	[[NSNotificationCenter defaultCenter]
		postNotificationName:MusicLibraryNeedsUpdateNotification
		object:self
		userInfo:nil];
}

- (CGFloat)refreshLatency {
	NSUInteger numberOfTracks = self.tracks.count;
	CGFloat latencyInSeconds = MIN(30, MAX(0, numberOfTracks / 5000)) * 60.0;
	
	return latencyInSeconds;
}

@end
