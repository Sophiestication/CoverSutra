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

#import "SCBezelTextFieldCell.h"
#import "SCBezelTextFieldCell+Private.h"

#import "NSFont+Additions.h"

@implementation SCBezelTextFieldCell

@synthesize textShadow = _textShadow;

- (id)init {
	if(self = [super init]) {
		[self initIvars];
	}
	
	return self;
}

- (id)initTextCell:(NSString*)text {
	if(self = [super initTextCell:text]) {
		[self initIvars];
	}
	
	return self;
}

- (id)initImageCell:(NSImage*)image {
	if(self = [super initImageCell:image]) {
		[self initIvars];
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder *)coder {
	if(self = [super initWithCoder:coder]) {
		[self initIvars];
	}
	
	return self;
}


- (BOOL)isOpaque { return NO; }
- (NSBackgroundStyle)interiorBackgroundStyle { return NSBackgroundStyleLight; }

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	[NSGraphicsContext saveGraphicsState]; {
	
		CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
		CGContextSetShouldSmoothFonts(context, NO);

		[[self textShadow] set];

		cellFrame = CGRectOffset(cellFrame, 0.0, -1.0);
		[super drawInteriorWithFrame:cellFrame inView:controlView];

	} [NSGraphicsContext restoreGraphicsState];
}

#pragma mark -
#pragma mark Private

- (void)initIvars {
	[self setFocusRingType:NSFocusRingTypeNone];
	[self setRefusesFirstResponder:YES];

	[self setUsesSingleLineMode:YES];
	[self setLineBreakMode:NSLineBreakByTruncatingTail];
	
	[self setBackgroundColor:[NSColor clearColor]];
	
	[self setBordered:NO];
	[self setBezeled:NO];
	
	[self setEditable:NO];
	[self setSelectable:NO];
	
	[self setAlignment:NSCenterTextAlignment];
	
	[self setBackgroundStyle:NSBackgroundStyleRaised];

	CGFloat fontSize = [[self font] pointSize];
	NSFont* font = [NSFont bezelFontOfSize:fontSize];
	[self setFont:font];

	[self setTextColor:[NSColor whiteColor]];
	
	NSShadow* textShadow = [[NSShadow alloc] init];
		
	[textShadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	[textShadow setShadowBlurRadius:1.5];
		
	NSColor* shadowColor = [NSColor colorWithDeviceWhite:0.0 alpha:0.6];
	[textShadow setShadowColor:shadowColor];
	
	self.textShadow = textShadow;
}

@end
