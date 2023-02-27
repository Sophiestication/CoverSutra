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

#import "NSGradient+Additions.h"

@implementation NSGradient(Additions)

+ (NSGradient*)selectedMenuItemGradientForHeight:(CGFloat)height {
	CGFloat smallestFraction = 1.0 / height;

	NSGradient* gradient = nil;
	
	if([NSColor currentControlTint] == NSGraphiteControlTint) {
		gradient = [[NSGradient alloc] initWithColorsAndLocations:
			[NSColor colorWithDeviceRed:(96.0 / 256.0) green:(105.0 / 256.0) blue:(113.0 / 256.0) alpha:1.0], 0.0,
			[NSColor colorWithDeviceRed:(107.0 / 256.0) green:(115.0 / 256.0) blue:(123.0 / 256.0) alpha:1.0], smallestFraction,
			[NSColor colorWithDeviceRed:(85.0 / 256.0) green:(94.0 / 256.0) blue:(105.0 / 256.0) alpha:1.0], 1.0 - smallestFraction,
			[NSColor colorWithDeviceRed:(68.0 / 256.0) green:(79.0 / 256.0) blue:(90.0 / 256.0) alpha:1.0], 1.0,
			nil];
	} else {
		gradient = [[NSGradient alloc] initWithColorsAndLocations:
			[NSColor colorWithDeviceRed:(72.0 / 256.0) green:(103.0 / 256.0) blue:(234.0 / 256.0) alpha:1.0], 0.0,
			[NSColor colorWithDeviceRed:(81.0 / 256.0) green:(112.0 / 256.0) blue:(246.0 / 256.0) alpha:1.0], smallestFraction,
			[NSColor colorWithDeviceRed:(26.0 / 256.0) green:(67.0 / 256.0) blue:(243.0 / 256.0) alpha:1.0], 1.0 - smallestFraction,
			[NSColor colorWithDeviceRed:(14.0 / 256.0) green:(54.0 / 256.0) blue:(231.0 / 256.0) alpha:1.0], 1.0,
			nil];
	}
		
	return gradient;
}

+ (NSGradient*)alternateSelectedMenuItemGradientForHeight:(CGFloat)height {
	CGFloat smallestFraction = 1.0 / height;

	NSGradient* gradient = nil;
	
	if([NSColor currentControlTint] == NSGraphiteControlTint) {
		gradient = [[NSGradient alloc] initWithColorsAndLocations:
			[NSColor colorWithDeviceRed:(96.0 / 256.0) green:(105.0 / 256.0) blue:(113.0 / 256.0) alpha:1.0], 0.0,
			[NSColor colorWithDeviceRed:(107.0 / 256.0) green:(115.0 / 256.0) blue:(123.0 / 256.0) alpha:1.0], smallestFraction,
//			[NSColor colorWithDeviceRed:(68.0 / 256.0) green:(79.0 / 256.0) blue:(90.0 / 256.0) alpha:1.0], 0.5,
			[NSColor colorWithDeviceRed:(85.0 / 256.0) green:(94.0 / 256.0) blue:(105.0 / 256.0) alpha:1.0], 1.0 - smallestFraction,
			[NSColor colorWithDeviceRed:(68.0 / 256.0) green:(79.0 / 256.0) blue:(90.0 / 256.0) alpha:1.0], 1.0,
			nil];
	} else {
		gradient = [[NSGradient alloc] initWithColorsAndLocations:
			[NSColor colorWithDeviceRed:(72.0 / 256.0) green:(103.0 / 256.0) blue:(234.0 / 256.0) alpha:1.0], 0.0,
			[NSColor colorWithDeviceRed:(81.0 / 256.0) green:(112.0 / 256.0) blue:(246.0 / 256.0) alpha:1.0], smallestFraction,
//			[NSColor colorWithDeviceRed:(14.0 / 256.0) green:(54.0 / 256.0) blue:(231.0 / 256.0) alpha:1.0], 0.5,
			[NSColor colorWithDeviceRed:(26.0 / 256.0) green:(67.0 / 256.0) blue:(243.0 / 256.0) alpha:1.0], 1.0 - smallestFraction,
			[NSColor colorWithDeviceRed:(14.0 / 256.0) green:(54.0 / 256.0) blue:(231.0 / 256.0) alpha:1.0], 1.0,
			nil];
	}
		
	return gradient;
}

@end
