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

#import "MusicLibraryTrack+UIAdditions.h"

#import "MusicLibraryAlbum.h"
#import "MusicLibraryAlbum+Private.h"

#import "Utilities.h"

@implementation MusicLibraryTrack(UIAdditions)

@dynamic
	tooltipString,
	albumCoverTitle,
	albumCoverSecondaryTitle;

- (NSString*)tooltipString {
	NSMutableArray* lines = [NSMutableArray array];
	
	// Add track number and display name
	NSString* time = self.time;
	
	if(IsEmpty(time)) {
		[lines addObject:self.displayName];
	} else {
		NSString* title = [NSString stringWithFormat:@"%@ (%@)",
			self.displayName,
			time];
		[lines addObject:title];
	}
	
	// Add artist info
	NSString* displayArtist = self.artist;
	
	if(!IsEmpty(displayArtist)) {
		[lines addObject:displayArtist];
	}
	
	// Add album info
	NSString* displayAlbum = self.displayAlbum;
	
	if(!IsEmpty(displayAlbum)) {
		[lines addObject:displayAlbum];
	}
	
	// Add display rating value if needed
	NSString* rating = self.displayRating;
	
	if(!IsEmpty(rating)) {
		[lines addObject:rating];
	}
	
	// Add display track number
	NSString* trackNumber = self.displayTrackNumber;
	
	if(!IsEmpty(trackNumber)) {
		[lines addObject:trackNumber];
	}
	
//	// Add genre if needed
//	NSString* genre = self.genre;
//	
//	if(!IsEmpty(genre)) {
//		[lines addObject:genre];
//	}
	
	return [lines componentsJoinedByString:@"\n"];
}

- (NSString*)albumCoverTitle {
	return self.displayName;
}

- (NSString*)albumCoverSecondaryTitle {
	if(self.streamed) {
		return self.displayArtist;
	}
	
	return [NSString stringWithFormat:@"%@ - %@", self.displayAlbum, self.displayAlbumArtist];
}

@end
