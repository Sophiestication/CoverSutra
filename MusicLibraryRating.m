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

#import "MusicLibraryRating.h"
#import "MusicLibraryRating+Private.h"

#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Private.h"

#import "Utilities.h"

@implementation MusicLibraryRating

@dynamic displayName;
@dynamic mutableTracks;

@synthesize rating = _rating;
@dynamic tracks;

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_rating = 0;
	_tracks = [[NSMutableArray alloc] init];
	_needsTrackOrdering = NO;
	
	return self;
}

- (id)copyWithZone:(NSZone*)zone {
	MusicLibraryRating* copy = [[[self class] alloc] init];
	
	copy.rating = self.rating;
	[copy->_tracks addObjectsFromArray:self.tracks];
	_needsTrackOrdering = NO;

	return copy;
}


- (NSString*)displayName {
	NSString* displayName = nil;
	NSUInteger value = self.rating;
	
	if(value >= 100) {
		displayName = @"★★★★★";
	} else if(value >= 90) {
		displayName = @"★★★★½";
	} else if(value >= 80) {
		displayName = @"★★★★";
	} else if(value >= 70) {
		displayName = @"★★★½";
	} else if(value >= 60) {
		displayName = @"★★★";
	} else if(value >= 50) {
		displayName = @"★★½";
	} else if(value >= 40) {
		displayName = @"★★";
	} else if(value >= 30) {
		displayName = @"★½";
	} else if(value >= 20) {
		displayName = @"★";
	} else if(value >= 10) {
		displayName = @"½";
	} else {
		displayName = @"";
	}
	
	return displayName;
}

- (NSArray*)items {
	return self.tracks;
}

- (NSArray*)tracks {
	if(_needsTrackOrdering) {
		[self addAdditionalInfoToTracks];
		
		NSArray* albumSortDescriptors = [NSArray arrayWithObjects:
			[[NSSortDescriptor alloc] initWithKey:@"playCount" ascending:NO],
			[[NSSortDescriptor alloc] initWithKey:@"discNumber" ascending:YES],
			[[NSSortDescriptor alloc] initWithKey:@"trackNumber" ascending:YES],
			[[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES],
			nil];
		[_tracks sortUsingDescriptors:albumSortDescriptors];
		
		_needsTrackOrdering = NO;
	}
	
	return _tracks;
}

- (NSMutableArray*)mutableTracks {
	return _tracks;
}

- (BOOL)isEqual:(id)other {
	if([other isKindOfClass:[MusicLibraryRating class]]) {
		MusicLibraryRating* otherRating = other;
		
		return self.rating == otherRating.rating;
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
