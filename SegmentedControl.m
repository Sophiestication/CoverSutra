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

#import "SegmentedControl.h"
#import "SegmentedCell.h"

@implementation SegmentedControl

@dynamic
	delayedTarget,
	delayedAction;

+ (Class)cellClass {
	return [SegmentedCell class];
}

- (id)initWithFrame:(NSRect)frame {
    if(![super initWithFrame:frame]) {
		return nil;
    }

    return self;
}

- initWithCoder:(NSCoder*)coder {
	if(![coder isKindOfClass: [NSKeyedUnarchiver class]]) {
		self = [super initWithCoder:coder]; 
	} else {
		NSKeyedUnarchiver* newCoder = (id)coder;
		
		NSString* oldClassName = [[[self superclass] cellClass] className];
		Class oldClass = [newCoder classForClassName:oldClassName];
		
		if(!oldClass) {
			oldClass = [[super superclass] cellClass];
		}
		
		[newCoder setClass:
			[[self class] cellClass]
			forClassName:oldClassName];

		self = [super initWithCoder:newCoder];
		
		[newCoder setClass:oldClass
			forClassName:oldClassName];
	}
	
	return self;
}

- (id)delayedTarget {
	return [[self cell] delayedTarget];
}

- (void)setDelayedTarget:(id)target {
	[[self cell] setDelayedTarget:target];
}

- (SEL)delayedAction {
	return [[self cell] delayedAction];
}

- (void)setDelayedAction:(SEL)action {
	[[self cell] setDelayedAction:action];
}

- (void)rightMouseDown:(NSEvent*)theEvent {
	[self mouseDown:theEvent];
}

@end
