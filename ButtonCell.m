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

#import "ButtonCell.h"

#import "CIImage+Additions.h"

#import "NSImage+Additions.h"
#import "NSView+Additions.h"
#import "NSShadow+Additions.h"

#import <QuartzCore/QuartzCore.h>

@implementation ButtonCell

- (BOOL)isOpaque {
	if(self.controlView.HUDControl) {
		return NO;
	}
	
	return [super isOpaque];
}

- (NSBackgroundStyle)interiorBackgroundStyle {
	if(self.controlView.HUDControl) {
		return NSBackgroundStyleDark;
	}
	
	return [super interiorBackgroundStyle];
}

- (void)drawImage:(NSImage*)image withFrame:(NSRect)frame inView:(NSView*)controlView {
	[NSGraphicsContext saveGraphicsState]; {
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
	
		if(controlView.HUDControl) {
			[[NSShadow HUDImageShadow] set];
			
			if([self isHighlighted]) {
				// Grayen the image to display it highlighted
				CIFilter* filter = [CIFilter filterWithName:@"CIFalseColor"];
				
				[filter setDefaults];
				
				[filter setValue:[image CIImage] forKey:kCIInputImageKey];
				
				CIColor* grayColor = [CIColor colorWithRed:0.75 green:0.75 blue:0.75];
				[filter setValue:grayColor forKey:@"inputColor0"];
				[filter setValue:grayColor forKey:@"inputColor1"];
				
				CIImage* outputImage = [filter valueForKey:kCIOutputImageKey];
				image = [outputImage NSImage];
			}
		}
	
		[super drawImage:image withFrame:frame inView:controlView];
	} [NSGraphicsContext restoreGraphicsState];
}

@end
