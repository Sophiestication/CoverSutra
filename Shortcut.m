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

#import "Shortcut.h"
#import "Shortcut+Private.h"

#import "ShortcutController.h"
#import "ShortcutController+Private.h"

#import "KeyCombination.h"

#import <Carbon/Carbon.h>

@implementation Shortcut

+ (Shortcut*)shortcutWithIdentifier:(id)identifier keyCombination:(KeyCombination*)keyCombination {
	if(!identifier) {
		return nil;
	}
	
	if(!keyCombination) {
		keyCombination = [KeyCombination emptyKeyCombination];
	}
	
	Shortcut* shortcut = [[ShortcutController sharedShortcutController] shortcutForIdentifier:identifier];
	
	if(shortcut) {
		[shortcut setKeyCombination:keyCombination];
		return shortcut;
	}
	
	return [[self alloc] initWithIdentifier:identifier keyCombination:keyCombination];
}

- (id)initWithIdentifier:(id)identifier keyCombination:(KeyCombination*)keyCombination {
	if(![super init]) {
		return nil;
	}
	
	_identifier = identifier;
	_keyCombination = keyCombination;
		
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
//	if(![super initWithCoder:coder]) {
//		return nil;
//	}

    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
//	[super encodeWithCoder:coder];

	[coder encodeObject:[self keyCombination] forKey:[self identifier]];
}


- (id)identifier {
	return _identifier;
}

- (void)setKeyCombination:(KeyCombination*)keyCombination {
	if(!EqualKeyCombinations(keyCombination, _keyCombination)) {
		_keyCombination = keyCombination;

		// Update key combination
		[[ShortcutController sharedShortcutController] _updateShortcut:self];
	}
}

- (KeyCombination*)keyCombination {
	return _keyCombination;
}

- (ShortcutEvent*)currentShortcutDownEvent {
	return _currentShortcutDownEvent;
}

- (ShortcutEvent*)currentShortcutUpEvent {
	return _currentShortcutUpEvent;
}

@end
