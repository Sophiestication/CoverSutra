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

extern NSString* const PlayerDidChangeTrackNotification;
extern NSString* const PlayerDidRepeatTrackNotification;
extern NSString* const PlayerDidChangeCoverNotification;

@class
	MusicLibraryQuery,
	MusicLibraryTrack,
	MusicLibraryAlbum,
	Skin;

@interface NowPlayingController : NSObject {
@private
	NSThread* _refreshThread;
	
	MusicLibraryTrack* _track;
	MusicLibraryAlbum* _album;
	NSImage* _coverImage;
	
	Skin* _skin;
	NSImage* _extraSmallAlbumCaseImage;
	NSImage* _smallAlbumCaseImage;
	NSImage* _mediumAlbumCaseImage;
	NSImage* _largeAlbumCaseImage;
	
	NSString* _playerState;
	NSDictionary* _playerInfo;
	NSDictionary* _spotifyPlayerInfo;
}

@property(readonly, strong) MusicLibraryTrack* track;
@property(readonly, strong) MusicLibraryAlbum* album;
@property(readonly, strong) NSImage* coverImage;

@property(strong) Skin* skin;

- (void)refreshIfNeeded;
- (void)refresh;

- (void)refreshImmediately;

// Cover

@property(unsafe_unretained, readonly) NSImage* extraSmallAlbumCaseImage;
@property(unsafe_unretained, readonly) NSImage* smallAlbumCaseImage;
@property(unsafe_unretained, readonly) NSImage* mediumAlbumCaseImage;
@property(unsafe_unretained, readonly) NSImage* largeAlbumCaseImage;

- (NSImage*)albumCaseWithSize:(NSString*)skinSize;
- (void)_purgeAlbumCaseImages;
- (void)_forceCoverImageDidChange;

@end
