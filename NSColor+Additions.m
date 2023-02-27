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

#import "NSColor+Additions.h"

@implementation NSColor(CoverSutraAdditions)

+ (NSColor*)menuItemLabelColor {
	return [NSColor colorWithCalibratedWhite:0.5 alpha:1.0];
}

- (NSColor*)lighterColor {
	CGFloat hue, saturation, brightness, alpha;
	
	[[self colorUsingColorSpaceName:NSDeviceRGBColorSpace] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	
	return [NSColor colorWithDeviceHue:hue saturation:MAX(0.0, saturation - 0.12) brightness:MIN(1.0, brightness + 0.30) alpha:alpha];
}

- (NSColor*)darkerColor {
	CGFloat hue, saturation, brightness, alpha;
	
	[[self colorUsingColorSpaceName:NSDeviceRGBColorSpace] getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
	
	return [NSColor colorWithDeviceHue:hue saturation:MIN(1.0, (saturation > 0.04) ? saturation + 0.12 : 0.0) brightness:MAX(0.0, brightness - 0.045) alpha:alpha];
}

@end
