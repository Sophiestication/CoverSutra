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

#import "KeyCombination.h"

#import "Shortcut.h"

#import <Carbon/Carbon.h>

@implementation KeyCombination

+ (KeyCombination*)emptyKeyCombination {
	return [self keyCombinationWithKeyCode:-1 modifiers:0];
}

+ (KeyCombination*)keyCombinationWithKeyCode:(short)keyCode modifiers:(unsigned int)modifiers {
	return [[self alloc] initWithKeyCode:keyCode modifiers:modifiers];
}

- (id)initWithKeyCode:(short)keyCode modifiers:(unsigned int)modifiers {
	if((self = [super init])) {
		_keyCode =  MAX(keyCode, -1);
		_modifiers = MAX(modifiers, 0);
	}
	
	return self;
}

- (id)initWithCoder:(NSCoder*)coder {
//	if(![super initWithCoder:coder]) {
//		return nil;
//	}
	
	_keyCode = [coder decodeIntForKey:@"keyCode"];
	_modifiers = [coder decodeInt32ForKey:@"modifiers"];
	
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder {
//	[super encodeWithCoder:coder];
    
	[coder encodeInt:[self keyCode] forKey:@"keyCode"];
	[coder encodeInt32:[self modifiers] forKey:@"modifiers"];
}

- (short)keyCode {
	return _keyCode;
}

- (unsigned int)modifiers {
	return _modifiers;
}

- (unsigned int)carbonModifiers {
	unsigned int cocoaModifiers = [self modifiers];
	unsigned int carbonModifiers = 0;
	
	if(cocoaModifiers & NSCommandKeyMask) { carbonModifiers += cmdKey; }
	if(cocoaModifiers & NSAlternateKeyMask) { carbonModifiers += optionKey; }
	if(cocoaModifiers & NSControlKeyMask) { carbonModifiers += controlKey; }
	if(cocoaModifiers & NSShiftKeyMask) { carbonModifiers += shiftKey; }
	if(cocoaModifiers & NSFunctionKeyMask) { carbonModifiers += NSFunctionKeyMask; }
	
	return carbonModifiers;
}

- (BOOL)isEqual:(id)other {
	if([other respondsToSelector:@selector(isEqualToKeyCombination:)]) {
		return [other isEqualToKeyCombination:self];
	}
	
	return NO;
}

- (BOOL)isEqualToKeyCombination:(KeyCombination*)keyCombination {
	if(keyCombination == self) {
		return YES;
	}
	
	return	[self keyCode] == [keyCombination keyCode] &&
			[self modifiers] == [keyCombination modifiers];
}

- (BOOL)isValid {
	return [self keyCode] >= 0;
}

- (BOOL)isEmpty {
	return ![self isValid];
//	return [self keyCode] <= 0 && [self modifiers] == 0;
}

@end

BOOL EqualKeyCombinations(KeyCombination* first, KeyCombination* second) {
	if(first == second) {
		return YES;
	}
	
	if(!first || !second) {
		return NO;
	}
	
	return [(first ? first : second) isEqualToKeyCombination:(first ? second : first)];
}
