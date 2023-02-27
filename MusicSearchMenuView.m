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

#import "MusicSearchMenuView.h"
#import "MusicSearchMenuView+Layout.h"
#import "MusicSearchMenuView+Private.h"

#import "MusicSearchGroupView.h"
#import "MusicSearchMenuItemView.h"

#import "PopupSearchField.h"

#import "NSArray+Additions.h"
#import "NSBezierPath+Additions.h"
#import "NSColor+Additions.h"
#import "NSGradient+Additions.h"
#import "NSImage+Additions.h"

#import "iTunesAPI.h"

#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Scripting.h"

#import "MusicLibraryAlbum.h"

#import "MusicSearchMenuItemCell.h"

#import "CoverSutra.h"

#import "Utilities.h"

#import <QuartzCore/CoreAnimation.h>

@implementation MusicSearchMenuView

@synthesize
	delegate = _delegate,
	selectedAlbum = _selectedAlbum,
	defaultSubviews = _defaultSubviews,
	coverCache = _coverCache;
	
@dynamic content;
@dynamic selection;
	
+ (id)defaultAnimationForKey:(NSString*)key {
	return [super defaultAnimationForKey:key];
}

- (id)initWithFrame:(NSRect)frame {
    if(![super initWithFrame:frame]) {
		return nil;
	}
	
	[self initView];
	
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    if(![super initWithCoder:coder]) {
		return nil;
	}
	
	[self initView];
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)content {
	return _content;
}

- (void)setContent:(id)content {
	if(content != _content) {
		_content = content;
		
		[self tile];
	}
}

- (id)selection {
	return _selection;
}

- (void)setSelection:(id)selection {
	if(selection != _selection) {
		if(_selection) {
			MusicSearchMenuItemView* menuItemView = [self menuItemViewForItem:_selection];
			[[menuItemView cell] setHighlighted:NO];
		}
		
		self.selectedAlbum = nil;
		
		_selection = selection;
	}
}

- (void)selectPreviousItem:(id)sender {
	MusicLibraryItem* selectedItem = self.selection;
	MusicLibraryItem* parentItem = [self parentForItem:selectedItem];

	if(IsEmpty(self.content)) {
		return;
	}
	
	MusicLibraryItem* newSelectedItem = nil;
	MusicLibraryItem* newParentItem = nil;
	
	if(!parentItem) {
		newParentItem = [self.content firstObject];
		newSelectedItem = [newParentItem.items firstObject];
		
		self.selection = newSelectedItem;
		[self _updateSelectionForItem:newSelectedItem parentItem:newParentItem makeVisible:YES selectedPrevious:YES];
	
		return;
	}
	
	if(selectedItem == parentItem.items.firstObject) {
		NSUInteger indexOfSelectedParentItem = [self.content indexOfObject:parentItem];
		
		if(indexOfSelectedParentItem == 0) {
			return;
		}
		
		newParentItem = [self.content objectAtIndex:--indexOfSelectedParentItem];
		newSelectedItem = [newParentItem.items lastObject];
	} else {
		NSUInteger indexOfSelectedItem = [parentItem.items indexOfObject:selectedItem];
		
		newParentItem = parentItem;
		newSelectedItem = [parentItem.items objectAtIndex:--indexOfSelectedItem];
	}
	
	self.selection = newSelectedItem;
	[self _updateSelectionForItem:newSelectedItem parentItem:newParentItem makeVisible:YES selectedPrevious:YES];
}

- (void)selectNextItem:(id)sender {
	MusicLibraryItem* selectedItem = self.selection;
	MusicLibraryItem* parentItem = [self parentForItem:selectedItem];

	if(IsEmpty(self.content)) {
		return;
	}
	
	MusicLibraryItem* newSelectedItem = nil;
	MusicLibraryItem* newParentItem = nil;

	if(!parentItem) {
		newParentItem = [self.content firstObject];
		newSelectedItem = [newParentItem.items firstObject];
		
		self.selection = newSelectedItem;
		[self _updateSelectionForItem:newSelectedItem parentItem:newParentItem makeVisible:YES selectedPrevious:NO];
		
		return;
	}
	
	if(!parentItem) {
		newParentItem = [self.content firstObject];
		newSelectedItem = [parentItem.items firstObject];
		
		self.selection = newSelectedItem;
		[self _updateSelectionForItem:newSelectedItem parentItem:newParentItem makeVisible:YES selectedPrevious:NO];
	
		return;
	}
	
	if(selectedItem == parentItem.items.lastObject) {
		if(parentItem == [self.content lastObject]) {
			return;
		}
		
		NSUInteger indexOfSelectedParentItem = [self.content indexOfObject:parentItem];
		
		newParentItem = [self.content objectAtIndex:++indexOfSelectedParentItem];
		newSelectedItem = [newParentItem.items firstObject];
	} else {
		NSUInteger indexOfSelectedItem = [parentItem.items indexOfObject:selectedItem];
		
		newParentItem = parentItem;
		newSelectedItem = [parentItem.items objectAtIndex:++indexOfSelectedItem];
	}
	
	self.selection = newSelectedItem;
	[self _updateSelectionForItem:newSelectedItem parentItem:newParentItem makeVisible:YES selectedPrevious:NO];
}

- (void)selectPreviousGroup:(id)sender {
	MusicLibraryItem* selectedItem = self.selection;
	MusicLibraryItem* parentItem = [self parentForItem:selectedItem];

	if(IsEmpty(self.content)) {
		return;
	}
	
	MusicLibraryItem* newSelectedItem = nil;
	MusicLibraryItem* newParentItem = nil;

	if(!parentItem) {
		newParentItem = [self.content firstObject];
		newSelectedItem = [newParentItem.items firstObject];
		
		self.selection = newSelectedItem;
		[self _updateSelectionForItem:newSelectedItem parentItem:newParentItem makeVisible:YES selectedPrevious:YES];
		
		return;
	}
	
	if(!parentItem) {
		parentItem = [self.content firstObject];
		selectedItem = [parentItem.items firstObject];
		
		self.selection = selectedItem;
		[self _updateSelectionForItem:selectedItem parentItem:parentItem makeVisible:YES selectedPrevious:YES];
		
		return;
	}

	if(!parentItem) {
		parentItem = [self.content firstObject];
		selectedItem = [parentItem.items firstObject];
		
		self.selection = selectedItem;
		[self _updateSelectionForItem:selectedItem parentItem:parentItem makeVisible:YES selectedPrevious:YES];
	
		return;
	}
	
	if(parentItem == [self.content firstObject]) {
		self.selection = [parentItem.items firstObject];
		[self _updateSelectionForItem:self.selection parentItem:parentItem makeVisible:YES selectedPrevious:YES];
		
		return;
	}
	
	NSUInteger indexOfSelectedParentItem = [self.content indexOfObject:parentItem];
	
	newParentItem = [self.content objectAtIndex:--indexOfSelectedParentItem];
	newSelectedItem = [newParentItem.items firstObject];
		
	self.selection = newSelectedItem;
	[self _updateSelectionForItem:newSelectedItem parentItem:newParentItem makeVisible:YES selectedPrevious:YES];
}

- (void)selectNextGroup:(id)sender {
	MusicLibraryItem* selectedItem = self.selection;
	MusicLibraryItem* parentItem = [self parentForItem:selectedItem];

	if(IsEmpty(self.content)) {
		return;
	}
	
	MusicLibraryItem* newSelectedItem = nil;
	MusicLibraryItem* newParentItem = nil;

	if(!parentItem) {
		newParentItem = [self.content firstObject];
		newSelectedItem = [newParentItem.items firstObject];
		
		self.selection = newSelectedItem;
		[self _updateSelectionForItem:newSelectedItem parentItem:newParentItem makeVisible:YES selectedPrevious:NO];
		
		return;
	}

	if(!parentItem) {
		parentItem = [self.content firstObject];
		selectedItem = [parentItem.items firstObject];
		
		self.selection = selectedItem;
		[self _updateSelectionForItem:selectedItem parentItem:parentItem makeVisible:YES selectedPrevious:NO];
	
		return;
	}
	
	if(parentItem == [self.content lastObject]) {
		self.selection = [parentItem.items lastObject];
		[self _updateSelectionForItem:self.selection parentItem:parentItem makeVisible:YES selectedPrevious:YES];
		
		return;
	}
	
	NSUInteger indexOfSelectedParentItem = [self.content indexOfObject:parentItem];
	
	newParentItem = [self.content objectAtIndex:++indexOfSelectedParentItem];
	newSelectedItem = [newParentItem.items firstObject];
		
	self.selection = newSelectedItem;
	[self _updateSelectionForItem:newSelectedItem parentItem:newParentItem makeVisible:YES selectedPrevious:NO];
}

- (BOOL)isFlipped {
	return YES;
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

- (BOOL)isOpaque {
	return NO;
}

/*
- (BOOL)wantsDefaultClipping {
    return NO;
}
*/

- (BOOL)acceptsFirstMouse:(NSEvent*)theEvent {
	return YES;
}

- (void)mouseExited:(NSEvent*)theEvent {
	MusicLibraryItem* selectedItem = self.selection;
	MusicSearchMenuItemView* menuItem = [self menuItemViewForItem:selectedItem];

	self.selection = nil;
	[[menuItem cell] setHighlighted:NO];
}

- (void)initView {
	// Register for control tint changeing notifications
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_controlTintDidChange:)
		name:NSControlTintDidChangeNotification
		object:NSApp];
	
	// Add play all menu item
	_playAllMenuItem = [[MusicSearchMenuItemView alloc] initWithFrame:NSZeroRect];
	
	[_playAllMenuItem setTitle:
		NSLocalizedString(@"MEDIASEARCH_PLAYALL_MENUITEM", @"Play all item in the search menu")];
	[_playAllMenuItem sizeToFit];
	
	[_playAllMenuItem setTarget:self];
	[_playAllMenuItem setAction:@selector(searchAll:)];
	
//	[self addSubview:_playAllMenuItem];
	
	// Add a no search results menu item
	_noResultsMenuItem = [[MusicSearchMenuItemView alloc] initWithFrame:NSZeroRect];
	
	[_noResultsMenuItem setTitle:
		NSLocalizedString(@"MEDIASEARCH_NOSEARCHRESULTS", @"No results item in the search menu")];
	[_noResultsMenuItem sizeToFit];
	[_noResultsMenuItem setEnabled:NO];
	
	[self addSubview:_noResultsMenuItem];
	
	self.defaultSubviews = self.subviews;
	
	// Make a new album cover cache
	_coverCache = [[AlbumCoverCache alloc] init];
	_coverCache.delegate = self;
	_coverCache.userSpaceScaleFactor = [[self window] userSpaceScaleFactor];
	
	// Tile the view
	[self tile];
}

- (void)_performClickOnItem:(id)sender {
	MusicLibraryItem* item = [sender representedObject];
	
	unsigned modifierFlags = self.window.currentEvent.modifierFlags;
	
	if([item isKindOfClass:[MusicLibraryTrack class]] && modifierFlags & NSCommandKeyMask) {
		[self.window.windowController performSelector:@selector(showInFinder:)
			withObject:item];
		return;
	}

	if(modifierFlags & NSControlKeyMask) {
		NSEvent* currentEvent = self.window.currentEvent;
		NSMenu* menu = [sender menuForEvent:currentEvent];
		
		NSRect bounds = [self convertRect:[(NSView*)sender frame] toView:nil];
		NSPoint newLocation = NSMakePoint(
			NSMinX(bounds) + 2.0,
			NSMinY(bounds) - 2.0);
	
		NSEvent* newEvent = [NSEvent keyEventWithType:currentEvent.type
			location:newLocation
			modifierFlags:currentEvent.modifierFlags
			timestamp:currentEvent.timestamp
			windowNumber:currentEvent.windowNumber
			context:currentEvent.context
			characters:currentEvent.characters
			charactersIgnoringModifiers:currentEvent.charactersIgnoringModifiers
			isARepeat:currentEvent.isARepeat
			keyCode:currentEvent.keyCode];
		
		[NSMenu popUpContextMenu:menu
			withEvent:newEvent
			forView:sender];
	} else if(modifierFlags & NSAlternateKeyMask) {
		[self.window.windowController performSelector:@selector(show:)
			withObject:item];
	} else {
		[self.window.windowController performSelector:@selector(play:)
			withObject:item];
		[[[self window] windowController] orderOut:sender];
	}
}

- (void)viewDidMoveToWindow {
	_coverCache.userSpaceScaleFactor = [[self window] userSpaceScaleFactor];
}

- (void)_updateSelectionForItem:(MusicLibraryItem*)item parentItem:(MusicLibraryItem*)parentItem makeVisible:(BOOL)makeVisible selectedPrevious:(BOOL)selectedPrevious {
	MusicSearchMenuItemView* menuItemView = [self menuItemViewForItem:item];
	
	if(menuItemView) {
		BOOL selected = self.selection == item;
		
		[[menuItemView cell] setHighlighted:selected];
		
		if(makeVisible) {
			NSRect menuItemFrame = menuItemView.frame;
			
			if(item == parentItem.items.firstObject) {
				CGFloat separatorHeight = [self _separatorHeight];

				menuItemFrame = NSOffsetRect(menuItemFrame, 0.0, -separatorHeight);
				menuItemFrame.size.height += separatorHeight;
			}
			
			if(parentItem == [self.content lastObject] && item == parentItem.items.lastObject) {
				NSRect bounds = self.bounds;
				menuItemFrame.origin.y = NSMaxY(bounds) - NSHeight(menuItemFrame);
			}
			
			menuItemFrame = NSIntersectionRect(menuItemFrame, self.bounds);
			
			[self scrollRectToVisible:menuItemFrame];		

/*
			CGFloat separatorHeight = [self _separatorHeight];
			
			NSRect menuItemFrame = menuItemView.frame;
			NSRect visibleFrame = self.visibleRect;
			
			menuItemFrame.size.width = 1.0; // We don't care about the width
			
			if(!selectedPrevious && NSContainsRect(visibleFrame, menuItemFrame)) {
				return;
			}
			
			NSRect newVisibleFrame = NSZeroRect;
			
			if(selectedPrevious) {
				if(item == parentItem.items.firstObject) {
					newVisibleFrame = NSMakeRect(
						NSMinX(visibleFrame), NSMinY(menuItemFrame) - separatorHeight,
						NSWidth(visibleFrame), NSHeight(menuItemFrame));
				} else {
					NSRect firstMenuItemFrame = [self menuItemViewForItem:parentItem.items.firstObject].frame;
	
					newVisibleFrame = NSMakeRect(
						NSMinX(visibleFrame), NSMinY(firstMenuItemFrame) - separatorHeight,
						NSWidth(visibleFrame), NSMinY(menuItemFrame) - NSMinY(firstMenuItemFrame));
				}
			} else {
				newVisibleFrame = NSMakeRect(
					NSMinX(visibleFrame), NSMinY(menuItemFrame) - separatorHeight,
					NSWidth(visibleFrame), NSHeight(visibleFrame));
			}

			newVisibleFrame = NSIntersectionRect(newVisibleFrame, self.bounds);
			
			[self scrollRectToVisible:newVisibleFrame];
*/
		}
	}
}

- (BOOL)_isSelection:(id)selection validForContent:(id)content {
	for(id item in content) {
		if([[item items] containsObject:selection]) {
			return YES;
		}
	}
	
	return NO;
}

- (void)_controlTintDidChange:(NSNotification*)notification {
	[self setNeedsDisplay:YES];
}

- (void)albumCoverCache:(AlbumCoverCache*)cache foundCoverForAlbum:(MusicLibraryAlbum*)album {
	[[self subviewForRepresentedObject:album] setNeedsDisplay:YES];
}

@end
