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

extern NSString* const MusicLibraryUnknownPlaylistType;
extern NSString* const MusicLibraryMasterPlaylistType;
extern NSString* const MusicLibraryMusicPlaylistType;
extern NSString* const MusicLibraryMoviesPlaylistType;
extern NSString* const MusicLibraryTVShowsPlaylistType;
extern NSString* const MusicLibraryPodcastsPlaylistType;
extern NSString* const MusicLibraryAudiobooksPlaylistType;
extern NSString* const MusicLibraryiTunesUPlaylistType;
extern NSString* const MusicLibraryGamesPlaylistType;
extern NSString* const MusicLibraryRadioPlaylistType;
extern NSString* const MusicLibraryRingtonesPlaylistType;
extern NSString* const MusicLibraryPurchasesPlaylistType;
extern NSString* const MusicLibraryPartyShufflePlaylistType;
extern NSString* const MusicLibraryFolderPlaylistType;
extern NSString* const MusicLibrarySmartPlaylistType;
extern NSString* const MusicLibraryUserPlaylistType;

@interface MusicLibraryPlaylist : MusicLibraryItem {
@private
	NSUInteger _playlistID;

	NSString* _persistentID;
	NSString* _parentPersistentID;
	
	NSString* _name;

	NSString* _type;
	NSInteger _distinguishedKind;
	NSInteger _geniusTrackID;
	
	BOOL _visible;

	NSMutableArray* _items;
}

@property(readonly) NSUInteger playlistID;

@property(readonly, strong) NSString* persistentID;
@property(readonly, strong) NSString* parentPersistentID;

@property(readonly, weak) MusicLibraryPlaylist* parent;

@property(weak, readonly) NSString* displayName;
@property(readonly, strong) NSString* name;

@property(readonly, copy) NSString* type;
@property(readonly, copy) NSString* category;

@property(readonly) NSInteger distinguishedKind;

@property(readonly) NSInteger geniusTrackID;

@property(readonly, getter=isVisible) BOOL visible;

@property(readonly) NSInteger priority;

@property(readonly, strong) NSImage* image;

@property(readonly, strong) NSArray* items;

@end
