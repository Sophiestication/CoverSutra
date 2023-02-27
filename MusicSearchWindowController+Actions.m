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

#import "MusicSearchWindowController.h"
#import "MusicSearchWindowController+Actions.h"
#import "MusicSearchWindowController+Private.h"

#import "MusicLibrary.h"
#import "MusicLibraryAlbum.h"
#import "MusicLibraryPlaylist.h"

#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Scripting.h"

#import "MusicSearchMenuView.h"
#import "MusicSearchMenuView+Layout.h"

#import "CoverSutra.h"

#import "NSArray+Additions.h"

@implementation MusicSearchWindowController(Actions)

- (IBAction)play:(id)sender {
//	[[[CoverSutra self] player] _setIgnoreNextSongChangeNotification:YES];

	id target = nil;
	SEL selector = NULL;
	id object = nil;

	if(searchMenu.selectedAlbum) {
		target = searchMenu.selectedAlbum;
		selector = @selector(play);
	} else if([[searchMenu selection] isKindOfClass:[MusicLibraryPlaylist class]]) {
		target = searchMenu.selection;
		selector = @selector(play);
	} else {
		target = searchMenu.selection;
		selector = @selector(play);
	}

	NSInvocationOperation* operation = [[NSInvocationOperation alloc]
		initWithTarget:target
		selector:selector
		object:object];
		
	[[[[CoverSutra self] musicLibrary] operationQueue] addOperation:operation];
	
}

- (IBAction)playInLibrary:(id)sender {
	MusicLibraryTrack* track = [[searchMenu.selectedAlbum tracks] firstObject];
	[track performSelectorInBackground:@selector(play)
		withObject:nil];
}

- (IBAction)playAlbum:(id)sender {
	MusicLibraryItem* item = [searchMenu parentForItem:searchMenu.selection];
	[item performSelectorInBackground:@selector(play)
		withObject:nil];
}

- (IBAction)playNextInPartyShuffle:(id)sender {
	MusicLibraryItem* item = searchMenu.selectedAlbum ? searchMenu.selectedAlbum : searchMenu.selection;
	[item performSelectorInBackground:@selector(playNextInPartyShuffle)
		withObject:nil];
}

- (IBAction)show:(id)sender {
	[[[self window] windowController] orderOut:sender];

	MusicLibraryItem* item = searchMenu.selection;
	[item performSelectorInBackground:@selector(show)
		withObject:nil];
}

- (IBAction)showInFinder:(id)sender {
	[[[self window] windowController] orderOut:sender];
	
	MusicLibraryTrack* track = searchMenu.selection;
	[track showInFinder];
}

- (IBAction)addToPartyShuffle:(id)sender {
	MusicLibraryItem* item = searchMenu.selectedAlbum ? searchMenu.selectedAlbum : searchMenu.selection;
	[item performSelectorInBackground:@selector(addToPlaylist:)
		withObject:[[sender representedObject] scriptingObject]];
}

- (IBAction)addToCurrentPlaylist:(id)sender {
	MusicLibraryItem* item = searchMenu.selectedAlbum ? searchMenu.selectedAlbum : searchMenu.selection;
	[item performSelectorInBackground:@selector(addToPlaylist:)
		withObject:[sender representedObject]];
}

@end
