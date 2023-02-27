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

#import "SCSoundVolumeBezelViewController.h"

#import "PlaybackController.h"
#import "CoverSutra.h"

#import "SCBezelImageView.h"
#import "SCBezelTextField.h"
#import "SCBezelLevelIndicator.h"

#import "NSImage+Additions.h"

@implementation SCSoundVolumeBezelViewController

+ (SCSoundVolumeBezelViewController*)viewController {
	return [[self alloc] initWithNibName:@"SCSoundVolumeBezelView" bundle:nil];
}

- (void)loadView {
	[super loadView];
	
	textLabel.stringValue = @"iTunes"; // TODO
	
	// Sound Volume Observer
	id soundVolumeBlock = ^(NSNotification* notification) {
		[self updateSoundVolume];
	};
	
	_soundVolumeObserver = [[NSNotificationCenter defaultCenter]
		addObserverForName:CSPlayerDidChangeSoundVolumeNotification
		object:nil
		queue:[NSOperationQueue mainQueue]
		usingBlock:soundVolumeBlock];
	
	[self updateSoundVolume];
}

- (void)viewDidUnload {
	[super viewDidUnload];

	[[NSNotificationCenter defaultCenter] removeObserver:_soundVolumeObserver];
}

- (void)updateSoundVolume {
	NSInteger soundVolume = [[[CoverSutra self] playbackController] soundVolume];
	BOOL mute = [[[CoverSutra self] playbackController] isMuted];
	
	if(mute) {
		soundVolume = 0;
		
	}
	
	volumeIndicator.value = soundVolume / 100.0;
	
	imageView.image = mute || soundVolume <= 0 ?
		[NSImage templateImageNamed:@"soundVolumeOffTemplate"] :
		[NSImage templateImageNamed:@"soundVolumeFullTemplate"];
}

@end
