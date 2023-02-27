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

#import "MusicLibraryArtist.h"
#import "MusicLibraryArtist+Private.h"

#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Private.h"

#import "Utilities.h"

@implementation MusicLibraryArtist

@dynamic persistentID;
@dynamic displayName;

@synthesize
	name = _name,
	albums = _albums,
	tracks = _tracks;

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_tracks = [[NSMutableArray alloc] init];
	_needsTrackOrdering = NO;
	
	return self;
}

- (id)copyWithZone:(NSZone*)zone {
	MusicLibraryArtist* copy = [[[self class] alloc] init];
	
	copy.name = self.name;
//	[copy->_albums addObjectsFromArray:self.albums];
	[copy->_tracks addObjectsFromArray:self.tracks];

	return copy;
}


- (NSString*)persistentID {
	return self.name;
}

- (NSString*)displayName {
	if(IsEmpty(self.name)) {
		return NSLocalizedString(@"MEDIALIBRARY_NO_ARTIST", @"Missing artist description");
	}
	
	return self.name;
}

- (NSArray*)items {
	return self.tracks;
}

- (NSArray*)tracks {
	if(_needsTrackOrdering) {
		[self addAdditionalInfoToTracks];
		
		NSArray* sortDescriptors = [NSArray arrayWithObjects:
			[[NSSortDescriptor alloc] initWithKey:@"album" ascending:YES],
			[[NSSortDescriptor alloc] initWithKey:@"discNumber" ascending:YES],
			[[NSSortDescriptor alloc] initWithKey:@"trackNumber" ascending:YES],
			[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES],
			nil];
		[_tracks sortUsingDescriptors:sortDescriptors];
		
		_needsTrackOrdering = NO;
	}
	
	return _tracks;
}

- (BOOL)isEqual:(id)other {
	if([other isKindOfClass:[MusicLibraryArtist class]]) {
		MusicLibraryArtist* otherArtist = other;
		
		return EqualStrings(self.name, otherArtist.name);
	}
	
	return [super isEqual:other];
}

- (void)addTrack:(MusicLibraryTrack*)track {
	[_tracks addObject:track];
	
	if([_tracks count] > 1) {
		_needsTrackOrdering = YES;
	}
}

- (void)addAdditionalInfoToTracks {
	NSArray* tracks = [NSArray arrayWithArray:_tracks];
	
	// Reset all previously set info
	for(MusicLibraryTrack* track in tracks) {
		track.custom1 = nil;
	}

	// Add album title as track info if needed
	for(MusicLibraryTrack* track in tracks) {
		NSString* name = track.name;
		
		for(MusicLibraryTrack* track2 in _tracks) {
			if(track != track2 && EqualStrings(name, track2.name)) {
				track.custom1 = track.album;
				track2.custom1 = track2.album;
			}
		}
	}
}

@end
