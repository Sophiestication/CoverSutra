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

#import "MusicLibraryPlaylist.h"
#import "MusicLibraryPlaylist+Private.h"

NSString* const MusicLibraryUnknownPlaylistType = @"unknownPlaylistType";
NSString* const MusicLibraryMasterPlaylistType = @"masterPlaylistType";
NSString* const MusicLibraryMusicPlaylistType = @"musicPlaylistType";
NSString* const MusicLibraryMoviesPlaylistType = @"moviesPlaylistType";
NSString* const MusicLibraryTVShowsPlaylistType = @"TVShowsPlaylistType";
NSString* const MusicLibraryPodcastsPlaylistType = @"PodcastsPlaylistType";
NSString* const MusicLibraryAudiobooksPlaylistType = @"AudiobooksPlaylistType";
NSString* const MusicLibraryiTunesUPlaylistType = @"iTunesUPlaylistType";
NSString* const MusicLibraryGamesPlaylistType = @"GamesPlaylistType";
NSString* const MusicLibraryRadioPlaylistType = @"RadioPlaylistType";
NSString* const MusicLibraryRingtonesPlaylistType = @"RingtonesPlaylistType";
NSString* const MusicLibraryPurchasesPlaylistType = @"PurchasesPlaylistType";
NSString* const MusicLibraryPartyShufflePlaylistType = @"PartyShufflePlaylistType";
NSString* const MusicLibraryFolderPlaylistType = @"FolderPlaylistType";
NSString* const MusicLibrarySmartPlaylistType = @"SmartPlaylistType";
NSString* const MusicLibraryUserPlaylistType = @"UserPlaylistType";

@implementation MusicLibraryPlaylist

@dynamic displayName;
@dynamic priority;
@dynamic image;
@dynamic mutableItems;
@dynamic category;

@synthesize
	playlistID = _playlistID,
	persistentID = _persistentID,
	parentPersistentID = _parentPersistentID,
	name = _name,
	type = _type,
	distinguishedKind = _distinguishedKind,
	geniusTrackID = _geniusTrackID,
	visible = _visible,
	items = _items;

- (id)init {
	if(![super init]) {
		return nil;
	}

	_playlistID = 0;
//	_items = [[NSMutableArray alloc] init];
	_type = MusicLibraryUnknownPlaylistType;
	_distinguishedKind = -1;
	_geniusTrackID = -1;
	_visible = YES;
	
	return self;
}

- (id)copyWithZone:(NSZone*)zone {
	MusicLibraryPlaylist* copy = [[[self class] alloc] init];
	
	copy.playlistID = self.playlistID;
	
	copy.persistentID = self.persistentID;
	
	copy.parentPersistentID = self.parentPersistentID;
	copy.parent = self.parent;

	copy.name = self.name;

	copy.type = self.type;
	copy.distinguishedKind = self.distinguishedKind;
	copy.geniusTrackID = self.geniusTrackID;
	copy.visible = self.visible;
	
	[copy->_items addObjectsFromArray:self.items];

	return copy;
}


- (BOOL)isEqual:(id)other {
	if([other isKindOfClass:[MusicLibraryPlaylist class]]) {
		MusicLibraryPlaylist* otherPlaylist = other;
		
		return self.playlistID == otherPlaylist.playlistID;
	}
	
	return [super isEqual:other];
}

- (NSUInteger)hash {
	return self.playlistID;
}

- (BOOL)isDisabled {
	return !self.visible;
}

- (NSString*)displayName {
	return self.name ? self.name : @"";
}

- (NSString*)category {
//	if(self.type == MusicLibrarySmartPlaylistType) {
//		return @"Smart Playlists";
//	}
	
	if(self.type == MusicLibraryPurchasesPlaylistType ||
	   (self.distinguishedKind == 20 || self.distinguishedKind == 21)) {
		return NSLocalizedString(@"MEDIALIBRARY_STORE_PLAYLIST_GROUP", @"");
	}
	
	if(self.type == MusicLibraryUserPlaylistType &&
	   (self.distinguishedKind == 26 ||
	   self.geniusTrackID >= 0)) {
		return NSLocalizedString(@"MEDIALIBRARY_GENIUS_PLAYLIST_GROUP", @"");
	}
	
	if(self.type == MusicLibraryUserPlaylistType ||
	   self.type == MusicLibrarySmartPlaylistType ||
	   self.type == MusicLibraryPartyShufflePlaylistType) {
		return NSLocalizedString(@"MEDIALIBRARY_PLAYLISTS_PLAYLIST_GROUP", @"");
	}
	
	if(self.type == MusicLibraryFolderPlaylistType) {
		return NSLocalizedString(@"MEDIALIBRARY_FOLDERS_PLAYLIST_GROUP", @"");
	}

	return NSLocalizedString(@"MEDIALIBRARY_LIBRARY_PLAYLIST_GROUP", @"");
}

- (NSInteger)priority {
	if(self.type == MusicLibraryPurchasesPlaylistType ||
	   self.distinguishedKind == 20 ||
	   self.distinguishedKind == 21) {
		return 20;
	}
	
	if(self.type == MusicLibraryUserPlaylistType &&
	   (self.distinguishedKind == 26 ||
	   self.geniusTrackID >= 0)) {
		if(self.distinguishedKind == 26) {
			return 298;
		}
		
		return 299;
	}
	
	if(self.type == MusicLibraryFolderPlaylistType) {
		return 500;
	}
	
	if(self.type == MusicLibraryPartyShufflePlaylistType) {
		return 400;
	}
	
	if(self.type == MusicLibrarySmartPlaylistType) {
		return 401;
	}
	
	if(self.type == MusicLibraryUserPlaylistType) {
		return 402;
	}
	
	if(self.type == MusicLibraryMusicPlaylistType) {
		return 1;
	}
	
	if(self.type == MusicLibraryMoviesPlaylistType) {
		return 2;
	}
	
	if(self.type == MusicLibraryTVShowsPlaylistType) {
		return 3;
	}
	
	if(self.type == MusicLibraryPodcastsPlaylistType) {
		return 4;
	}
	
	if(self.type == MusicLibraryiTunesUPlaylistType) {
		return 5;
	}
	
	if(self.type == MusicLibraryAudiobooksPlaylistType) {
		return 6;
	}
	
	if(self.type == MusicLibraryGamesPlaylistType) {
		return 7;
	}
	
	if(self.type == MusicLibraryRadioPlaylistType) {
		return 8;
	}
	
	if(self.type == MusicLibraryRingtonesPlaylistType) {
		return 9;
	}
	
	return 100;
}

- (NSImage*)image {
	if(self.type == MusicLibraryFolderPlaylistType) {
		return [NSImage imageNamed:@"folder"];
	}

	if(self.type == MusicLibrarySmartPlaylistType) {
		return [NSImage imageNamed:@"smartPlaylist"];
	}
	
	if(self.type == MusicLibraryPurchasesPlaylistType ||
	   self.distinguishedKind == 20 ||
	   self.distinguishedKind == 21) {
		return [NSImage imageNamed:@"purchasedMusicPlaylist"];
	}
	
	if(self.type == MusicLibraryUserPlaylistType) {
		if(self.distinguishedKind == 26) {
			return [NSImage imageNamed:@"genius"];
		} else if(self.geniusTrackID >= 0) {
			return [NSImage imageNamed:@"genius"];
		}

		return [NSImage imageNamed:@"userPlaylist"];
	}
	
	if(self.type == MusicLibraryMusicPlaylistType) {
		return [NSImage imageNamed:@"music"];
	}
	
	if(self.type == MusicLibraryMoviesPlaylistType) {
		return [NSImage imageNamed:@"movies"];
	}
	
	if(self.type == MusicLibraryTVShowsPlaylistType) {
		return [NSImage imageNamed:@"TVShows"];
	}
	
	if(self.type == MusicLibraryPodcastsPlaylistType) {
		return [NSImage imageNamed:@"podcast"];
	}
	
	if(self.type == MusicLibraryAudiobooksPlaylistType) {
		return [NSImage imageNamed:@"audiobook"];
	}
	
	if(self.type == MusicLibraryiTunesUPlaylistType) {
		return [NSImage imageNamed:@"iTunesU"];
	}
	
	if(self.type == MusicLibraryPartyShufflePlaylistType) {
		return [NSImage imageNamed:@"partyShuffle"];
	}
	
	if(self.type == MusicLibraryFolderPlaylistType) {
		return [NSImage imageNamed:@"folder"];
	}
	
	return nil;
}

- (NSMutableArray*)mutableItems {
	return _items;
}

@end
