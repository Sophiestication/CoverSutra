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

#import "DesktopWindowController.h"

#import "CoverSutra.h"
#import "CoverSutra+Menu.h"
#import "CoverSutra+Shortcuts.h"

#import "ApplicationWindowController.h"

#import "PlayerController.h"
#import "PlaybackController.h"

#import "CoverView.h"

#import "SkinController.h"
#import "Skin.h"

#import "NSArray+Additions.h"
#import "NSString+Additions.h"
#import "NSShadow+Additions.h"

#import "TextField.h"

#import "Utilities.h"

@implementation DesktopWindowController

+ (DesktopWindowController*)desktopWindowController {
	return [[self alloc] initWithWindowNibName:@"DesktopWindow"];
}

+ (BOOL)desktopWindowShown {
	BOOL showDesktopWindow = [[[NSUserDefaultsController sharedUserDefaultsController]
		valueForKeyPath:@"values.desktopWindowShown"] boolValue];
	return showDesktopWindow;
}

+ (NSInteger)desktopWindowSize {
	NSInteger size = [[[NSUserDefaultsController sharedUserDefaultsController]
	    valueForKeyPath:@"values.desktopWindowSize"] integerValue];
	return size;
}

+ (NSInteger)desktopWindowLevel {
	NSString* desktopWindowLevel = [[NSUserDefaultsController sharedUserDefaultsController]
		valueForKeyPath:@"values.desktopWindowLevel"];
	
	CGWindowLevelKey windowLevelKey = kCGDesktopIconWindowLevelKey;
	
	if(desktopWindowLevel != nil) {
		if(EqualStrings(desktopWindowLevel, @"kCGDesktopWindowLevelKey")) {
//			windowLevelKey = kCGDesktopWindowLevelKey;
		} else if(EqualStrings(desktopWindowLevel, @"kCGDesktopIconWindowLevelKey")) {
			windowLevelKey = kCGDesktopIconWindowLevelKey;
		} else if(EqualStrings(desktopWindowLevel, @"kCGNormalWindowLevelKey")) {
			windowLevelKey = kCGNormalWindowLevelKey;
		} else if(EqualStrings(desktopWindowLevel, @"kCGStatusWindowLevelKey")) {
			windowLevelKey = kCGStatusWindowLevelKey;
		}
	}
	
	return CGWindowLevelForKey(windowLevelKey);
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	NSWindow* window = [self window];
	
	[window setOpaque:NO];
	[window setAlphaValue:0.0];
//	[window setHasShadow:NO];
	[window setBackgroundColor:[NSColor clearColor]];
	[window setMovableByWindowBackground:YES];
	[window setAllowsConcurrentViewDrawing:YES];
	
	[window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	// [window setCollectionBehavior:NSWindowCollectionBehaviorStationary];

//	[window setLevel:
//		[[self class] desktopWindowLevel]];
	
	if([NSPopover class]) {
		[window setLevel:kCGDesktopIconWindowLevel + 1];
	} else {
		[window setLevel:kCGDesktopWindowLevel];
	}
	
	[self bind:@"songDetailsShown"
		toObject:[NSUserDefaultsController sharedUserDefaultsController]
		withKeyPath:@"values.songDetailsShown"
		options:nil];
		
//	[coverView setMenu:[[CoverSutra self] valueForKey:@"actionMenu"]];

	[self updateCaseSizeAnimated:NO];
	
	// Setup all textfields
	NSShadow* textShadow = [NSShadow desktopTextShadow];
	
	for(TextField* subview in [[window contentView] subviews]) {
		if([subview isKindOfClass:[TextField class]]) {
			[subview setAlignment:NSCenterTextAlignment];
			[subview setDrawsBackground:NO];
			[subview setBackgroundColor:[NSColor clearColor]];
			[subview setTextColor:[NSColor whiteColor]];
			[[subview cell] setTextShadow:textShadow];
			[subview setEditable:NO];
			[subview setSelectable:NO];
			[subview setBordered:NO];
			[[subview cell] setUsesSingleLineMode:YES];
			[[subview cell] setLineBreakMode:NSLineBreakByTruncatingTail];
		}
	}
	
	// ...
	[textLabel setFont:[NSFont boldSystemFontOfSize:12.0]];
	
	[textLabel bind:NSValueBinding
		toObject:[[CoverSutra self] nowPlayingController]
		withKeyPath:@"track.albumCoverTitle"
		options:0];
	[textLabel bind:NSToolTipBinding
		toObject:[[CoverSutra self] nowPlayingController]
		withKeyPath:@"track.albumCoverTitle"
		options:0];
	
	[detailTextLabel setFont:[NSFont boldSystemFontOfSize:11.0]];
	
	[detailTextLabel bind:NSValueBinding
		toObject:[[CoverSutra self] nowPlayingController]
		withKeyPath:@"track.albumCoverSecondaryTitle"
		options:0];
	[detailTextLabel bind:NSToolTipBinding
		toObject:[[CoverSutra self] nowPlayingController]
		withKeyPath:@"track.albumCoverSecondaryTitle"
		options:0];

	[[CoverSutra self] addObserver:self
		forKeyPath:@"skinController.selection.self"
		options:0
		context:NULL];
	[[NSUserDefaultsController sharedUserDefaultsController]
		addObserver:self
		forKeyPath:@"values.desktopWindowSize"
		options:0
		context:NULL];
		
	[self setWindowFrameAutosaveName:@"desktopWindow"];
	
	NSRect windowFrame = [window frame];
	windowFrame = [window constrainFrameRect:windowFrame toScreen:[window screen]];
	[window setFrame:windowFrame display:NO];
	
	[self updateFromUserDefaults];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
	if([keyPath isEqualToString:@"values.desktopWindowSize"]) {
		[self updateCaseSizeAnimated:YES];
	}
	
	[self tile];
}

- (void)windowDidMove:(NSNotification*)notification {
	[self tile];
}

- (void)windowDidChangeScreen:(NSNotification*)notification {
	[self tile];
}

- (IBAction)orderFront:(id)sender {
	[self orderFront:sender animate:YES];
	
	[[NSUserDefaultsController sharedUserDefaultsController]
		setValue:[NSNumber numberWithBool:YES]
		forKeyPath:@"values.desktopWindowShown"];
}

- (IBAction)orderFront:(id)sender animate:(BOOL)animate {
	[super orderFront:sender animate:animate];
	
	[self updateCaseSizeAnimated:NO];
	[self tile];
}

- (IBAction)orderOut:(id)sender {
	[self orderOut:sender animate:YES];
	
	[[NSUserDefaultsController sharedUserDefaultsController]
		setValue:[NSNumber numberWithBool:NO]
		forKeyPath:@"values.desktopWindowShown"];
		
	[coverView unbind:@"image"];
}

- (void)tile:(id)sender {
	[self tile];
}

- (void)tile {
	NSWindow* window = [self window];

//	[window setBackgroundColor:[NSColor orangeColor]];
	
	// Layout the window
	NSInteger desktopWindowSize = [[self class] desktopWindowSize];
	
	NSSize contentSize = desktopWindowSize == 0 ?
		NSMakeSize(320.0, 290.0) :
		NSMakeSize(300.0, 180.0);
	[window setContentSize:contentSize];

	// Layout the cover view
	Skin* skin = [[[[CoverSutra self] skinController] selectedObjects] firstObject];
	
	NSString* skinSize = desktopWindowSize == 0 ?
		LargeSkinSize :
		MediumSkinSize;
	
	NSSize caseSize = [[[skin caseDescriptionOfSkinSize:skinSize]
		objectForKey:SkinCaseSizeKey]
		sizeValue];
	NSRect alignmentRect = [[[skin caseDescriptionOfSkinSize:skinSize]
		objectForKey:SkinCaseAlignmentRectKey]
		rectValue];
	
	NSRect contentRect = [(NSView*)[[self window] contentView] bounds];
	NSRect coverViewRect = NSMakeRect(
		floorf(NSMidX(contentRect) - caseSize.width * 0.5),
		floorf(NSMaxY(contentRect) - caseSize.height),
		caseSize.width,
		caseSize.height);
	
	coverViewRect.origin.x += alignmentRect.origin.x;
	coverViewRect.origin.y += alignmentRect.origin.y;
	
	coverView.frame = coverViewRect;
	
	// Layout the text label
	NSSize textLabelSize = [[textLabel cell]
		cellSizeForBounds:contentRect];
	textLabelSize.height += 2.0; // To prevent text shadow clipping
		
	NSRect textLabelRect = NSMakeRect(
		NSMinX(contentRect),
		NSMinY(coverViewRect) - textLabelSize.height,
		NSWidth(contentRect),
		textLabelSize.height);
		
	// Tweak for the large skin
	if(desktopWindowSize == 0) {
		textLabelRect = NSOffsetRect(textLabelRect, 0.0, 5.0);
	}
		
	textLabel.frame = textLabelRect;
	
	// Layout the text label
	NSSize detailTextLabelSize = [[detailTextLabel cell]
		cellSizeForBounds:contentRect];
	detailTextLabelSize.height += 2.0; // To prevent text shadow clipping
		
	NSRect detailTextLabelRect = NSMakeRect(
		NSMinX(contentRect),
		NSMinY(textLabelRect) - detailTextLabelSize.height,
		NSWidth(contentRect),
		detailTextLabelSize.height);
	detailTextLabel.frame = detailTextLabelRect;
	
	// Show/Hide the text labels if needed
	NSRect visibleFrame = [[window screen] frame];
	
	for(id subview in [[window contentView] subviews]) {
		if([subview isKindOfClass:[TextField class]]) {
			NSRect frame = [(NSView*)subview frame];
			
			frame.origin = [window convertBaseToScreen:frame.origin];
			
			BOOL visible =
				(NSMinY(frame) > NSMinY(visibleFrame)) &&
				[self songDetailsShown];
			[subview setHidden:!visible];
		}
	}
}

- (BOOL)songDetailsShown {
	return _songDetailsShown;
}

- (void)setSongDetailsShown:(BOOL)songDetailsShown {
	if(songDetailsShown != _songDetailsShown) {
		_songDetailsShown = songDetailsShown;
		[self tile];
	}
}

- (void)updateFromUserDefaults {
	BOOL showDesktopWindow = [[self class] desktopWindowShown];
		
	if(showDesktopWindow) {
		[self orderFront:nil animate:YES];
	} else {
		[[self window] orderOut:nil];
	}
}

- (void)updateCaseSizeAnimated:(BOOL)animated {
	NSString* keyPath = [[self class] desktopWindowSize] == 0 ?
		@"nowPlayingController.largeAlbumCaseImage" :
		@"nowPlayingController.mediumAlbumCaseImage";
	
	[coverView
		bind:@"image"
		toObject:[CoverSutra self]
		withKeyPath:keyPath
		options:nil];
	
	if([[self class] desktopWindowSize] == 0) {
		[textLabel setFont:[NSFont boldSystemFontOfSize:12.0]];
		[detailTextLabel setFont:[NSFont boldSystemFontOfSize:11.0]];
	} else {
		[textLabel setFont:[NSFont boldSystemFontOfSize:11.0]];
		[detailTextLabel setFont:[NSFont boldSystemFontOfSize:10.0]];
	}
	
	NSWindow* window = [self window];
	NSRect windowFrame = [window
		constrainFrameRect:[window frame]
		toScreen:[window screen]];
	[window setFrame:windowFrame display:YES animate:animated];
}

- (void)mouseUp:(NSEvent*)theEvent {
	if([theEvent clickCount] == 2) {
		unsigned int modifiers = [theEvent modifierFlags];
		
		if(modifiers & NSAlternateKeyMask) {
			[[CoverSutra self] showCurrentSong:theEvent];
		} else {
			[[CoverSutra self] toggleApplicationWindowShown:theEvent];
		}
		
		return;
	}	
	
	[super mouseUp:theEvent];
}

@end
