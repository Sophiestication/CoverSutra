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

#import "NSResponder+SpecialKeys.h"
#import "NSResponder+MediaPlayer.h"

@implementation NSResponder(SpecialKeys)

- (BOOL)interpretSpecialKeyEvent:(NSEvent*)theEvent {
	unsigned short keyCode = [theEvent specialKeyCode];
		
	SEL theSelector = nil;
		
	if(keyCode == NX_KEYTYPE_PLAY) { theSelector = @selector(playpause:); }
	if(keyCode == NX_KEYTYPE_REWIND) { theSelector = @selector(previous:); }
	if(keyCode == NX_KEYTYPE_FAST) { theSelector = @selector(next:); }
	
	if(keyCode == NX_KEYTYPE_SOUND_UP) { theSelector = @selector(increaseSystemSoundVolume:); }
	if(keyCode == NX_KEYTYPE_SOUND_DOWN) { theSelector = @selector(decreaseSystemSoundVolume:); }
	if(keyCode == NX_KEYTYPE_MUTE) { theSelector = @selector(muteSystemSoundVolume:); }
		
	if(theSelector) {
		return [self tryToPerform:theSelector with:theEvent];
	}
	
	return NO;
}

@end
