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

#import "NSMenu+Additions.h"

@implementation NSMenu(CoverSutraAdditions)

- (void)addItemsFromArray:(NSArray*)items {
	for(NSMenuItem* item in items) {
		[self addItem:item];
	}
}

- (NSArray*)itemsWithTag:(int)tag {
	NSMutableArray* array = [NSMutableArray array];

	for(NSMenuItem* item in self.itemArray) {
		if([item tag] == tag) {
			[array addObject:item];
		}
	}
	
	return array;
}

- (NSArray*)itemsWithAction:(SEL)action {
	NSMutableArray* array = [NSMutableArray array];

	for(NSMenuItem* item in self.itemArray) {
		if([item action] == action) {
			[array addObject:item];
		}
	}
	
	return array;
}

- (void)removeItems:(NSArray*)items {
	for(NSMenuItem* item in items) {
		[self removeItem:item];
	}
}

@end
