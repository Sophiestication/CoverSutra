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

#import "MusicLibraryPlaylist+Scripting.h"

#import "MusicLibrary.h"
#import "MusicLibrary+Scripting.h"

#import "CoverSutra.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "NSArray+Additions.h"

#import "Utilities.h"

@implementation MusicLibraryPlaylist(Scripting)

- (iTunesPlaylist*)scriptingObject {
	iTunesPlaylist* scriptingObject = nil;
	
	NS_DURING
		// Broke since iTunes 10.5 Beta 3
//		iTunesSource* library = [[[CoverSutra self] musicLibrary] scriptingObject];
//	
//		NSArray* filteredPlaylists = [library.playlists filteredArrayUsingPredicate:
//			[NSPredicate predicateWithFormat:@"persistentID == %@", self.persistentID]];
		
		SBElementArray* playlists = [[[[CoverSutra self] musicLibrary] scriptingObject] playlists];
		
		for(iTunesPlaylist* playlist in playlists) {
			if(EqualStrings([playlist persistentID], [self persistentID])) {
				scriptingObject = playlist;
				break;
			}
		}
		
//		playlist = [[filteredPlaylists firstObject] get];
	NS_HANDLER
	NS_ENDHANDLER
	
	return scriptingObject;
}

- (void)play {
//	@autoreleasepool {
	
		NS_DURING
			iTunesPlaylist* playlist = [self scriptingObject];
			
			if([[playlist tracks] count] > 0) {
				[playlist playOnce:NO];
				[playlist selectInBrowserWindow];
			} else {
				[CSiTunesApplication() activate];
				[playlist reveal];
			}
		NS_HANDLER
			NSLog(@"Error in music library playlist: %@", localException);
		NS_ENDHANDLER
	
//	}
}

- (void)show {
//	@autoreleasepool {
	
		NS_DURING
			[CSiTunesApplication() activate];
			[[self scriptingObject] reveal];
		NS_HANDLER
			NSLog(@"Error in music library playlist: %@", localException);
		NS_ENDHANDLER
	
//	}
}

@end
