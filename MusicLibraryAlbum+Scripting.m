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

#import "MusicLibraryAlbum+Scripting.h"

#import "MusicLibrary.h"
#import "MusicLibrary+Scripting.h"

#import "MusicLibraryTrack+Scripting.h"

#import "PlaybackController.h"
#import "PlaybackController+Private.h"

#import "CoverSutra.h"

#import "iTunesAPI+Additions.h"

#import "NSArray+Additions.h"

@implementation MusicLibraryAlbum(Scripting)

- (void)play {
	@autoreleasepool {
	
		NS_DURING
			iTunesApplication* application = CSiTunesApplication();
			iTunesPlaylist* playlist = [application musicSearchPlaylist];
			
			// Clear the current "CoverSutra" playlist and add the new tracks to it
			[playlist.tracks removeAllObjects];
			[self addToPlaylist:playlist];
		
			// Tell our playback controller to ignore the next player notification
			[[[CoverSutra self] playbackController] setShouldNotNotifyAboutTrackChanges:YES];
			
			// Play track and reveal it in iTunes
			[playlist playOnce:NO];
			[playlist selectInBrowserWindow];
		NS_HANDLER
			NSLog(@"Error in music library album: %@", localException);
		NS_ENDHANDLER
	
	}
}

- (void)addToPlaylist:(iTunesPlaylist*)playlist {
	for(MusicLibraryTrack* track in self.tracks) {
		[track addToPlaylist:playlist];
	}
}

@end
