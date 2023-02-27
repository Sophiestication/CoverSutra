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

#import "WindowController.h"

#import "PopupSearchField.h"

extern NSString* const MusicSearchMenuDidBeginTrackingNotification;
extern NSString* const MusicSearchMenuDidEndTrackingNotification;

@class
	MusicSearchMenuView,
	PopupSearchField,
	PopupSearchFieldEditor,
	MusicLibraryQuery;

@interface MusicSearchWindowController : WindowController {
@public
	IBOutlet NSView* contentView;
	IBOutlet MusicSearchMenuView* searchMenu;
	IBOutlet NSView* searchMenuBar;
	IBOutlet NSTextField* titleField;
	IBOutlet PopupSearchField* searchField;
	
	IBOutlet NSMenu* albumActions;
	IBOutlet NSMenu* playlistActions;
	IBOutlet NSMenu* trackActions;
	
	IBOutlet NSSegmentedControl* actionButton;
	
@private
	PopupSearchFieldEditor* _searchFieldEditor;
	MusicLibraryQuery* _query;
	NSArray* _previousContent;
}

@property(readwrite, strong) MusicLibraryQuery* query;

@property(readwrite) PopupSearchFieldFilter filter;

+ (MusicSearchWindowController*)musicSearchWindowController;

- (IBAction)toggleWindowShown:(id)sender;

- (void)orderFront:(id)sender;
- (void)orderOut:(id)sender;

- (IBAction)search:(id)sender;

- (IBAction)filterByAll:(id)sender;
- (IBAction)filterByArtist:(id)sender;
- (IBAction)filterByAlbum:(id)sender;
- (IBAction)filterBySong:(id)sender;
- (IBAction)filterByUserRating:(id)sender;
- (IBAction)filterByPlaylist:(id)sender;

- (void)tile;

@end
