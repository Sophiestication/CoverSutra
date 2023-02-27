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

#import "NowPlayingController.h"
#import "NowPlayingController+Private.h"

#import "SkinController.h"
#import "Skin.h"

#import "PlayerController.h"
#import "PlaybackController.h"

#import "CoverSutra.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "MusicLibrary.h"
#import "MusicLibrary+Private.h"

#import "MusicLibraryQuery.h"
#import "MusicLibraryQuery+Predicates.h"

#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Covers.h"
#import "MusicLibraryTrack+UIAdditions.h"
#import "MusicLibraryTrack+Private.h"

#import "MusicLibraryTrackAdapter.h"

#import "MusicLibraryAlbum.h"
#import "MusicLibraryAlbum+Private.h"

#import "NSArray+Additions.h"
#import "NSImage+QuickLook.h"
#import "NSObject+Additions.h"

#import "Utilities.h"

/*!
    @const PlayerDidChangeTrackNotification
*/
NSString* const PlayerDidChangeTrackNotification = @"com.sophiestication.CoverSutra.PlayerDidChangeTrack";

/*!
    @const PlayerDidRepeatTrackNotification
*/
NSString* const PlayerDidRepeatTrackNotification = @"com.sophiestication.CoverSutra.PlayerDidRepeatTrackNotification";

/*!
    @const PlayerDidChangeCoverNotification
*/
NSString* const PlayerDidChangeCoverNotification = @"com.sophiestication.CoverSutra.PlayerDidChangeCover";

@implementation NowPlayingController

@synthesize refreshThread = _refreshThread;
@synthesize album = _album;
@synthesize playerState = _playerState;
@synthesize playerInfo = _playerInfo;
@synthesize spotifyPlayerInfo = _spotifyPlayerInfo;

@dynamic coverImage;
@dynamic track;
@dynamic skin;

@dynamic
	extraSmallAlbumCaseImage,
	smallAlbumCaseImage,
	mediumAlbumCaseImage,
	largeAlbumCaseImage;

- (id)init {
	if((self = [super init])) {
		[self bind:@"skin"
			toObject:[CoverSutra self]
			withKeyPath:@"skinController.selection.self"
			options:nil];
			
//		[[NSDistributedNotificationCenter defaultCenter]
//			addObserver:self
//			selector:@selector(applicationDidReceiveDistributedNotification:)
//			name:nil
//			object:nil
//			suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
		
		[[NSDistributedNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(iTunesPlaybackStateChanged:)
			name:@"com.apple.iTunes.playerInfo"
			object:@"com.apple.iTunes.player"
			suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];
			
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(iTunesWillFinishLaunching:)
			name:iTunesWillFinishLaunchingNotification
			object:nil];
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(iTunesDidTerminate:)
			name:iTunesDidTerminateNotification
			object:nil];
			
		[[NSDistributedNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(spotifyPlaybackStateChanged:)
			name:@"com.spotify.client.PlaybackStateChanged"
			object:@"com.spotify.client"
			suspensionBehavior:NSNotificationSuspensionBehaviorCoalesce];

		[self refreshImmediately];
	}
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
}

- (MusicLibraryTrack*)track {
	return _track;
}

- (void)setTrack:(MusicLibraryTrack*)track {
	if(track != _track) {
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:2];

		[userInfo setValue:track forKey:@"track"];
		[userInfo setValue:[self track] forKey:@"previousTrack"];

		_track = track;
		
		// Post the player did change track notification
		[[NSNotificationCenter defaultCenter]
			postNotificationName:PlayerDidChangeTrackNotification
			object:nil
			userInfo:userInfo];
	}
}

- (NSImage*)coverImage {
	return _coverImage;
}

- (void)setCoverImage:(NSImage*)coverImage {
	if(coverImage != _coverImage) {
		// Release prepared case images
		[self _purgeAlbumCaseImages];
		
		_coverImage = coverImage;
		
		// Post the player did change cover notification
		[self postPlayerDidChangeCoverNotification];
	}
}

- (Skin*)skin {
	return _skin;
}

- (void)setSkin:(Skin*)skin {
	if(skin != _skin) {
		// Release prepared case images
		[self _purgeAlbumCaseImages];

		_skin = skin;
		
		// Post the player did change cover notification
		[self postPlayerDidChangeCoverNotification];
	}
}

- (void)_reset {
	self.album = nil;
	self.track = nil;
	self.coverImage = nil;
}

- (void)postPlayerDidRepeatTrackNotification {
	NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
		self.track, @"track",
		nil];
		
	[[NSNotificationCenter defaultCenter]
		postNotificationName:PlayerDidRepeatTrackNotification
		object:nil
		userInfo:userInfo];
}

- (void)postPlayerDidChangeCoverNotification {		
	[[NSNotificationCenter defaultCenter]
		postNotificationName:PlayerDidChangeCoverNotification
		object:nil
		userInfo:nil];
}

- (void)refreshIfNeeded {
	[self refresh];
}

- (void)refresh {
	[self refreshImmediately]; return; // TODO
	
	
	NSThread* refreshThread = self.refreshThread;

//	// Cancel the previous refresh operation
//	[currentRefreshOperation cancel];
	
	// Check is iTunes if running
	if(![CSiTunesApplication() isRunning]) {
//		self.refreshOperation = nil;
		[self _reset];
		
		return;
	}
	
	if(!refreshThread) {
		refreshThread = [[NSThread alloc] initWithTarget:self
			selector:@selector(refreshLoop:)
			object:nil];
		self.refreshThread = refreshThread;
		
		[refreshThread start];
	}
	
	[self performSelector:@selector(refreshForRealz:)
		onThread:refreshThread
		withObject:[self album]
		waitUntilDone:NO];
}

- (void)refreshImmediately {
	// Check is iTunes if running
	if(![CSiTunesApplication() isRunning]) {
		[self _reset];
		return;
	}
	
	// Do the actual refresh operation
	[self refreshForRealz:[self album]];
}

- (void)refreshLoop:(id)sender {
//	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
	
	while(![[NSThread currentThread] isCancelled]) {
		BOOL keepRunning = [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]; // Wait for input events
	
		if(!keepRunning) {
			break;
		}
		
//		[pool drain], pool = [[NSAutoreleasePool alloc] init];
	}
	
//	[pool drain];
}

- (void)refreshForRealz:(id)nowPlayingInfo {
//	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
	NS_DURING
		// Check if iTunes is still running
		iTunesApplication* application = CSiTunesApplication();
		
		if(![application isRunning]) {
			[self performSelectorOnMainThreadIfNeeded:@selector(_reset)
				withObject:nil];
			[self performSelectorOnMainThreadIfNeeded:@selector(_forceCoverImageDidChange)
				withObject:nil];
			
//			[pool drain];
			
			NS_VOIDRETURN;
		}
		
		// Request the new track object from iTunes
		MusicLibraryTrackAdapter* newTrack = nil;
		
		iTunesTrack* scriptingObject = [application currentTrack];
		newTrack = [MusicLibraryTrackAdapter adapterForScriptingObject:scriptingObject];
		
		// This is probably a iTunes Store track
		if(newTrack.persistentID.length <= 0) {
			newTrack.persistentID = [NSString stringWithFormat:@"%qX",
				[[[self playerInfo] objectForKey:@"PersistentID"] longLongValue]];
			newTrack.name = [[self playerInfo] objectForKey:@"Name"];
			newTrack.album = [[self playerInfo] objectForKey:@"Album"];
			newTrack.albumArtist = [[self playerInfo] objectForKey:@"Album Artist"];
			newTrack.artist = [[self playerInfo] objectForKey:@"Artist"];
				
			newTrack.compilation = [[[self playerInfo] objectForKey:@"Compilation"] boolValue];
				
			newTrack.rating = [[[self playerInfo] objectForKey:@"Rating"] integerValue];
				
			newTrack.duration = [[[self playerInfo] objectForKey:@"Total Time"] integerValue];
			
			newTrack.trackNumber = [[[self playerInfo] objectForKey:@"Track Number"] integerValue];
			newTrack.trackCount = [[[self playerInfo] objectForKey:@"Track Count"] integerValue];
			
			newTrack.discNumber = [[[self playerInfo] objectForKey:@"Disc Number"] integerValue];
			newTrack.discCount = [[[self playerInfo] objectForKey:@"Disc Count"] integerValue];
			
			newTrack.location = [[self playerInfo] objectForKey:@"Location"];
			
			newTrack.storePreview = YES;
		}

		// Are we still on the same album?
		MusicLibraryAlbum* album = nowPlayingInfo;
		MusicLibraryAlbum* newAlbum = nil;
		
		BOOL hasNewAlbum = YES;

		if(album && [album isTrackPartOfAlbum:newTrack]) {
			newAlbum = album;
			hasNewAlbum = NO;
		}

		// Get the new cover image
		NSImage* newCoverImage = nil;
		
		if(newTrack.artworkCount > 0) {
			newCoverImage = [newTrack coverImage];
				
			if(newCoverImage || (!newCoverImage && !newAlbum)) {
				[self performSelectorOnMainThreadIfNeeded:@selector(setCoverImage:)
					withObject:newCoverImage];
			}
		}
		
		// Check if we can retain the current cover image
		if(!newCoverImage && newAlbum) {
			newCoverImage = self.coverImage;
		}
		
		// Set the track after we retrieved the cover image
		[self performSelectorOnMainThreadIfNeeded:@selector(setTrack:)
			withObject:newTrack];

		// Get the whole album if needed
		if(!newAlbum && ![[NSThread currentThread] isCancelled]) {
			newAlbum = [self albumForTrack:newTrack];
		}

		// Set the new album in our main thread
		[self performSelectorOnMainThreadIfNeeded:@selector(setAlbum:)
			withObject:newAlbum];

		// Retrieve the cover image from our album if needed
		if(!newCoverImage && ![[NSThread currentThread] isCancelled]) {
			newCoverImage = [self coverImageForAlbum:newAlbum];
			
			[self performSelectorOnMainThreadIfNeeded:@selector(setCoverImage:)
				withObject:newCoverImage];
		}
		
		// Reset the pre-rendered cases if we have a new album but no cover image
		if(hasNewAlbum && !newCoverImage && ![[NSThread currentThread] isCancelled]) {
			[self performSelectorOnMainThreadIfNeeded:@selector(_purgeAlbumCaseImages)
				withObject:nil];
			[self performSelectorOnMainThreadIfNeeded:@selector(_forceCoverImageDidChange)
				withObject:nil];
		}
	NS_HANDLER
		NSLog(@"Error in now playing controller: %@", localException);
	NS_ENDHANDLER
	
//	[pool drain];
}

- (MusicLibraryAlbum*)albumForTrack:(MusicLibraryTrack*)track {
	return [MusicLibraryAlbum albumForTrack:track];
}

- (NSImage*)coverImageForAlbum:(MusicLibraryAlbum*)album {
	MusicLibraryTrack* trackContainingArtwork = nil;
		
	for(MusicLibraryTrack* track in album.tracks) {
		if(track.artworkCount > 0) {
			trackContainingArtwork = track;
			break;
		}
	}
		
	return [trackContainingArtwork coverImage];
}

- (void)iTunesPlaybackStateChanged:(NSNotification*)notification {
	self.spotifyPlayerInfo = nil;
	
	NSDictionary* newPlayerInfo = [notification userInfo];
	MusicLibraryTrack* track = self.track;

	BOOL needsRefresh = NO;
	
	// Check if this is a repeat
	if([[newPlayerInfo objectForKey:@"PersistentID"] isEqual:[[self playerInfo] objectForKey:@"PersistentID"]] &&
	   ![[newPlayerInfo objectForKey:@"Play Count"] isEqual:[[self playerInfo] objectForKey:@"Play Count"]]) {
		[self postPlayerDidRepeatTrackNotification];
	} else if([newPlayerInfo objectForKey:@"PersistentID"]) {
		// We need to convert the persistent ID string into hex format
		// to compare it with the string that the scripting object returns
		NSString* newPersistentID = [NSString stringWithFormat:@"%qX",
			[[newPlayerInfo objectForKey:@"PersistentID"] longLongValue]];
		NSString* persistentID = [NSString stringWithFormat:@"%qX",
			[[[self playerInfo] objectForKey:@"PersistentID"] longLongValue]];
		
		if(track.persistentID.length > 0) {
			persistentID = track.persistentID;
		}
		
		if(EqualStrings(newPersistentID, persistentID)) {
			NSString* streamTitle = [newPlayerInfo objectForKey:@"Stream Title"];

			if(streamTitle) {
				// This seems to be a internet radio track
				if(!EqualStrings(streamTitle, track.artist)) {
					needsRefresh = YES;
				}
			} else {
				if(EqualStrings([newPlayerInfo objectForKey:@"Player State"], [[self playerInfo] objectForKey:@"Player State"])) {
					[self postPlayerDidRepeatTrackNotification];
				}
			}
		} else {
			needsRefresh = YES;
		}
	} else if([newPlayerInfo objectForKey:@"Location"]) {
		// Check if the track changed by it's location
		NSString* location = [newPlayerInfo objectForKey:@"Location"];
		if(!EqualStrings(location, track.location)) {
			needsRefresh = YES;
		}
	} else {
		// Check if the track changed
		if(!EqualStrings([newPlayerInfo objectForKey:@"Name"], track.name) ||
		   !EqualStrings([newPlayerInfo objectForKey:@"Album"], track.album) ||
		   !EqualStrings([newPlayerInfo objectForKey:@"Artist"], track.artist) ||
		   [[newPlayerInfo objectForKey:@"Track Number"] integerValue] != track.trackNumber) {
			needsRefresh = YES;
		}
	}
	
	// Update player info and state
	self.playerState = [newPlayerInfo objectForKey:@"Player State"];
	self.playerInfo = newPlayerInfo;

	if(needsRefresh) {
		// Refresh in a separate thread
		[self refresh];
	}
}

- (void)iTunesWillFinishLaunching:(NSNotification*)notification {
}

- (void)iTunesDidTerminate:(NSNotification*)notification {
	[self _reset];
}

- (void)spotifyPlaybackStateChanged:(NSNotification*)notification {
	self.playerInfo = nil;
	
	NSDictionary* newPlayerInfo = [notification userInfo];
	BOOL needsRefresh = NO;
	
	if([[newPlayerInfo objectForKey:@"Track ID"] isEqual:[[self playerInfo] objectForKey:@"Track ID"]] &&
	   ![[newPlayerInfo objectForKey:@"Play Count"] isEqual:[[self playerInfo] objectForKey:@"Play Count"]]) {
		[self postPlayerDidRepeatTrackNotification];
	} else if([[newPlayerInfo objectForKey:@"Track ID"] isEqual:[[self playerInfo] objectForKey:@"Track ID"]]) {
		// do nothing…
	} else if([newPlayerInfo objectForKey:@"Track ID"]) {
		needsRefresh = YES;
	}
	
	// update player info and state
	self.playerState = [newPlayerInfo objectForKey:@"Player State"];
	self.spotifyPlayerInfo = newPlayerInfo;
	
	if(needsRefresh) {
		// TODO
		NSLog(@"%@ %@", self.playerState, [newPlayerInfo objectForKey:@"Name"]);
	}
}

- (void)applicationDidReceiveDistributedNotification:(NSNotification*)notification {
	NSLog(@"%@", notification);
}

+ (NSSet*)keyPathsForValuesAffectingExtraSmallAlbumCaseImage { return [NSSet setWithObjects:@"coverImage", @"skin", @"track", nil]; }
+ (NSSet*)keyPathsForValuesAffectingSmallAlbumCaseImage { return [NSSet setWithObjects:@"coverImage", @"skin", @"track", nil]; }
+ (NSSet*)keyPathsForValuesAffectingMediumAlbumCaseImage { return [NSSet setWithObjects:@"coverImage", @"skin", @"track", nil]; }
+ (NSSet*)keyPathsForValuesAffectingLargeAlbumCaseImage { return [NSSet setWithObjects:@"coverImage", @"skin", @"track", nil]; }

- (NSImage*)extraSmallAlbumCaseImage {
	if(!_extraSmallAlbumCaseImage) {
		_extraSmallAlbumCaseImage = [self albumCaseWithSize:ExtraSmallSkinSize];
	}
	
	return _extraSmallAlbumCaseImage;
}

- (NSImage*)smallAlbumCaseImage {
	if(!_smallAlbumCaseImage) {
		_smallAlbumCaseImage = [self albumCaseWithSize:SmallSkinSize];
	}
	
	return _smallAlbumCaseImage;
}

- (NSImage*)mediumAlbumCaseImage {
	if(!_mediumAlbumCaseImage) {
		_mediumAlbumCaseImage = [self albumCaseWithSize:MediumSkinSize];
	}
	
	return _mediumAlbumCaseImage;
}

- (NSImage*)largeAlbumCaseImage {
	if(!_largeAlbumCaseImage) {
		_largeAlbumCaseImage = [self albumCaseWithSize:LargeSkinSize];
	}
	
	return _largeAlbumCaseImage;
}

- (NSImage*)albumCaseWithSize:(NSString*)skinSize {
	NSImage* coverImage = self.coverImage;
	NSImage* albumCaseImage = nil;
	
	if(coverImage) {
		albumCaseImage = [[self skin] albumCaseWithCover:[self coverImage] ofSkinSize:skinSize];
	} else {
		albumCaseImage = [[self skin] albumCaseWithTrack:[self track] ofSkinSize:skinSize];
	}
	
	return albumCaseImage;
}

- (void)_purgeAlbumCaseImages {
	_extraSmallAlbumCaseImage = nil;
	_smallAlbumCaseImage = nil;
	_mediumAlbumCaseImage = nil;
	_largeAlbumCaseImage = nil;
}

- (void)_forceCoverImageDidChange {
	[self willChangeValueForKey:@"coverImage"];
	[self didChangeValueForKey:@"coverImage"];
}

@end
