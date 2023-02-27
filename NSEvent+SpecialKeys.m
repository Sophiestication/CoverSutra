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

#import "NSEvent+SpecialKeys.h"

@implementation NSEvent(SpecialKeys)

- (BOOL)isSpecialKeyEvent {
	return [self type] == NSSystemDefined && [self subtype] == 8;
}

- (unsigned short)specialKeyCode {
	unsigned short keyCode = (([self data1] & 0xFFFF0000) >> 16);
	return keyCode;
}

- (BOOL)isSpecialKeyDown {
	int keyFlags = ([self data1] & 0x0000FFFF);
	return (((keyFlags & 0xFF00) >> 8)) == 0xA;
}

- (BOOL)isSpecialKeyARepeat {
	int keyFlags = ([self data1] & 0x0000FFFF);
	return (keyFlags & 0x1) == 1;
}

@end
