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

#import "SCLyricsWindowController.h"
#import "SCLyricsWindowController+Private.h"

#import "PlayerController.h"

#import "CoverSutra.h"

#import "NSArray+Additions.h"
#import "NSImage+Additions.h"
#import "NSShadow+Additions.h"
#import "NSString+Additions.h"

@implementation SCLyricsWindowController

@synthesize lyrics = _lyrics;
@dynamic styledLyrics;

#pragma mark -
#pragma mark Construction & Destruction

+ (NSSet*)keyPathsForValuesAffectingStyledLyrics { return [NSSet setWithObject:@"lyrics"]; }

+ (SCLyricsWindowController*)lyricsWindowController {
	return [[[self alloc] initWithWindowNibName:@"SCLyricsWindow"] autorelease];
}

- (void)dealloc {
	[_lyrics release];
	[_lyricsStyle release];

	[super dealloc];
}

#pragma mark -
#pragma mark SCLyricsWindowController

+ (BOOL)lyricsWindowShown {
	BOOL showLyricsWindow = [[[NSUserDefaultsController sharedUserDefaultsController]
							    valueForKeyPath:@"values.lyricsWindowShown"] boolValue];
	return showLyricsWindow;
}

#pragma mark -
#pragma mark NSWindowController

- (void)windowWillLoad {
	[super windowWillLoad];
}

- (void)windowDidLoad {
	[super windowDidLoad];
	
	// Prepare the lyrics test style
	NSMutableParagraphStyle* paragraph = [[[NSMutableParagraphStyle alloc] init] autorelease];
	
	[paragraph setLineBreakMode:NSLineBreakByWordWrapping];
	[paragraph setAlignment:NSCenterTextAlignment];
	
	NSDictionary* lyricsStyle = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSColor whiteColor], NSForegroundColorAttributeName,
		[NSFont boldSystemFontOfSize:10.0], NSFontAttributeName, 
		[NSShadow HUDImageShadow], NSShadowAttributeName,
		paragraph, NSParagraphStyleAttributeName,
		nil];
	_lyricsStyle = [lyricsStyle retain];
	
	// Prepare our window
	NSWindow* window = [self window];
	
	// Setup bezel window
	[window setAlphaValue:0.0];
	[window setLevel:NSStatusWindowLevel];
	[window setOneShot:YES];
	[window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	
	// Setup the custom close button
	NSButton* closeButton = [window standardWindowButton:NSWindowCloseButton];
	
	[closeButton setTarget:self];
	[closeButton setAction:@selector(orderOut:)];
	
	// Set the frames of our subviews
	NSRect subviewFrame = content.frame;
	
	notRunning.frame = subviewFrame;
	[[window contentView] addSubview:notRunning];
	
	inProgress.frame = subviewFrame;
	[[window contentView] addSubview:inProgress];
	
	// Bind to our lyrics
	[self bind:@"lyrics"
		toObject:[CoverSutra self]
		withKeyPath:@"nowPlayingController.track.lyrics"
		options:nil];
}

#pragma mark -
#pragma mark WindowController

- (float)animationOrderInTime {
	return 0.125;
}

- (float)animationOrderOutTime {
	return 0.25;
}

#pragma mark -
#pragma mark Private

- (NSAttributedString*)styledLyrics {
	NSString* lyrics = self.lyrics;
	
	if([lyrics length] > 0) {
		lyrics = [lyrics stringByReplacingOccurrencesOfString:@"\r" withString:@"<br/>"];
		lyrics = [lyrics stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
		
		NSData* data = [lyrics dataUsingEncoding:NSUnicodeStringEncoding];
		NSMutableAttributedString* styledLyrics = [[[NSMutableAttributedString alloc] initWithHTML:data documentAttributes:nil] autorelease];
		
		NSRange range = NSMakeRange(0, [styledLyrics length]);
		[styledLyrics addAttributes:_lyricsStyle range:range];

		return styledLyrics;
	}
	
	return nil;
}

- (IBAction)orderFront:(id)sender {
	[self orderFront:sender animate:YES];
}

- (IBAction)orderOut:(id)sender {
	[self orderOut:sender animate:YES];
}

- (void)orderFrontNotRunning {
	NSRect frame = content.frame;
	notRunning.frame = frame;
	[[[content superview] animator] replaceSubview:content with:notRunning];
}

- (void)orderFrontInProgress {
	NSRect frame = content.frame;
	inProgress.frame = frame;
	[[[content superview] animator] replaceSubview:content with:inProgress];

	NSProgressIndicator* indicator = [[inProgress subviews] firstObject];
	[indicator startAnimation:nil];
}

- (void)orderFrontContent {
}

@end
