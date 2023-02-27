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
#import "WindowController.h"

@class CoverView,
	MusicLibraryTrack;

@interface obsolete__SCLyricsWindowController : WindowController <NSWindowDelegate> {
	IBOutlet NSTextView* _textView;
	IBOutlet NSTextField* _label;
	IBOutlet NSProgressIndicator* _spinner;
	
	IBOutlet CoverView* _coverView;
	IBOutlet NSTextField* _artistLabel;
	IBOutlet NSTextField* _trackLabel;
}

+ (obsolete__SCLyricsWindowController*)lyricsWindowController;

- (IBAction)orderFront:(id)sender;
- (IBAction)orderOut:(id)sender;

+ (BOOL)lyricsWindowShown;

- (void)setTrack:(MusicLibraryTrack *)track;

- (void)setLyrics:(NSString*)lyrics;
- (void)setInfoText:(NSString*)infoText;
- (void)startSpinner;
	
@end
