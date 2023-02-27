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

#import "SCBezelController+Playback.h"
#import "SCBezelController+Alert.h"
#import "SCBezelController+Private.h"

#import "SCPlaybackBezelViewController.h"
#import "SCPlaybackModeBezelViewController.h"
#import "SCSoundVolumeBezelViewController.h"

@implementation SCBezelController(Playback)

- (void)orderFrontPlaypauseBezel:(id)sender {
	if(![self canOrderFrontShortcutBezel:sender]) { return; }
	if([self orderFrontAlertBezelIfNeeded:sender]) { return; }
	if([self orderFrontNotPlayableBezelIfNeeded:sender]) { return; }
	
	[self orderFrontBezelOfClassIfNeeded:[SCPlaybackBezelViewController class] sender:sender];
}

- (void)orderFrontSkippingBezel:(id)sender {
	if(![self canOrderFrontShortcutBezel:sender]) { return; }
	if([self orderFrontAlertBezelIfNeeded:sender]) { return; }
	if([self orderFrontNothingPlayingBezelIfNeeded:sender]) { return; }
	
	SCPlaybackBezelViewController* controller = [self orderFrontBezelOfClassIfNeeded:[SCPlaybackBezelViewController class] sender:sender];
	[controller didSkip];
}

- (void)orderFrontRewindingBezel:(id)sender {
	if(![self canOrderFrontShortcutBezel:sender]) { return; }
	if([self orderFrontAlertBezelIfNeeded:sender]) { return; }
	if([self orderFrontNothingPlayingBezelIfNeeded:sender]) { return; }
	
	SCPlaybackBezelViewController* controller = [self orderFrontBezelOfClassIfNeeded:[SCPlaybackBezelViewController class] sender:sender];
	[controller didRewind];
}

- (void)orderFrontShuffleBezel:(id)sender {
	if(![self canOrderFrontShortcutBezel:sender]) { return; }
	if([self orderFrontAlertBezelIfNeeded:sender]) { return; }
	
	SCPlaybackModeBezelViewController* controller = [self orderFrontBezelOfClassIfNeeded:[SCPlaybackModeBezelViewController class] sender:sender];
	[controller setShuffleMode];
}

- (void)orderFrontRepeatModeBezel:(id)sender {
	if(![self canOrderFrontShortcutBezel:sender]) { return; }
	if([self orderFrontAlertBezelIfNeeded:sender]) { return; }
	
	SCPlaybackModeBezelViewController* controller = [self orderFrontBezelOfClassIfNeeded:[SCPlaybackModeBezelViewController class] sender:sender];
	[controller setRepeatMode];
}

- (void)orderFrontSoundVolumeBezel:(id)sender {
	if(![self canOrderFrontShortcutBezel:sender]) { return; }
	if([self orderFrontAlertBezelIfNeeded:sender]) { return; }
	
	[self orderFrontBezelOfClassIfNeeded:[SCSoundVolumeBezelViewController class] sender:sender];
}

@end
