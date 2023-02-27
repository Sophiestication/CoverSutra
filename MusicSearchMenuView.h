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

@class
	PopupSearchField,
	MusicLibraryAlbum,
	MusicSearchMenuItemView,
	AlbumCoverCache;

@interface MusicSearchMenuView : NSView {
@private
	id __unsafe_unretained _delegate;
	
	id _content;
	id _selection;
	
	AlbumCoverCache* _coverCache;
	
	NSArray* _defaultSubviews;
	
	MusicSearchMenuItemView* _playAllMenuItem;
	MusicSearchMenuItemView* _noResultsMenuItem;
	
	MusicLibraryAlbum* _selectedAlbum;
}

@property(readwrite, unsafe_unretained) id delegate;

@property(readwrite, strong) id content;
@property(readwrite, strong) id selection;

@property(readwrite, strong) MusicLibraryAlbum* selectedAlbum;

- (void)selectPreviousItem:(id)sender;
- (void)selectNextItem:(id)sender;

- (void)selectPreviousGroup:(id)sender;
- (void)selectNextGroup:(id)sender;

@end
