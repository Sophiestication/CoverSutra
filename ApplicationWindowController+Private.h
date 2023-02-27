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

#import "ApplicationWindowController.h"

/*!
    @category	 ApplicationWindowController+Private
    @abstract    (brief description)
    @discussion  (comprehensive description)
*/
@interface ApplicationWindowController(Private)

- (void)_updatePlayerPositionSlider;
- (void)_updatePlayerButtons;
- (void)_updateShuffleButtons;
- (void)_updateSongRepeatButtons;
- (void)_updateSoundVolumeButtons;
- (void)_updatePlayerInfo;

- (void)_initPlayerControls;
- (void)_initPlaylistControls;
- (void)_initSoundVolumeControls;
- (void)_initTrackLabels;
- (void)_initActionButton;
- (void)_initAlert;

- (NSImage*)_segmentedControlButtonWithName:(NSString*)name;

- (void)_iTunesWillFinishLaunching:(NSNotification*)notification;
- (void)_iTunesDidTerminate:(NSNotification*)notification;

@end
