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

#import "NSArray+Additions.h"

#import "Utilities.h"

@implementation NSArray(CoverSutraAdditions)

- (id)firstObject {
	if(!IsEmpty(self)) {
		return [self objectAtIndex:0];
	}
	
	return nil;
}

- (NSArray*)arrayByRemovingObjectIdenticalTo:(id)object {
    NSMutableArray* filteredArray;
    
    if(![self containsObject:object]) {
        return [NSArray arrayWithArray:self];
	}

    filteredArray = [NSMutableArray arrayWithArray:self];
    [filteredArray removeObjectIdenticalTo:object];

    return [NSArray arrayWithArray:filteredArray];
}

- (NSArray*)arrayByRemovingObjectsIdenticalToObjectsInArray:(NSArray*)array {
	NSMutableArray* newArray = [NSMutableArray arrayWithCapacity:[self count]];
	
	unsigned numberOfObjects = [array count];
	unsigned indexOfObject = 0;
	
	for(; indexOfObject<numberOfObjects; ++indexOfObject) {
		id object = [array objectAtIndex:indexOfObject];
		
		NSInteger index = [self indexOfObjectIdenticalTo:object];
			
		if(index == NSNotFound) {
			[newArray addObject:object];
		}
	}
	
	return newArray;
}

@end
