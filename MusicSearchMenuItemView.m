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

#import "MusicSearchMenuItemView.h"
#import "MusicSearchMenuItemCell.h"

#import "MusicSearchMenuView.h"

#import "NSView+Additions.h"

#import "Utilities.h"

@implementation MusicSearchMenuItemView

@dynamic
	controlSize,
	representedObject;

+ (void)initialize {
	[self setCellClass:[MusicSearchMenuItemCell class]];
}

- (id)initWithFrame:(NSRect)frame {
	if(![super initWithFrame:frame]) {
		return nil;
	}

	return self;
}

- (NSControlSize)controlSize {
	return [[self cell] controlSize];
}

- (void)setControlSize:(NSControlSize)controlSize {
	[[self cell] setControlSize:controlSize];
}

- (id)representedObject {
	return [[self cell] representedObject];
}

- (void)setRepresentedObject:(id)representedObject {
	[[self cell] setRepresentedObject:representedObject];
}

- (BOOL)isOpaque {
	return NO;
}

- (NSMenu*)menuForEvent:(NSEvent*)theEvent {
	MusicSearchMenuView* menuView = (MusicSearchMenuView*)[self enclosingViewOfClass:
		[MusicSearchMenuView class]];
	[menuView setSelection:self.representedObject];
	
	[[self cell] setHighlighted:YES];
	[self display];

	return [super menuForEvent:theEvent];
}

- (BOOL)acceptsFirstResponder {
	return NO;
}

@end
