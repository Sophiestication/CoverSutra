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

#import <Cocoa/Cocoa.h>

static inline BOOL IsEmpty(id thing) {
    return thing == nil
        || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
        || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

static inline BOOL ToBoolean(id value) {
	if(!value) {
		return NO;
	}
	
	if([value isKindOfClass:[NSNull class]]) {
		return NO;
	}
	
	if([value respondsToSelector:@selector(boolValue)]) {
		return [value boolValue];
	}
	
	if([value respondsToSelector:@selector(intValue)]) {
		return [value intValue];
	}
	
	if([value respondsToSelector:@selector(isEqualToString:)]) {
		return [value isEqualToString:@"1"];
	}
	
	return NO;
}

static inline BOOL EqualStrings(NSString* first, NSString* second) {
	if(first == second) {
		return YES;
	}
	
	if(!first || !second) {
		return NO;
	}
	
	BOOL isEqual = [first isEqualToString:second];

	return isEqual;
}

static inline NSString* StringValueForObject(id value) {
	if([value isKindOfClass:[NSString class]]) {
		return value;
	}
	
	if([value respondsToSelector:@selector(stringValue)]) {
		return [value performSelector:@selector(stringValue)];
	}
	
	return nil;
}
