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

#import "HUDSeparator.h"


@implementation HUDSeparator

- (id)initWithFrame:(NSRect)frame {
    if(![super initWithFrame:frame]) {
		return nil;
    }

    return self;
}

- (void)drawRect:(NSRect)rect {
    NSRect topLine = rect;
	topLine.size.height = 1.0;
	topLine.origin.y = 1.0;
	
	[[NSColor colorWithCalibratedWhite:0.0 alpha:0.25] set];
	NSRectFillUsingOperation(topLine, NSCompositeSourceOver);
	
	
	NSRect bottomLine = rect;
	bottomLine.size.height = 1.0;
	bottomLine.origin.y = 0.0;
	
	[[NSColor colorWithCalibratedWhite:1.0 alpha:0.25] set];
	NSRectFillUsingOperation(bottomLine, NSCompositeSourceOver);
}

@end
