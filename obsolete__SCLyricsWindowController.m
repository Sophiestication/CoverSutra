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

#import "obsolete__SCLyricsWindowController.h"

#import "CoverSutra.h"
#import "NowPlayingController.h"

#import "MusicLibraryTrack.h"
#import "CoverView.h"

@implementation obsolete__SCLyricsWindowController

#pragma mark -
#pragma mark SCLyricsWindowController construction & destruction

+ (obsolete__SCLyricsWindowController*)lyricsWindowController {
	return [[[self alloc] initWithWindowNibName:@"SCLyricsWindow"] autorelease];
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

#pragma mark -
#pragma mark NSNibAwaking methods

- (void)awakeFromNib {
	[super awakeFromNib];

	[self startSpinner];
	
	NowPlayingController* nowPlayingController = [[CoverSutra self] nowPlayingController];
	[self setTrack:nowPlayingController.track];
	
	[_textView setTextContainerInset:NSMakeSize(8.0, 8.0)];
	
	NSFont* labelFont = [NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]];
	[_label setFont:labelFont];
	
	NSFont* artistAndTitleFont = [NSFont boldSystemFontOfSize:[NSFont systemFontSize]];
	[_artistLabel setFont:artistAndTitleFont];
	[_trackLabel setFont:artistAndTitleFont];

	[[NSNotificationCenter defaultCenter]
	 addObserver:self
	 selector:@selector(playerDidChangeTrack:)
	 name:PlayerDidChangeTrackNotification
	 object:nil];
	
	[self setWindowFrameAutosaveName:@"lyricsWindow"];
}

#pragma mark -
#pragma mark SCLyricsWindowController order handling

- (IBAction)orderFront:(id)sender {
	[self orderFront:sender animate:YES];
	
	[[NSUserDefaultsController sharedUserDefaultsController]
	 setValue:[NSNumber numberWithBool:YES]
	 forKeyPath:@"values.lyricsWindowShown"];
}

- (IBAction)orderOut:(id)sender {
	[self orderOut:sender animate:YES];
	
	[[NSUserDefaultsController sharedUserDefaultsController]
	 setValue:[NSNumber numberWithBool:NO]
	 forKeyPath:@"values.lyricsWindowShown"];
	
	[_coverView unbind:@"image"];
}

- (float)animationOrderInTime {
	return 0.125;
}

- (float)animationOrderOutTime {
	return 0.25;
}

#pragma mark -
#pragma mark SCLyricsWindowController methods

- (void)setTrack:(MusicLibraryTrack *)track {
	NSRange zeroRange = { 0, 0 };
	[_textView scrollRangeToVisible: zeroRange];
	
	if (nil == track) {
		// TODO: show info
		[_artistLabel setStringValue:@""];
		[_trackLabel setStringValue:@""];
		[self setLyrics:@""];
		[self setInfoText:@""];
		[_spinner stopAnimation:self];
		[_coverView unbind:@"image"];
		[_coverView setImage:nil];
		return;
	}
	
	[_artistLabel setStringValue:track.artist];
	[_trackLabel setStringValue:track.name];
	if (![track.lyrics isEqualToString:@""]) {
		[self setLyrics:track.lyrics];
	}

	NSString *albumCasePath = @"nowPlayingController.extraSmallAlbumCaseImage";
	[_coverView bind:@"image"
		   toObject:[CoverSutra self]
		withKeyPath:albumCasePath
			options:nil];
}

+ (BOOL)lyricsWindowShown {
	BOOL showLyricsWindow = [[[NSUserDefaultsController sharedUserDefaultsController]
							    valueForKeyPath:@"values.lyricsWindowShown"] boolValue];
	return showLyricsWindow;
}

- (void)setLyrics:(NSString*)lyrics {
	[_spinner stopAnimation:self];
	if (nil == lyrics) {
		[_textView setString:@""];
		return;
	}
	
	NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
								[NSColor whiteColor], NSForegroundColorAttributeName,
								[NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]], NSFontAttributeName,
								nil];
	NSAttributedString* attributedLyrics = [[NSAttributedString alloc] initWithString:lyrics attributes:attributes];
	
	[[_textView textStorage] setAttributedString:attributedLyrics];
	[attributedLyrics release], attributedLyrics = nil;
}

- (void)setInfoText:(NSString*)infoText {
	[_label setStringValue:infoText];
}

- (void)startSpinner {
	[self setLyrics:@""];
	[self setInfoText:@""];
	[_spinner startAnimation:self];
}

#pragma mark -
#pragma mark NSWindowDelegate methods

- (NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize {
	NSSize finalSize = frameSize;
	CGFloat minHeight = 256.0;
	CGFloat minWidth = 256.0;
	if (finalSize.width < minWidth) {
		finalSize.width = minWidth;
	}
	if (finalSize.height < minHeight) {
		finalSize.height = minHeight;
	}
	
	return finalSize;
}

- (BOOL)windowShouldClose:(id)sender {
	[self orderOut:sender];
	return NO;
}

#pragma mark -
#pragma mark NowPlayingController notification methods

- (void)playerDidChangeTrack:(NSNotification*)notification {
	MusicLibraryTrack* track = [[notification userInfo] objectForKey:@"track"];
	
	[self startSpinner];
	[self setTrack:track];
}

@end
