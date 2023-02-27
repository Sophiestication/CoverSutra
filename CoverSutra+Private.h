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

#import "CoverSutra.h"

@interface CoverSutra()

@property(readwrite, strong) StarRatingController* currentRatingController;

- (void)_playpause:(id)sender;

- (void)_orderFrontNextSongBezel:(id)sender;
- (void)_orderFrontPreviousSongBezel:(id)sender;

- (void)_fastForward:(id)sender;
- (void)_rewind:(id)sender;

- (void)_increaseSoundVolume:(id)sender;
- (void)_decreaseSoundVolume:(id)sender;

- (void)_rateUsingSelector:(SEL)selector sender:(id)sender;
- (void)_rateCurrentSongWith:(NSInteger)rating sender:(id)sender;

- (void)_resetPreferencesWindowController;

@end
