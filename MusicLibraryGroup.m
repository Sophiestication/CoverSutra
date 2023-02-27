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

#import "MusicLibraryGroup.h"
#import "MusicLibraryGroup+Private.h"

#import "Utilities.h"

@implementation MusicLibraryGroup

@dynamic displayName;
@dynamic mutableItems;

@synthesize
	name = _name,
	representedObject = _representedObject,
	priority = _priority,
	custom1 = _custom1,
	custom2 = _custom2,
	custom3 = _custom3,
	items = _items;

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_items = [[NSMutableArray alloc] init];
	_priority = -1;
	
	return self;
}

- (id)copyWithZone:(NSZone*)zone {
	MusicLibraryGroup* copy = [[[self class] alloc] init];
	
	copy.name = self.name;
	
	copy.representedObject = self.representedObject;
	
	copy.custom1 = self.custom1;
	copy.custom2 = self.custom2;
	copy.custom3 = self.custom3;
	
	[copy->_items addObjectsFromArray:_items];

	return copy;
}


- (NSString*)displayName {
	return self.name;
}

- (NSArray*)tracks {
	return self.items;
}

- (BOOL)isEqual:(id)other {
	if([other isKindOfClass:[MusicLibraryGroup class]]) {
		MusicLibraryGroup* otherGroup = other;
		
		return EqualStrings(self.name, otherGroup.name);
	}
	
	return [super isEqual:other];
}

- (NSMutableArray*)mutableItems {
	return _items;
}

@end
