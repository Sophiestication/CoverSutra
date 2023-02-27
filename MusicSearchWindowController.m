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

#import "MusicSearchMenuContentView.h"

#import "MusicSearchMenuView.h"
#import "MusicSearchMenuView+Layout.h"

#import "MusicSearchMenuItemView.h"

#import "MusicLibraryQuery.h"
#import "MusicLibraryQuery+Predicates.h"
#import "MusicLibraryQuery+Delegate.h"

#import "MusicLibrary.h"
#import "MusicLibrary+Private.h"

#import "MusicLibraryPlaylist.h"
#import "MusicLibraryPlaylist+Scripting.h"

#import "MusicLibraryTrack.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "StatusItemController.h"

#import "PopupSearchField.h"
#import "PopupSearchFieldEditor.h"

#import "NSArray+Additions.h"
#import "NSEvent+Additions.h"
#import "NSImage+Additions.h"
#import "NSShadow+Additions.h"

#import "CoverSutra.h"

#import "Utilities.h"

NSString* const MusicSearchMenuDidBeginTrackingNotification = @"com.sophiestication.CoverSutra.musicSearchMenuDidBeginTracking";
NSString* const MusicSearchMenuDidEndTrackingNotification = @"com.sophiestication.CoverSutra.musicSearchMenuDidEndTracking";

@implementation MusicSearchWindowController

@synthesize query = _query;
@dynamic filter;
@synthesize previousContent = _previousContent;

+ (MusicSearchWindowController*)musicSearchWindowController {
	MusicSearchWindowController* musicSearchWindowController = [[self alloc] initWithWindowNibName:@"MusicSearchWindow"];
	return musicSearchWindowController;
}

- (id)initWithWindow:(NSWindow*)window {
	if((self = [super initWithWindow:window])) {
		_query = [[MusicLibraryQuery alloc] init];
		_query.delegate = self;
	}

	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	NSPanel* window = (NSPanel*)[self window];
    
    [window setOpaque:NO];
    [window setHasShadow:NO];
    [window setAlphaValue:0.0];
	[window setBackgroundColor:[NSColor clearColor]];
    
    [window useOptimizedDrawing:YES];
    [window setAutodisplay:YES];
    
	[window setHidesOnDeactivate:NO];
    [window setCanHide:NO];
    
    [window setIgnoresMouseEvents:NO];
    [window setMovable:YES];
    
	[window setLevel:kCGStatusWindowLevel];
	[window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorTransient|NSWindowCollectionBehaviorFullScreenAuxiliary];
    
    // [window setOneShot:YES];
    // [window setDisplaysWhenScreenProfileChanges:YES];
	
	NSImage* advancedImage = [NSImage templateImageNamed:ImageNameAdvancedTemplate];
	[advancedImage setSize:NSMakeSize(32.0, 32.0)];
	
	[actionButton setSegmentCount:1];
	[[actionButton cell] setBordered:NO];
	[actionButton setImage:advancedImage
		forSegment:0];
	[actionButton setMenu:[[CoverSutra self] valueForKeyPath:@"actionMenu"]
		forSegment:0];
	[actionButton setImageScaling:NSImageScaleProportionallyUpOrDown forSegment:0];
	
	// Setup the title text field
	NSMutableAttributedString* title = [[NSMutableAttributedString alloc]
		initWithAttributedString:[titleField attributedStringValue]];
	
	NSFont* titleFont = [NSFont fontWithName:@"Gill Sans" size:16.0];
	
	if(!titleFont) {
		titleFont = [NSFont controlContentFontOfSize:14.0];
	}
	
	[title addAttribute:NSFontAttributeName
		value:titleFont
		range:NSMakeRange(0, [title length])];
	
	NSShadow* shadow = [NSShadow navigationBarImageShadow];
	
	[title addAttribute:NSShadowAttributeName
		value:shadow
		range:NSMakeRange(0, [title length])];
	[title addAttribute:NSForegroundColorAttributeName
		value:[NSColor whiteColor]
		range:NSMakeRange(0, [title length])];
	
	[titleField setAttributedStringValue:title];
	
	// ...
	NSNumber* aFilter = [[NSUserDefaultsController sharedUserDefaultsController]
		valueForKeyPath:@"values.musicSearchFilter"];
		
	if(aFilter) {
		[searchField setFilter:[aFilter intValue]];
	}
	
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_searchMenuFrameDidChange:)
		name:NSViewFrameDidChangeNotification
		object:searchMenu];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_searchMenuFrameDidChange:)
		name:NSWindowDidMoveNotification
		object:[[CoverSutra self] valueForKeyPath:@"statusItemController.statusItem.view.window"]];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_windowDidChangeScreen:)
		name:NSWindowDidChangeScreenNotification
		object:window];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_windowDidChangeScreen:)
		name:NSApplicationDidChangeScreenParametersNotification
		object:nil];
		
	[self tile];
	
	[[CoverSutra self] musicLibrary];
	
	[self performSelector:@selector(search:)
		withObject:searchField
		afterDelay:0.0];
	
//	[searchMenu bind:@"content"
//		toObject:self
//		withKeyPath:@"query.results"
//		options:nil];
}

- (PopupSearchFieldFilter)filter {
	return searchField.filter;
}

- (void)setFilter:(PopupSearchFieldFilter)aFilter {
	searchField.filter = aFilter;
}

- (IBAction)toggleWindowShown:(id)sender {
	if([self isVisible]) {
		[self orderOut:sender];
	} else {
		[self orderFront:sender];	
	}
}

- (IBAction)search:(id)sender {
	MusicLibraryQuery* query = self.query;
	
	NSString* searchTerm = [NSString stringWithString:[sender stringValue]];
	PopupSearchFieldFilter aFilter = searchField.filter;

	if(IsEmpty(searchTerm) && aFilter != PopupSearchFieldPlaylistFilter) {
		[query stopQuery];
		return;
	}

	if(aFilter == PopupSearchFieldAllFilter) {
		query.searchScopes = [NSArray arrayWithObject:MusicLibraryTracksSearchScope];
		query.groupingKind = MusicLibraryAlbumGroupingKind;
		query.predicate = [MusicLibraryQuery predicateForGenericSearch:searchTerm];
		query.completeAlbums = NO;
	} else if(aFilter == PopupSearchFieldSongFilter) {
		query.searchScopes = [NSArray arrayWithObject:MusicLibraryTracksSearchScope];
		query.groupingKind = MusicLibraryArtistGroupingKind;
		query.predicate = [MusicLibraryQuery predicateForSongSearch:searchTerm];
		query.completeAlbums = NO;
	} else if(aFilter == PopupSearchFieldAlbumFilter) {
		query.searchScopes = [NSArray arrayWithObject:MusicLibraryTracksSearchScope];
		query.groupingKind = MusicLibraryAlbumGroupingKind;
		query.predicate = [MusicLibraryQuery predicateForAlbumSearch:searchTerm];
		query.completeAlbums = NO;
	} else if(aFilter == PopupSearchFieldArtistFilter) {
		query.searchScopes = [NSArray arrayWithObject:MusicLibraryTracksSearchScope];
		query.groupingKind = MusicLibraryAlbumGroupingKind;
		query.predicate = [MusicLibraryQuery predicateForArtistSearch:searchTerm];
		query.completeAlbums = NO;
	} else if(aFilter == PopupSearchFieldUserRatingFilter) {
		query.searchScopes = [NSArray arrayWithObject:MusicLibraryTracksSearchScope];
		query.groupingKind = MusicLibraryRatingGroupingKind;
		query.predicate = [MusicLibraryQuery predicateForUserRatingSearch:
			([searchTerm integerValue] * 20)];
		query.completeAlbums = NO;
	} else if(aFilter == PopupSearchFieldPlaylistFilter) {
		query.searchScopes = [NSArray arrayWithObject:MusicLibraryPlaylistsSearchScope];
		query.groupingKind = MusicLibraryPlaylistCategoryGroupingKind;
		
		if(IsEmpty(searchTerm)) {
			query.predicate = [NSPredicate predicateWithValue:YES]; // We like to see all
		} else {
			query.predicate = [MusicLibraryQuery predicateForPlaylistSearch:searchTerm];
		}
		
		query.completeAlbums = NO;
	}
	
	if(![query isStarted]) {
//		self.previousContent = searchMenu.content;
		[query startQuery];
	}
}

- (IBAction)filterByAll:(id)sender {
	[self _setFilter:PopupSearchFieldAllFilter];
	[self search:searchField];
}

- (IBAction)filterByArtist:(id)sender {
	[self _setFilter:PopupSearchFieldArtistFilter];
	[self search:searchField];
}

- (IBAction)filterByAlbum:(id)sender {
	[self _setFilter:PopupSearchFieldAlbumFilter];
	[self search:searchField];
}

- (IBAction)filterBySong:(id)sender {
	[self _setFilter:PopupSearchFieldSongFilter];
	[self search:searchField];
}

- (IBAction)filterByUserRating:(id)sender {
	[self _setFilter:PopupSearchFieldUserRatingFilter];
	[self search:searchField];
}

- (IBAction)filterByPlaylist:(id)sender {
	[self _setFilter:PopupSearchFieldPlaylistFilter];
	[self search:searchField];
}

- (void)_setFilter:(PopupSearchFieldFilter)aFilter {
	[[NSUserDefaultsController sharedUserDefaultsController]
		setValue:[NSNumber numberWithInt:aFilter]
		forKeyPath:@"values.musicSearchFilter"];
		
	searchField.filter = aFilter;
}

- (void)musicLibraryQuery:(MusicLibraryQuery*)query foundItems:(id)items {
	[self _updateCancelledState];
	searchMenu.content = items;
}

- (void)musicLibraryQuery:(MusicLibraryQuery*)query didFinishGathering:(id)foundItems {
	[self _updateCancelledState];
	searchMenu.content = foundItems;
	
	NSScrollView* scrollView = [searchMenu enclosingScrollView];
	
	if([scrollView respondsToSelector:@selector(flashScrollers)]) {
//		if(![[self previousContent] isEqualToArray:(NSArray*)foundItems]) {
			[scrollView flashScrollers];
//		}
	}
	
//	self.previousContent = nil;
}

- (void)tile {
	NSRect searchMenuFrame = searchMenu.bounds;
	NSRect scrollViewFrame = [[searchMenu enclosingScrollView] frame];
	
	CGFloat heightDelta = NSHeight(searchMenuFrame) - NSHeight(scrollViewFrame);
	
	NSRect newWindowFrame = self.window.frame;
	NSScreen* screen = self.window.screen ? self.window.screen : [NSScreen mainScreen];
	
	newWindowFrame.size.height += heightDelta;
	
	NSWindow* statusItemWindow = [[CoverSutra self] valueForKeyPath:@"statusItemController.statusItem.view.window"];
	NSRect statusItemWindowFrame = [statusItemWindow frame];

	CGFloat windowScale = [statusItemWindow backingScaleFactor];

	CGFloat statusItemLocation = NSMaxX(statusItemWindowFrame) - (14.0 / windowScale);
	
	NSPoint newOrigin = NSMakePoint(
		statusItemLocation - NSWidth(newWindowFrame) + (36.0 + 8.0) / windowScale,
		NSMaxY(screen.frame) - [[NSStatusBar systemStatusBar] thickness] - NSHeight(newWindowFrame));
	
	newWindowFrame.origin = newOrigin;
	
	newWindowFrame = [self.window constrainFrameRect:newWindowFrame
		toScreen:screen];
	
//	newWindowFrame.origin.x -= 1.0;
	newWindowFrame.origin.y += 9.0;

	[self.window setFrame:newWindowFrame display:YES];
	[self.window.contentView setNeedsDisplay:YES];
	[self _updateCancelledState];
}

- (void)_updateCancelledState {
	if((IsEmpty(searchField.stringValue) || (self.query.gathering && IsEmpty(self.query.results))) && searchField.filter != PopupSearchFieldPlaylistFilter) {
		[[searchMenu enclosingScrollView] setHidden:YES];
		[(id)[[self window] contentView] setSearchResultsShown:NO];
	} else {
		[[searchMenu enclosingScrollView] setHidden:NO];
		[(id)[[self window] contentView] setSearchResultsShown:YES];
	}
}

- (float)animationOrderInTime {
	return .05;
}

- (float)animationOrderOutTime {
	return .15;
}

- (void)windowDidBecomeKey:(NSNotification*)notification {
	if([self isOrderingOut]) {
		[self orderFront:notification];
	}
	
	if(![[self window] makeFirstResponder:searchField]) {
		NSLog(@"can't make search field first responder");
	}
	
	[self tile];
}

- (void)windowDidResignKey:(NSNotification*)notification {
	[self orderOut:notification];
}

- (void)orderFront:(id)sender {
	[self orderFront:sender animate:YES];
	[[self window] makeKeyWindow];
	
	if(![[[CoverSutra self] statusItemController] statusItemShown]) {
		[[[CoverSutra self] statusItemController] setStatusItemShown:YES];
	}

	[[NSNotificationCenter defaultCenter]
		postNotificationName:MusicSearchMenuDidBeginTrackingNotification
		object:self];
}

- (void)orderOut:(id)sender {
	[self orderOut:sender animate:YES];
	
	id statusItemShown = [[[NSUserDefaultsController sharedUserDefaultsController] values]
		valueForKey:@"statusItemShown"];
	
	if(!ToBoolean(statusItemShown)) {
		[[[CoverSutra self] statusItemController] setStatusItemShown:NO];
	}
	
	[[NSNotificationCenter defaultCenter]
		postNotificationName:MusicSearchMenuDidEndTrackingNotification
		object:self];
}

- (id)windowWillReturnFieldEditor:(NSWindow*)sender toObject:(id)anObject {
	if(anObject == searchField) {
		if(!_searchFieldEditor) {
			_searchFieldEditor = [[PopupSearchFieldEditor alloc] initWithFrame:NSZeroRect];
		}
	
		[_searchFieldEditor setDelegate:anObject];
	
		return _searchFieldEditor;
	}
	
	return nil;
}

- (void)cancelOperation:(id)sender {
	[self orderOut:sender];
	
	// We don't want to cancel a playlist query
	if(searchField.filter != PopupSearchFieldPlaylistFilter) {
		[self.query stopQuery];
	}
	
	[self _updateCancelledState];
}

- (void)insertNewline:(id)sender {
	MusicSearchMenuItemView* selectedMenuItem = [searchMenu menuItemViewForItem:searchMenu.selection];
	[selectedMenuItem performClick:sender];
	
	[selectedMenuItem highlight:YES];
	searchMenu.selection = selectedMenuItem.representedObject;
}

- (void)insertTab:(id)sender {
	PopupSearchFieldFilter aFilter = searchField.filter;
	
	switch(aFilter) {
		case PopupSearchFieldAllFilter:
			[self filterByArtist:sender];
		break;
		
		case PopupSearchFieldArtistFilter:
			[self filterByAlbum:sender];
		break;
		
		case PopupSearchFieldAlbumFilter:
			[self filterBySong:sender];
		break;
		
		case PopupSearchFieldSongFilter:
			[self filterByPlaylist:sender];
		break;
		
		case PopupSearchFieldUserRatingFilter:
//			[self filterByPlaylist:sender];
		break;
		
		case PopupSearchFieldPlaylistFilter:
			[self filterByAll:sender];
		break;
	};
}

- (void)insertTabIgnoringFieldEditor:(id)sender {
	[self insertTab:sender];
}

- (void)insertBacktab:(id)sender {
	PopupSearchFieldFilter aFilter = searchField.filter;
	
	switch(aFilter) {
		case PopupSearchFieldAllFilter:
			[self filterByPlaylist:sender];
		break;
		
		case PopupSearchFieldArtistFilter:
			[self filterByAll:sender];
		break;
		
		case PopupSearchFieldAlbumFilter:
			[self filterByArtist:sender];
		break;
		
		case PopupSearchFieldSongFilter:
			[self filterByAlbum:sender];
		break;
		
		case PopupSearchFieldUserRatingFilter:
//			[self filterBySong:sender];
		break;
		
		case PopupSearchFieldPlaylistFilter:
			[self filterBySong:sender];
		break;
	};
}

- (void)insertParagraphSeparator:(id)sender {
}

- (void)indent:(id)sender {
}

- (void)moveUp:(id)sender {
	NSUInteger modifierFlags = self.window.currentEvent.modifierFlags;
	
	if(modifierFlags & NSCommandKeyMask) {
		[searchMenu selectPreviousGroup:sender];
	} else {
		[searchMenu selectPreviousItem:sender];
	}
}

- (void)moveDown:(id)sender {
	NSUInteger modifierFlags = self.window.currentEvent.modifierFlags;
	
	if(modifierFlags & NSCommandKeyMask) {
		[searchMenu selectNextGroup:sender];
	} else {
		[searchMenu selectNextItem:sender];
	}
}

- (void)_searchMenuFrameDidChange:(NSNotification*)notification {
	[self tile];
}

- (void)_statusItemFrameDidChange:(NSNotification*)notification {
	[self tile];
}

- (void)_windowDidChangeScreen:(NSNotification*)notification {
	[self tile];
}

- (BOOL)validateMenuItem:(NSMenuItem*)menuItem {
	if([menuItem action] == @selector(filterByAll:)) {
		[menuItem setState:
			searchField.filter == PopupSearchFieldAllFilter ? NSOnState : NSOffState];
		return YES;
	}
	
	if([menuItem action] == @selector(filterByArtist:)) {
		[menuItem setState:
			searchField.filter == PopupSearchFieldArtistFilter ? NSOnState : NSOffState];
		return YES;
	}
	
	if([menuItem action] == @selector(filterByAlbum:)) {
		[menuItem setState:
			searchField.filter == PopupSearchFieldAlbumFilter ? NSOnState : NSOffState];
		return YES;
	}
	
	if([menuItem action] == @selector(filterBySong:)) {
		[menuItem setState:
			searchField.filter == PopupSearchFieldSongFilter ? NSOnState : NSOffState];
		return YES;
	}
	
	if([menuItem action] == @selector(filterByUserRating:)) {
		[menuItem setState:
			searchField.filter == PopupSearchFieldUserRatingFilter ? NSOnState : NSOffState];
		return YES;
	}
	
	if([menuItem action] == @selector(filterByPlaylist:)) {
		[menuItem setState:
			searchField.filter == PopupSearchFieldPlaylistFilter ? NSOnState : NSOffState];
		return YES;
	}
	
	if([menuItem action] == @selector(playNextInPartyShuffle:)) {
		MusicLibraryPlaylist* partyShuffle = [[[CoverSutra self] musicLibrary] playlistForType:MusicLibraryPartyShufflePlaylistType];
		
		if(partyShuffle && partyShuffle.visible) {
			[menuItem setRepresentedObject:partyShuffle];
			return YES;
		}

		return NO;
	}
	
	if([menuItem action] == @selector(playInLibrary:)) {
		[menuItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
		[menuItem setAlternate:YES];
	}
	
	if([menuItem action] == @selector(playAlbum:)) {
		[menuItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
		[menuItem setAlternate:YES];
		
		return self.query.groupingKind == MusicLibraryAlbumGroupingKind;
	}
	
	if([menuItem action] == @selector(addToPartyShuffle:)) {
		MusicLibraryPlaylist* partyShuffle = [[[CoverSutra self] musicLibrary] playlistForType:MusicLibraryPartyShufflePlaylistType];
		
		if(partyShuffle && partyShuffle.visible) {
			[menuItem setRepresentedObject:partyShuffle];
			return YES;
		}

		return NO;
	}
	
	if([menuItem action] == @selector(addToCurrentPlaylist:)) {
		iTunesPlaylist* playlist = [self currentPlaylist];
		NSString* newTitle = nil;
		
		if(playlist) {
			newTitle = [NSString stringWithFormat:NSLocalizedString(@"MEDIASEARCH_ADDTRACKTOPLAYLIST_MENUITEM", @""), playlist.name];
		} else {
			newTitle = NSLocalizedString(@"MEDIASEARCH_ADDTRACKTOCURRENTPLAYLIST_MENUITEM", @"");
		}
		
		[menuItem setHidden:playlist == nil];
		[menuItem setRepresentedObject:playlist];
		[menuItem setTitle:newTitle];
		
		return playlist != nil;
	}
	
	if([menuItem action] == @selector(showInFinder:)) {
		MusicLibraryTrack* track = searchMenu.selection;
		return track && track.locationURL; // needs to be a file track
	}
	
	return YES;
}

- (iTunesPlaylist*)currentPlaylist {
	iTunesApplication* application = CSiTunesApplication();
	iTunesPlaylist* playlist = nil;
	
	if(![application isRunning]) {
		return nil;
	}
	
	NS_DURING
		playlist = [application currentPlaylist];
		
		if(![self isPlaylistEditable:playlist]) {
			playlist = nil;
		}
	NS_HANDLER
		playlist = nil;
	NS_ENDHANDLER
	
	NS_DURING
		if(!playlist) {
			playlist = [(iTunesBrowserWindow*)[[application browserWindows] firstObject] view];
			
			if(![self isPlaylistEditable:playlist]) {
				playlist = nil;
			}
		}
	NS_HANDLER
		playlist = nil;
	NS_ENDHANDLER
	
	if(playlist) {
		// Check if the current playlistis the party shuffle playlist
		MusicLibraryPlaylist* partyShuffle = [[[CoverSutra self] musicLibrary] playlistForType:MusicLibraryPartyShufflePlaylistType];
		
		if(partyShuffle && EqualStrings(playlist.persistentID, partyShuffle.persistentID)) {
			return nil;
		}
	}

	return playlist;
}

- (BOOL)isPlaylistEditable:(iTunesPlaylist*)playlist {
	NS_DURING
		iTunesUserPlaylist* userPlaylist = (iTunesUserPlaylist*)playlist;

		if([userPlaylist specialKind] == iTunesESpKNone &&
		   ![[[userPlaylist propertyWithCode:'pSmt'] get] boolValue] && 
		   ![[[userPlaylist propertyWithCode:'pShr'] get] boolValue]) {
			return YES;
		}
	NS_HANDLER
	NS_ENDHANDLER
	
	return NO;
}

@end
