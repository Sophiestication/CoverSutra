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

#import "Slider.h"
#import "SliderCell.h"

@implementation Slider

+ (Class)cellClass {
	return [SliderCell class];
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

// NSResponder interface

- (void)scrollWheel:(NSEvent*)theEvent {
	if(![self isEnabled]) {
		return; // We don't wanna change the value
	}
	
	CGFloat deltaY = [theEvent deltaY];
	CGFloat deltaX = [theEvent deltaX];
	
	if([theEvent respondsToSelector:@selector(isDirectionInvertedFromDevice)]) {
		if([theEvent isDirectionInvertedFromDevice]) {
			CGFloat y = deltaY;
			
			deltaY = deltaX;
			deltaX = y;
		}
	}
	
	CGFloat scrollDelta = abs(deltaY) > abs(deltaX) ? deltaY : -deltaX;
	scrollDelta = round(scrollDelta);
	
	if(abs(scrollDelta) < 1.0) {
		return;
	}
	
	scrollDelta *= 2.0;
	
	CGFloat trackWidth = NSWidth([[self cell] trackRect]);
	CGFloat minDelta = trackWidth / 100.0;
	
	CGFloat delta = minDelta * scrollDelta;
	
	CGFloat value = [self doubleValue];
	CGFloat newValue = value + delta;
	
	newValue = MAX([self minValue], newValue);
	newValue = MIN([self maxValue], newValue);
	
	if(newValue != [self doubleValue]) {
		[self setDoubleValue:newValue];

		[NSApp sendAction:[self action] to:[self target] from:self];
	}
}

@end
