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

#import "MusicLibraryTrack+Covers.h"
#import "MusicLibraryTrack+Scripting.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "PlayerController.h"

#import "NSArray+Additions.h"
#import "NSImage+Additions.h"
#import "NSImage+QuickLook.h"

@implementation MusicLibraryTrack(Covers)

@dynamic
	coverImage;

- (NSImage*)coverImage {
	if([[NSRunningApplication runningApplicationsWithBundleIdentifier:iTunesBundleIdentifier] count] <= 0) { return nil; }
//	if(![((SBApplication*)CSiTunesApplication()) isRunning]) { return nil; }
//	if(self.artworkCount <= 0) { return nil; } // iTunes does report 0 covers for some tracks
	
	NS_DURING
		iTunesArtwork* artwork = (id)[[[self scriptingObject] artworks] firstObject];

		NSData* artworkData = [artwork rawData];
		NSImage* image = [[NSImage alloc] initWithData:artworkData];
				
		NS_VALUERETURN(image, NSImage*);
				
		// return [(iTunesArtwork*)[[[self scriptingObject] artworks] firstObject] data]; // TODO
	NS_HANDLER
	NS_ENDHANDLER
	
	return nil;
}

@end
