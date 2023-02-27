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

#import "PopupSearchField.h"

#import "PopupSearchFieldCell.h"
#import "PopupSearchButtonCell.h"

@implementation PopupSearchField

@dynamic filter;

+ (void)initialize {
	[self setCellClass:[PopupSearchFieldCell class]];
}

- (id)initWithFrame:(NSRect)frameRect {
	if(![super initWithFrame:frameRect]) {
		return nil;
	}
	
	[self initView];
	
	return self;
}

- (id)initWithCoder:(id)coder {
	if(![super initWithCoder:coder]) {
		return nil;
	}
	
	[self initView];

	return self;
}

- (void)initView {
	[self setFocusRingType:NSFocusRingTypeNone];
	
	// Register for control tint changeing notifications
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_controlTintDidChange:)
		name:NSControlTintDidChangeNotification
		object:NSApp];
}

-(void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_controlTintDidChange:(NSNotification*)notification {
	[self setNeedsDisplay:YES];
}

- (PopupSearchFieldFilter)filter {
	return [[self cell] filter];
}

- (void)setFilter:(PopupSearchFieldFilter)filter {
	if(filter != [self filter]) {
		[[self cell] setFilter:filter];
		[self setNeedsDisplay:YES];
	}
}

- (BOOL)isOpaque {
	return NO;
}

- (BOOL)acceptsFirstResponder {
	return YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent*)theEvent {
	return YES;
}

- (BOOL)isFlipped {
	return YES;
}

@end
