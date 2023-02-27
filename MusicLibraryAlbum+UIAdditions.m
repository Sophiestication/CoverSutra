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

#import "MusicLibraryAlbum+UIAdditions.h"

#import "MusicLibraryTrack.h"

#import "NowPlayingController.h"
#import "CoverSutra.h"

#import "Utilities.h"

#import "NSArray+Additions.h"

@implementation MusicLibraryAlbum(UIAdditions)

- (NSString*)tooltipString {
	return [NSString stringWithFormat:NSLocalizedString(@"MEDIALIBRARY_TITLEANDARTIST_TOOLTIP", @"Album tooltip in the search menu with title and artist"),
		self.displayName,
		self.displayArtist];
}

- (NSArray*)menuItemsForTracks:(BOOL)includeInfo {
	includeInfo = NO; // TODO
	
	NSString* currentTrackID = [[[[CoverSutra self] nowPlayingController] track] persistentID];
	NSMutableArray* menuItems = [NSMutableArray arrayWithCapacity:self.tracks.count * 3];
	
	// ...
	NSDictionary* menuItemStyle = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSFont menuFontOfSize:14.0 /*[NSFont systemFontSizeForControlSize:NSRegularControlSize]*/ ], NSFontAttributeName,
		nil];
		
	NSDictionary* timeStyle = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSColor disabledControlTextColor], NSForegroundColorAttributeName,
		[NSFont menuFontOfSize:11.0], NSFontAttributeName,
		nil];
	
	// ..
	NSInteger previousDisc = 1;
	
	for(MusicLibraryTrack* track in self.tracks) {
		BOOL nowPlaying = EqualStrings(currentTrackID, track.persistentID);
		
		// Check if we need to add the disc number item
		NSInteger currentDiscNumber = track.discNumber;
		
		if(currentDiscNumber > 1 && currentDiscNumber != previousDisc) {
			if(track != self.tracks.firstObject) {
				[menuItems addObject:[NSMenuItem separatorItem]];
			}

			NSString* discNumber = [NSString stringWithFormat:
				NSLocalizedString(@"DISC_MENUITEM_TEMPLATE", @"Disc number menu item title"), (long)currentDiscNumber];
			NSMenuItem* discNumberMenuItem = [[NSMenuItem alloc]
				initWithTitle:discNumber
				action:nil
				keyEquivalent:@""];
			
			[menuItems addObject:discNumberMenuItem];
		}
		
		previousDisc = currentDiscNumber;
		
		// Make the standard menu item for this track
		NSString* menuItemTitle = track.displayName;
		NSMenuItem* menuItem = [[NSMenuItem alloc]
			initWithTitle:menuItemTitle
			action:@selector(play:)
			keyEquivalent:@""];
		
		NSMutableAttributedString* attributedTitle = [[NSMutableAttributedString alloc] initWithString:menuItemTitle attributes:menuItemStyle];
		
		if(includeInfo) {
			NSString* timeString = track.time;
			
			if(!IsEmpty(timeString)) {
				timeString = [NSString stringWithFormat:@" (%@)", timeString];
				NSMutableAttributedString* attributedTimeString = [[NSMutableAttributedString alloc] initWithString:timeString attributes:timeStyle];
				[attributedTitle appendAttributedString:attributedTimeString];
			}
		}
		
		[menuItem setAttributedTitle:attributedTitle];

		[menuItem setRepresentedObject:track];
		[menuItem setState:nowPlaying ? NSOnState : NSOffState];
		
		[menuItems addObject:menuItem];
		
		// Make a show track menu item
		NSString* showMenuItemTitle = [NSString stringWithFormat:
			NSLocalizedString(@"SHOW_TRACK_MENUITEM_TEMPLATE", @"Show track menu item title"), track.displayName];
		NSMenuItem* showMenuItem = [[NSMenuItem alloc]
			initWithTitle:showMenuItemTitle
			action:@selector(show:)
			keyEquivalent:@""];
			
		[showMenuItem setAttributedTitle:
			[[NSAttributedString alloc] initWithString:showMenuItemTitle attributes:menuItemStyle]];
			
		[showMenuItem setRepresentedObject:track];
		[showMenuItem setState:nowPlaying ? NSOnState : NSOffState];
		[showMenuItem setKeyEquivalentModifierMask:NSAlternateKeyMask];
		[showMenuItem setAlternate:YES];
		
		[menuItems addObject:showMenuItem];
		
		// Make a show track in Finder menu item
		NSString* showInFinderMenuItemTitle = [NSString stringWithFormat:
			NSLocalizedString(@"SHOW_TRACK_INFINDER_MENUITEM_TEMPLATE", @"Show track in Finder menu item title"), track.displayName];
		NSMenuItem* showInFinderMenuItem = [[NSMenuItem alloc]
			initWithTitle:showInFinderMenuItemTitle
			action:@selector(showInFinder:)
			keyEquivalent:@""];
			
		[showInFinderMenuItem setAttributedTitle:
			[[NSAttributedString alloc] initWithString:showInFinderMenuItemTitle attributes:menuItemStyle]];
			
		[showInFinderMenuItem setRepresentedObject:track];
		[showInFinderMenuItem setState:nowPlaying ? NSOnState : NSOffState];
		[showInFinderMenuItem setKeyEquivalentModifierMask:NSShiftKeyMask];
		[showInFinderMenuItem setAlternate:YES];
		
		[menuItems addObject:showInFinderMenuItem];
	}
	
	return menuItems;
}

@end
