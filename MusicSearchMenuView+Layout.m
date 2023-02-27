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

#import "MusicSearchMenuView+Layout.h"
#import "MusicSearchMenuView+Private.h"

#import "MusicSearchGroupView.h"
#import "MusicSearchMenuItemView.h"

#import "MusicLibraryItem.h"
#import "MusicLibraryPlaylist.h"
#import "MusicLibraryArtist.h"

#import "MusicLibraryAlbum.h"
#import "MusicLibraryAlbum+UIAdditions.h"

#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+UIAdditions.h"

#import "NSArray+Additions.h"

#import "Utilities.h"

#import <QuartzCore/CoreAnimation.h>

@implementation MusicSearchMenuView(Layout)

- (void)tile {
	CGFloat leftSideWidth = [self _leftSideWidth];
	CGFloat rightSideWidth = [self _rightSideWidth];
	
	CGFloat seperatorHeight = [self _separatorHeight];
	
	NSRect frame = self.bounds;
	NSPoint origin = frame.origin;
	NSPoint previousOrigin = origin;
	
	NSArray* content = self.content;
	BOOL hasSearchResults = !IsEmpty(content);
	BOOL hasSearchTerm = !IsEmpty([self valueForKeyPath:@"window.windowController.searchField.stringValue"]); // TODO
	
	if(!hasSearchTerm) {
		[[self coverCache] purgeIfNeeded];
	}
	
	NSMutableArray* newSubviews = [NSMutableArray arrayWithCapacity:[content count]];
	
	// Create a new animation context for tiling
//	[NSAnimationContext beginGrouping];
//	
//	[[NSAnimationContext currentContext] setDuration:0.5];

	// Show or hide no search results menu item
	if(!hasSearchResults && hasSearchTerm) {
		NSSize noResultsSize = [_noResultsMenuItem frame].size;
		
		[_noResultsMenuItem setFrame:NSMakeRect(
			previousOrigin.x, previousOrigin.y + seperatorHeight,
			NSWidth(frame), noResultsSize.height)];
		
		previousOrigin.y += noResultsSize.height + seperatorHeight;
	}
	
	[_noResultsMenuItem setHidden:hasSearchResults || !hasSearchTerm];
	
	// Tile all group/album views
	for(MusicLibraryItem* item in content) {
//		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init]; {
			if(item != [content firstObject]) {
				previousOrigin.y += seperatorHeight;
			}
			
			// We have an album
//			if([item isKindOfClass:[MusicLibraryAlbum class]] || [item isKindOfClass:[MusicLibraryArtist class]]) {
				// Display the album on the left side
				NSControl* groupView = [self viewForItem:item origin:previousOrigin];
				
				// Set the track views new frame
				NSSize groupCellSize = [[groupView cell] cellSize];
				NSRect newGroupViewFrame = NSMakeRect(
					previousOrigin.x, previousOrigin.y,
					leftSideWidth - 1.0, groupCellSize.height);
				[groupView setFrame:newGroupViewFrame];
				
				// Add the group view to our subviews array
				[newSubviews addObject:groupView];
				
				NSPoint trackOrigin = NSMakePoint(previousOrigin.x + leftSideWidth, previousOrigin.y);
				
				// Display all tracks for this album
				for(MusicLibraryItem* subitem in [(id)item items]) {
					NSControl* menuItemView = [self viewForSubitem:subitem origin:trackOrigin];
					
					if(self.selection == subitem) {
						[[menuItemView cell] setHighlighted:YES];
					}
					
					// Set the track views new frame
					NSSize cellSize = [[menuItemView cell] cellSize];
					NSRect newTrackViewFrame = NSMakeRect(
						trackOrigin.x, trackOrigin.y,
						rightSideWidth, cellSize.height);
					[menuItemView setFrame:newTrackViewFrame];
					
					// Set the origin of the next item
					trackOrigin.y += NSHeight(newTrackViewFrame);
					
					// Add the view to our subviews array
					[newSubviews addObject:menuItemView];
				}
				
				// Advance our origin for the next item
				previousOrigin.y += MAX(groupCellSize.height, trackOrigin.y - previousOrigin.y);
//			}
//		} [pool drain];
	}
	
	// Add some seperator space
	if(!hasSearchResults && hasSearchTerm) {
		previousOrigin.y += seperatorHeight;
	}
	
	if(content.count == 1 && [[[content firstObject] items] count] == 1) {
		previousOrigin.y += seperatorHeight * 2.0;
	}
	
	// Update our menu view's frame
//	NSRect screenFrame = self.window.screen.visibleFrame;
	NSSize frameSize = NSMakeSize(NSWidth(frame), previousOrigin.y);
	
//	frameSize.height = MIN(NSHeight(screenFrame), frameSize.height);

	NSMutableSet* newSubviewsSet = [NSMutableSet setWithArray:newSubviews];
	[newSubviewsSet addObjectsFromArray:self.defaultSubviews];
	[self setSubviews:[newSubviewsSet allObjects]];
	
//	[self setSubviews:
//		[self.defaultSubviews arrayByAddingObjectsFromArray:newSubviews]];
	
	[self setFrameSize:frameSize];
	
	// End our tiling animation context
//	[NSAnimationContext endGrouping];
	
//	NSRect visibleRect = NSIntersectionRect(self.visibleRect, self.bounds);
//	[self scrollRectToVisible:visibleRect];
}

- (CGFloat)_leftSideWidth {
	return 167.0;
}

- (CGFloat)_rightSideWidth {
//	NSRect documentVisibleRect = [[self enclosingScrollView] documentVisibleRect];
	return NSWidth(self.bounds) - [self _leftSideWidth];
}

- (CGFloat)_separatorHeight {
	return 8.0;
}

/*
- (NSRect)adjustScroll:(NSRect)proposedVisibleRect {
	NSRect bounds = self.bounds;
	
	if(NSMaxY(proposedVisibleRect) > NSMaxY(bounds)) {
		proposedVisibleRect.origin.y = NSMaxY(bounds) - NSHeight(proposedVisibleRect);
	}

	return proposedVisibleRect;
}
*/

- (void)updateTrackingAreas {
	[super updateTrackingAreas];
	
	// Remove all old tracking areas
	for(NSTrackingArea* trackingArea in self.trackingAreas) {
		[self removeTrackingArea:trackingArea];
	}
	
	// Add tracking rect for content area
	NSRect contentRect = self.bounds;
	
	contentRect = NSOffsetRect(contentRect, [self _leftSideWidth], 0.0);
	contentRect.size.width -= [self _leftSideWidth];
	
	NSTrackingArea* contentTrackingArea = [[NSTrackingArea alloc]
		initWithRect:contentRect
		options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways|NSTrackingAssumeInside|NSTrackingInVisibleRect
		owner:self
		userInfo:nil];
	[self addTrackingArea:contentTrackingArea];
}

- (MusicLibraryItem*)parentForItem:(MusicLibraryItem*)item {
	for(MusicLibraryItem* result in self.content) {
		for(MusicLibraryItem* subitem in result.items) {
			if([subitem isEqual:item]) {
				return result;
			}
		}
	}
	
	return nil;
}

- (id)viewForSubitem:(MusicLibraryItem*)subitem origin:(NSPoint)origin {
	MusicSearchMenuItemView* view = [self menuItemViewForItem:subitem];

	if(!view) {
		NSRect menuItemFrame = NSMakeRect(
			origin.x, origin.y,
			[self _rightSideWidth], 0.0);
		view = [[MusicSearchMenuItemView alloc] initWithFrame:menuItemFrame];
		
		if([subitem isKindOfClass:[MusicLibraryTrack class]]) {
			[view setTag:((MusicLibraryTrack*)subitem).trackID];
			
			[view setMenu:[[[self window] windowController] valueForKey:@"trackActions"]];
		}
		
		if([subitem isKindOfClass:[MusicLibraryPlaylist class]]) {
			[view setTag:((MusicLibraryPlaylist*)subitem).playlistID];
			
			[view setMenu:[[[self window] windowController] valueForKey:@"playlistActions"]];
		}
		
		[view setAction:@selector(_performClickOnItem:)];
		[view setTarget:self];
		
		[view setControlSize:NSSmallControlSize];
	}
	
	[view setRepresentedObject:subitem];
	
	if([subitem respondsToSelector:@selector(image)]) {
		[view setImage:[subitem performSelector:@selector(image)]];
		[view setAlternateImage:[subitem performSelector:@selector(image)]];
	}

	// TODO
	if([subitem respondsToSelector:@selector(custom1)]) {
		NSString* optionalAlbumTitle = [(id)subitem custom1];
	
		if(!IsEmpty(optionalAlbumTitle)) {
			[view setTitle:[NSString stringWithFormat:@"%@ —­ ­%@", subitem.displayName, optionalAlbumTitle]];
		} else {
			[view setTitle:subitem.displayName];
		}
	} else {
		[view setTitle:subitem.displayName];
	}
	
	if([subitem respondsToSelector:@selector(tooltipString)]) {
		[view setToolTip:[(id)subitem tooltipString]];
	}

	return view;
}

- (id)viewForItem:(MusicLibraryItem*)item origin:(NSPoint)origin {
	MusicSearchGroupView* groupView = [self subviewForRepresentedObject:item];
	
	if(!groupView) {
		NSRect groupFrame = NSMakeRect(
			origin.x, origin.y,
			[self _leftSideWidth], 0.0);
		groupView = [[MusicSearchGroupView alloc] initWithFrame:groupFrame];

		if([item isKindOfClass:[MusicLibraryAlbum class]]) {
			[groupView setShowsBorderOnlyWhileMouseInside:YES];
			[groupView setMenu:[[[self window] windowController] valueForKey:@"albumActions"]];
		}
		
		if([item respondsToSelector:@selector(tooltipString)]) {
			[groupView setToolTip:[(id)item tooltipString]];
		}

//		[groupView setTag:-2];
//		[groupView setWantsLayer:YES];
	}
	
	[groupView setRepresentedObject:item];
	
	return groupView;
}

- (id)subviewForRepresentedObject:(id)representedObject {
	for(id view in self.subviews) {
		if([view respondsToSelector:@selector(representedObject)]) {
			if([representedObject isEqual:[view representedObject]]) {
				return view;
			}
		}
	}
	
	return nil;
}

- (MusicSearchMenuItemView*)menuItemViewForItem:(MusicLibraryItem*)item {
	if([item isKindOfClass:[MusicLibraryTrack class]]) {
		return (MusicSearchMenuItemView*)[self viewWithTag:((MusicLibraryTrack*)item).trackID];
	}
	
	if([item isKindOfClass:[MusicLibraryPlaylist class]]) {
		return (MusicSearchMenuItemView*)[self viewWithTag:((MusicLibraryPlaylist*)item).playlistID];
	}
	
	return nil;
}

@end
