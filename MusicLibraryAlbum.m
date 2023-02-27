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

#import "MusicLibraryAlbum.h"
#import "MusicLibraryAlbum+Private.h"

#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Scripting.h"

#import "MusicLibraryTrackAdapter.h"

#import "MusicLibrary.h"

#import "CoverSutra.h"

#import "NSArray+Additions.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "Utilities.h"

@implementation MusicLibraryAlbum

@dynamic persistentID,
	displayName,
	displayArtist,
	discs;

@synthesize
	name = _name,
	artist = _artist,
	compilation = _compilation;
	
@dynamic tracks;

+ (MusicLibraryAlbum*)albumForTrack:(MusicLibraryTrack*)track {
	if(!track) {
		return nil;
	}
	
	// TODO Check if this is a file track of our media library
	if([CSiTunesApplication() isRunning] && ![[NSThread currentThread] isCancelled]) {
		MusicLibraryAlbum* album = [[MusicLibraryAlbum alloc] init];
		
		album.name = track.album;
		album.artist = track.albumArtist;
		
		if(IsEmpty(album.artist)) {
			album.artist = track.artist;
		}
		
		album.compilation = track.compilation;
		
		if(IsEmpty(album.name)) {
			[album addTrack:track];

			return album; // Don't query if the track has no album information
		}
		
		NS_DURING
			NSDictionary* scriptingObjects = [track scriptingObjects];

			iTunesPlaylist* playlist = [scriptingObjects objectForKey:@"playlist"];
			
			id foundObject = [playlist searchFor:[album name] only:iTunesESrAAlbums];
			
			// Check if this thread was cancelled
			if([[NSThread currentThread] isCancelled]) {
				return album;
			}
			
			if([foundObject isKindOfClass:[CSiTunesApplication() classForScriptingClass:@"track"]]) {
				[album addTrack:track];
				
				return album; // We only found one object which must be the current one
			} else {
				NSArray* scriptingObjects = foundObject;

				for(iTunesTrack* scriptingObject in scriptingObjects) {
					// Check if this thread was cancelled
					if([[NSThread currentThread] isCancelled]) {
						return album;
					}
					
					// Make a wrapper for the scripting object
					if([album isScriptingObjectPartOfAlbum:scriptingObject]) {
						MusicLibraryTrack* track = [MusicLibraryTrackAdapter adapterForScriptingObject:scriptingObject];
						[album addTrack:track];
					}
				}
			}
		NS_HANDLER
			NSLog(@"Error in albumForScriptingObjects: %@", localException);
		NS_ENDHANDLER
		
		return album;
	}

	return nil;
}

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_compilation = NO;
	_tracks = [[NSMutableArray alloc] init];
	_needsTrackOrdering = NO;
	
	return self;
}

- (id)copyWithZone:(NSZone*)zone {
	MusicLibraryAlbum* copy = [[[self class] alloc] init];
	
	copy.name = self.name;
	copy.artist = self.artist;
	copy.compilation = self.compilation;
	[copy->_tracks addObjectsFromArray:self.tracks];

	return copy;
}


- (NSString*)persistentID {
	return [NSString stringWithFormat:@"%@:%@",
		self.name,
		self.artist];
}

- (NSString*)displayName {
	if(IsEmpty(self.name)) {
		return NSLocalizedString(@"MEDIALIBRARY_NO_ALBUM", @"Missing album title description");
	}
	
	return self.name;
}

- (NSString*)displayArtist {
	if(self.compilation) {
		return NSLocalizedString(@"MEDIALIBRARY_VARIOUS_ARTISTS", @"Artist display name for compilation albums");
	}
	
	if(IsEmpty(self.artist)) {
		return NSLocalizedString(@"MEDIALIBRARY_NO_ARTIST", @"Missing artist description");
	}

	return self.artist;
}

- (NSArray*)items {
	return self.tracks;
}

- (NSArray*)tracks {
	if(_needsTrackOrdering) {
		NSArray* albumSortDescriptors = [NSArray arrayWithObjects:
			[[NSSortDescriptor alloc] initWithKey:@"discNumber" ascending:YES],
			[[NSSortDescriptor alloc] initWithKey:@"trackNumber" ascending:YES],
			[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES],
			nil];
		[_tracks sortUsingDescriptors:albumSortDescriptors];
		
		_needsTrackOrdering = NO;
	}
	
	return _tracks;
}

- (NSDictionary*)discs {
	NSMutableDictionary* discs = [NSMutableDictionary dictionary];
	
	for(MusicLibraryTrack* track in self.tracks) {
		NSNumber* discNumber = [NSNumber numberWithInteger:
			track.discNumber <= 0 ? 1 : track.discNumber];
			
		NSMutableArray* disc = [discs objectForKey:discNumber];
		
		if(!disc) {
			disc = [NSMutableArray array];
			[discs setObject:disc forKey:discNumber];
		}
		
		[disc addObject:track];
	}
	
	return discs;
}

- (BOOL)isEqual:(id)other {
	if([other isKindOfClass:[MusicLibraryAlbum class]]) {
		MusicLibraryAlbum* otherAlbum = other;
		
		if(self.compilation) {
			if(otherAlbum.compilation) {
				return  EqualStrings(self.name, otherAlbum.name);
			}
		}
		
		return EqualStrings(self.name, otherAlbum.name) &&
			   EqualStrings(self.artist, otherAlbum.artist);
	}
	
	return [super isEqual:other];
}

- (BOOL)isTrackPartOfAlbum:(MusicLibraryTrack*)track {
	if(!track) {
		return NO;
	}
	
	NSString* trackAlbum = track.displayAlbum;
	
	if(track.compilation) {
		return EqualStrings(trackAlbum, self.name);
	}
	
	NSString* trackArtist = track.albumArtist;
	
	if(IsEmpty(trackArtist)) {
		trackArtist = track.artist;
	}
	
	if(EqualStrings(trackAlbum, self.name) &&
	   EqualStrings(trackArtist, self.artist)) {
		return YES;
	}
	
	return NO;
}

- (BOOL)isScriptingObjectPartOfAlbum:(iTunesTrack*)scriptingObject {
	NSString* trackAlbum = scriptingObject.album;

	if(IsEmpty(trackAlbum)) {
		trackAlbum = @"";
	}
	
	if(scriptingObject.compilation) {
		return EqualStrings(trackAlbum, self.name);
	}
	
	NSString* trackArtist = scriptingObject.albumArtist;
	
	if(IsEmpty(trackArtist)) {
		trackArtist = scriptingObject.artist;
	}
	
	if(IsEmpty(trackArtist)) {
		trackArtist = @"";
	}
	
	if(EqualStrings(trackAlbum, self.name) &&
	   EqualStrings(trackArtist, self.artist)) {
		return YES;
	}
	
	return NO;
}

- (void)addTrack:(MusicLibraryTrack*)track {
	[_tracks addObject:track];
	
	if([_tracks count] > 1) {
		_needsTrackOrdering = YES;
	}
}

@end
