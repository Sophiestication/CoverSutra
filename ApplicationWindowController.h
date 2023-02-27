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

@class
	CoverView,
	PlayerPositionSlider,
	SegmentedControl,
	Slider,
	StarRatingControl;

/*!
    @class		 ApplicationWindowController
    @abstract    (brief description)
    @discussion  (comprehensive description)
*/
@interface ApplicationWindowController : WindowController<NSTextFieldDelegate> {
	IBOutlet CoverView* coverView;
	
	IBOutlet NSButton* notRunning;
	
	IBOutlet NSTextField* title;
	IBOutlet NSTextField* album;
	IBOutlet NSTextField* artist;
	IBOutlet NSTextField* trackNumber;
	
	IBOutlet StarRatingControl* userRatingControl;
	
	IBOutlet PlayerPositionSlider* playerPositionSlider;
	
	IBOutlet SegmentedControl* playerControls;
	IBOutlet SegmentedControl* playlistControls;
	
	IBOutlet NSButton* minSoundVolume;
	IBOutlet NSButton* maxSoundVolume;
	IBOutlet Slider* soundVolumeSlider;
	
	IBOutlet SegmentedControl* actionButton;
	
@private
	BOOL _condensedLayout;
}

+ (ApplicationWindowController*)applicationWindowController;

- (IBAction)maximizeSoundVolume:(id)sender;
- (IBAction)minimizeSoundVolume:(id)sender;

- (IBAction)changeSoundVolume:(id)sender;

- (BOOL)condensedLayout;
- (void)setCondensedLayout:(BOOL)condensedLayout;

- (IBAction)orderFront:(id)sender;
- (IBAction)orderOut:(id)sender;

- (IBAction)orderFrontiTunes:(id)sender;

- (void)playlistControlsButtonPressed:(id)sender;

@end
