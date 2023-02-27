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

#import "PopupSearchFieldCell.h"
#import "PopupSearchFieldEditor.h"

#import "PopupSearchButtonCell.h"

#import "NSImage+Additions.h"

@implementation PopupSearchFieldCell

- (id)initWithCoder:(id)coder {
	if(![super initWithCoder:coder]) {
		return nil;
	}

	[self initView];

	return self;
}

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	[self initView];
	
	return self;
}

- (PopupSearchFieldFilter)filter {
	return _filter;
}

- (void)setFilter:(PopupSearchFieldFilter)filter {
	_filter = filter;
	
	NSButtonCell* searchButtonCell = [self searchButtonCell];
	[searchButtonCell setImage:[self _imageForFilter:_filter]];
	
	[self setSendsSearchStringImmediately:filter == PopupSearchFieldPlaylistFilter];
}

- (NSSize)cellSize {
	NSSize capSize = [_leftCapImage size];
	NSSize cellSize = [super cellSize];
	
	cellSize.height = capSize.height;
	
	return cellSize;
}

- (NSSize)cellSizeForBounds:(NSRect)aRect {
	NSSize cellSize = [super cellSizeForBounds:aRect];
	
	NSSize capSize = [_leftCapImage size];
	cellSize.height = capSize.height;
	
	return cellSize;
}

- (NSRect)searchButtonRectForBounds:(NSRect)rect {
	NSSize leftCapSize = [_leftCapImage size];
	
	return NSMakeRect(
		NSMinX(rect), NSMinY(rect) + 1.0,
		leftCapSize.width, NSHeight(rect));
}

- (NSRect)searchTextRectForBounds:(NSRect)rect {
	NSRect searchButtonRect = [self searchButtonRectForBounds:rect];
	NSRect cancelButtonRect = [self cancelButtonRectForBounds:rect];

	return NSMakeRect(
		NSMaxX(searchButtonRect), NSMinY(rect) + 3.0,
		NSWidth(rect) - NSWidth(searchButtonRect) - (NSMaxX(rect) - NSMinX(cancelButtonRect)), 18.0);
}

- (NSRect)cancelButtonRectForBounds:(NSRect)rect {
	float width = 20.0;
	float rightMargin = 2.0;
	
	return NSMakeRect(
		NSMaxX(rect) - width - rightMargin, NSMinY(rect) + 1.0,
		width, NSHeight(rect));
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSDrawThreePartImage(
		cellFrame,
		_leftCapImage,
		_fillImage,
		_rightCapImage,
		NO,
		NSCompositeSourceOver,
		1.0,
		[controlView isFlipped]);

	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)initView {
	_leftCapImage = [NSImage imageNamed:@"popupSearchLeft"];
	_fillImage = [NSImage imageNamed:@"popupSearchFill"];
	_rightCapImage = [NSImage imageNamed:@"popupSearchRight"];
	
	[self setSearchButtonCell:
		[[PopupSearchButtonCell alloc] initImageCell:nil]];
	[self setSearchMenuTemplate:
		[self _filterMenu]];
	[self setFilter:PopupSearchFieldAllFilter];
	
	[self setFont:
		[NSFont controlContentFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
}

- (NSImage*)_imageForFilter:(PopupSearchFieldFilter)filter {
	switch(filter) {
		case PopupSearchFieldAllFilter:
			return [NSImage imageNamed:@"allFilter"];
		break;
		
		case PopupSearchFieldArtistFilter:
			return [NSImage imageNamed:@"artistFilter"];
		break;
		
		case PopupSearchFieldAlbumFilter:
			return [NSImage imageNamed:@"albumFilter"];
		break;
		
		case PopupSearchFieldSongFilter:
			return [NSImage imageNamed:@"songFilter"];
		break;
		
		case PopupSearchFieldUserRatingFilter:
			return [NSImage imageNamed:@"ratingFilter"];
		break;
		
		case PopupSearchFieldPlaylistFilter:
			return [NSImage imageNamed:@"playlistFilter"];
		break;
	}
	
	return nil;
}

- (NSMenu*)_filterMenu {
	NSMenu* menu = [[NSMenu alloc] initWithTitle:@""];
	
	[menu setDelegate:self];
	
	[menu addItemWithTitle:NSLocalizedString(@"MEDIASEARCH_FINDALL_MENUITEM", @"") action:@selector(filterByAll:) keyEquivalent:@""];
//	[menuItem setImage:[self _imageForFilter:PopupSearchFieldAllFilter]];
	
//	[menu addItem:[NSMenuItem separatorItem]];
	
	[menu addItemWithTitle:NSLocalizedString(@"MEDIASEARCH_FINDARTIST_MENUITEM", @"") action:@selector(filterByArtist:) keyEquivalent:@""];
//	[menuItem setImage:[self _imageForFilter:PopupSearchFieldArtistFilter]];
	
	[menu addItemWithTitle:NSLocalizedString(@"MEDIASEARCH_FINDALBUM_MENUITEM", @"") action:@selector(filterByAlbum:) keyEquivalent:@""];
//	[menuItem setImage:[self _imageForFilter:PopupSearchFieldAlbumFilter]];
	
	[menu addItemWithTitle:NSLocalizedString(@"MEDIASEARCH_FINDSONG_MENUITEM", @"") action:@selector(filterBySong:) keyEquivalent:@""];
//	[menuItem setImage:[self _imageForFilter:PopupSearchFieldSongFilter]];

	// TODO
//	menuItem = [menu addItemWithTitle:NSLocalizedString(@"MEDIASEARCH_FINDRATING_MENUITEM", @"") action:@selector(filterByUserRating:) keyEquivalent:@""];
//	[menuItem setImage:[self _imageForFilter:PopupSearchFieldUserRatingFilter]];
	
	[menu addItem:[NSMenuItem separatorItem]];
	
	[menu addItemWithTitle:NSLocalizedString(@"MEDIASEARCH_FINDPLAYLIST_MENUITEM", @"") action:@selector(filterByPlaylist:) keyEquivalent:@""];
//	[menuItem setImage:[self _imageForFilter:PopupSearchFieldPlaylistFilter]];
	
	return menu;
}

@end
