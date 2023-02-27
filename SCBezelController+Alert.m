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

#import "SCBezelController+Alert.h"
#import "SCBezelController+Private.h"

#import "SCAlertBezelViewController.h"

#import "SCBezelTextField.h"

#import "PlayerController.h"
#import "NowPlayingController.h"
#import "PlaybackController.h"
#import "CoverSutra.h"

#import "NSImage+Additions.h"

@implementation SCBezelController(Alert)

- (BOOL)orderFrontAlertBezelIfNeeded:(id)sender {
	PlayerController* playerController = [[CoverSutra self] playerController];
	
	if(!playerController.iTunesIsRunning) {
		[self orderFrontPlayerIsNotRunningBezel:sender];
		return YES;
	}
	
	if(playerController.iTunesIsBusy) {
		[self orderFrontPlayerIsBusyBezel:sender];
		return YES;
	}
	
	return NO;
}

- (void)orderFrontPlayerIsNotRunningBezel:(id)sender {
	SCAlertBezelViewController* controller = [self orderFrontBezelOfClassIfNeeded:[SCAlertBezelViewController class] sender:sender];
	
	controller.text = NSLocalizedString(@"ITUNESNOTRUNNING_BEZEL_TEXT", @"iTunes is not running alert text on the keyboard bezel");
	controller.image = [NSImage templateImageNamed:ImageNameAlertTemplate];
}

- (void)orderFrontPlayerIsBusyBezel:(id)sender {
	SCAlertBezelViewController* controller = [self orderFrontBezelOfClassIfNeeded:[SCAlertBezelViewController class] sender:sender];
	
	controller.text = NSLocalizedString(@"ITUNESISBUSY_BEZEL_TEXT", @"iTunes is busy alert text on the keyboard bezel");
	controller.image = [NSImage templateImageNamed:ImageNameAlertTemplate];
}

- (void)orderFrontPlayerLaunchingBezel:(id)sender {
	SCAlertBezelViewController* controller = [self orderFrontBezelOfClassIfNeeded:[SCAlertBezelViewController class] sender:sender];
	
	controller.text = NSLocalizedString(@"ITUNESLAUNCHING_BEZEL_TEXT", @"iTunes launching alert text on the keyboard bezel");
	controller.image = [NSImage templateImageNamed:ImageNamePlayerTemplate];
}

- (BOOL)orderFrontNothingPlayingBezelIfNeeded:(id)sender {
	if(![[[CoverSutra self] nowPlayingController] track]) {
		SCAlertBezelViewController* controller = [self orderFrontBezelOfClassIfNeeded:[SCAlertBezelViewController class] sender:sender];
		
		controller.text = NSLocalizedString(@"NOSONG_BEZEL_TEXT", @"No song selected alert text on the keyboard bezel");
		controller.image = [NSImage templateImageNamed:ImageNameAlertTemplate];
		
		return YES;
	}
	
	return NO;
}

- (BOOL)orderFrontNotPlayableBezelIfNeeded:(id)sender {
	if(![[[CoverSutra self] playbackController] isPlayable]) {
		SCAlertBezelViewController* controller = [self orderFrontBezelOfClassIfNeeded:[SCAlertBezelViewController class] sender:sender];
		
		controller.text = NSLocalizedString(@"NOPLAYLIST_BEZEL_TEXT", @"No playlist selected alert text on the keyboard bezel");
		controller.image = [NSImage templateImageNamed:ImageNameAlertTemplate];
		
		return YES;
	}
	
	return NO;
}

@end
