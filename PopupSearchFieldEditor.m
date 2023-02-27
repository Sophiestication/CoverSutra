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

#import "PopupSearchFieldEditor.h"

#import "Utilities.h"

#import "NSEvent+Additions.h"

@implementation PopupSearchFieldEditor

- (void)keyDown:(NSEvent*)event {
	NSUInteger modifierFlags = event.modifierFlags;

	if([event hasCharacter:NSEnterCharacter] ||
	   [event hasCharacter:NSCarriageReturnCharacter] ||
	   [event hasCharacter:NSNewlineCharacter]) {
		[self insertNewline:event];
		return;
	}

	if([event hasUpArrowKey] && (modifierFlags & NSCommandKeyMask)) {
		[self moveUp:event];
		return;
	}
	
	if([event hasDownArrowKey] && (modifierFlags & NSCommandKeyMask)) {
		[self moveDown:event];
		return;
	}
	
	[super keyDown:event];
}

- (void)insertTab:(id)sender {
	[[self _actionDelegate] insertTab:sender];
}

- (void)insertTabIgnoringFieldEditor:(id)sender {
	[self insertTab:sender];
}

- (void)insertBacktab:(id)sender {
	[[self _actionDelegate] insertBacktab:sender];
}

- (void)insertNewline:(id)sender {
	[[self _actionDelegate] insertNewline:sender];
}

- (void)insertNewlineIgnoringFieldEditor:(id)sender {
	[[self _actionDelegate] insertNewline:sender];
}

- (void)cancelOperation:(id)sender {
	[[self _actionDelegate] cancelOperation:sender];
}

- (void)moveUp:(id)sender {
	[[self _actionDelegate] moveUp:sender];
}

- (void)moveDown:(id)sender {
	[[self _actionDelegate] moveDown:sender];
}

- (void)superscript:(id)sender {
}

- (void)subscript:(id)sender {
}

- (void)unscript:(id)sender {
}

- (id)_actionDelegate {
	return [(id)[self delegate] delegate];
}

@end
