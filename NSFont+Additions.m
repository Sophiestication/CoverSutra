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

#import "NSFont+Additions.h"

@implementation NSFont(Additions)

+ (NSFont*)markerFontOfSize:(CGFloat)fontSize {
	NSFont* markerFont = [NSFont fontWithName:@"Marker Felt" size:fontSize];

	if(!markerFont) {
		markerFont = [NSFont systemFontOfSize:fontSize];
	}

	return markerFont;
}

+ (NSFont*)bezelFontOfSize:(CGFloat)fontSize {
	NSFont* bezelFont = [NSFont fontWithName:@"Helvetica Neue Bold" size:fontSize];

	if(!bezelFont) {
		bezelFont = [NSFont boldSystemFontOfSize:fontSize];
	}

	return bezelFont;
}

+ (NSFont*)notificationFontOfSize:(CGFloat)fontSize {
	NSFont* bezelFont = [NSFont fontWithName:@"Helvetica Neue Bold" size:fontSize];

	if(!bezelFont) {
		bezelFont = [NSFont boldSystemFontOfSize:fontSize];
	}

	return bezelFont;
}

@end
