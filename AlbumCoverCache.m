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

#import "AlbumCoverCache.h"
#import "AlbumCoverCache+Private.h"

#import "MusicLibrary.h"
#import "MusicLibrary+Private.h"

#import "MusicLibraryAlbum.h"
#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Covers.h"

#import "CoverSutra.h"

#import "NSImage+QuickLook.h"

@implementation AlbumCoverCache

@synthesize loadingAlbums = loadingAlbums_;
@synthesize
	delegate = _delegate,
	covers = _covers,
	userSpaceScaleFactor = _userSpaceScaleFactor;

- (id)init {
	if((self = [super init])) {
		self.loadingAlbums = [NSMutableSet set];
		_covers = [[NSCache alloc] init];
		// [_covers setTotalCostLimit:(48 * 48 * 4) * 20]; // about 20 covers
		
		_userSpaceScaleFactor = 1.0;
	}

	return self;
}


- (NSImage*)coverForAlbum:(MusicLibraryAlbum*)album {
	NSImage* albumCover = [self.covers objectForKey:album.persistentID];
	
	if(!albumCover) {
		[self _requestCoverForAlbum:album];
	}
	
	return albumCover;
}

- (void)purgeIfNeeded {
//	[[self covers] removeAllObjects];

//	[self cancelPurge];
//	[self performSelector:@selector(_purge)
//		withObject:nil
//		afterDelay:1.0 * 60.0];
}

- (void)cancelPurge {
//	[[self class] cancelPreviousPerformRequestsWithTarget:self
//		selector:@selector(_purge)
//		object:nil];
}

- (void)_requestCoversForAlbumsInArray:(NSArray*)albums {
	for(MusicLibraryAlbum* album in albums) {
		[self _requestCoverForAlbum:album];
	}
}

- (void)_requestCoverForAlbum:(MusicLibraryAlbum*)album {
	if([[self loadingAlbums] containsObject:album]) { return; }

	[[self loadingAlbums] addObject:album];

	NSInvocationOperation* operation = [[NSInvocationOperation alloc] initWithTarget:self
		selector:@selector(_requestCoverForAlbumOperation:)
		object:album];
	
	[[[[CoverSutra self] musicLibrary] operationQueue] addOperation:operation];
}

- (void)_requestCoverForAlbumOperation:(MusicLibraryAlbum*)album {
	NS_DURING
		NSArray* tracks = [NSArray arrayWithArray:album.tracks];
		
		for(MusicLibraryTrack* track in tracks) {
			// iTunes does report 0 tracks in some weird cases
//			if(track.artworkCount <= 0) { continue; } // ignore tracks without album artwork
			
			NSURL* fileURL = track.locationURL;
			
			NSDictionary* options = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithFloat:self.userSpaceScaleFactor], (id)kQLThumbnailOptionScaleFactorKey,
				[NSNumber numberWithBool:NO], (id)kQLThumbnailOptionIconModeKey,
				nil];
			
			NSImage* albumCover = [NSImage thumbnailImageForContentsOfURL:fileURL
				size:NSMakeSize(48.0, 48.0)
				options:options];
				
			if(!albumCover) {
				albumCover = [track coverImage];
			}
			
			if(albumCover) {
				NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
					album, @"album",
					albumCover, @"cover",
					nil];
				
				[self performSelectorOnMainThread:@selector(_foundCover:)
					withObject:userInfo
					waitUntilDone:NO];

				NS_VOIDRETURN;
			}
		}
		
		[self performSelectorOnMainThread:@selector(_couldNotFindCoverForAlbum:)
			withObject:album
			waitUntilDone:NO];
	NS_HANDLER
		NSLog(@"Error while getting album cover for album %@: %@", album.displayName, [localException reason]);
	NS_ENDHANDLER
}

- (void)_foundCover:(NSDictionary*)userInfo {
	MusicLibraryAlbum* album = [userInfo objectForKey:@"album"];
	NSImage* albumCover = [userInfo objectForKey:@"cover"];
	
	NSSize imageSize = [albumCover size];
	NSUInteger imageCost = imageSize.width * imageSize.height * self.userSpaceScaleFactor * 4.0; // good enough for caching
	
	[_covers setObject:albumCover forKey:album.persistentID cost:imageCost];
	
	id delegate = self.delegate;
	
	if([delegate respondsToSelector:@selector(albumCoverCache:foundCoverForAlbum:)]) {
		[delegate albumCoverCache:self foundCoverForAlbum:album];
	}
}

- (void)_couldNotFindCoverForAlbum:(MusicLibraryAlbum*)album {
	[[self loadingAlbums] removeObject:album];
}

- (void)_purge {
//	self.covers = [NSMutableDictionary dictionary];
}

@end
