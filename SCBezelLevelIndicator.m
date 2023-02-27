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

#import "SCBezelLevelIndicator.h"
#import "SCBezelLevelIndicator+Private.h"

#import <QuartzCore/QuartzCore.h>

@implementation SCBezelLevelIndicator

@dynamic levelIndicatorStyle;
@dynamic value;

@synthesize color = _color;
@synthesize alternateColor = _alternateColor;
@synthesize indicatorShadow = _indicatorShadow;

#pragma mark -
#pragma mark Construction & Destruction

- (id)initWithFrame:(NSRect)frame {
    if(self = [super initWithFrame:frame]) {
		[self initIvars];
	}

    return self;
}

- (id)initWithCoder:(NSCoder*)coder {
    if(self = [super initWithCoder:coder]) {
		[self initIvars];
	}

    return self;
}


#pragma mark -
#pragma mark SCBezelLevelIndicator

- (SCBezelLevelIndicatorStyle)levelIndicatorStyle {
	return _levelIndicatorStyle;
}

- (void)setLevelIndicatorStyle:(SCBezelLevelIndicatorStyle)levelIndicatorStyle {
	if(levelIndicatorStyle != self.levelIndicatorStyle) {
		_levelIndicatorStyle = levelIndicatorStyle;
		[self setNeedsDisplay:YES];
	}
}

- (float)value {
	return _value;
}

- (void)setValue:(float)value {
	value = MIN(MAX(value, 0.0), 1.0); // 0.0-1.0 only
	
	if(value != self.value) {
		_value = value;
		[self setNeedsDisplay:YES];
	}
}

#pragma mark -
#pragma mark NSView

+ (NSFocusRingType)defaultFocusRingType { return NSFocusRingTypeNone; }

- (BOOL)isFlipped { return YES; }

- (BOOL)wantsDefaultClipping { return YES; }
- (BOOL)isOpaque { return NO; }

- (void)drawRect:(NSRect)rect {
	[super drawRect:rect];
	
	NSRect bounds = self.bounds;
	NSRect contentRect = NSInsetRect(bounds, 3.0, 3.0);
	
	switch(self.levelIndicatorStyle) {
		case SCContinuousBezelLevelIndicatorStyle:
			[self drawContinuousIndicatorInRect:contentRect];
		break;
		
		SCRegularBezelLevelIndicatorStyle:
		default:
			[self drawRegularIndicatorInRect:contentRect];
		break;
	}
}

#pragma mark -
#pragma mark Private

- (void)initIvars {
	self.levelIndicatorStyle = SCRegularBezelLevelIndicatorStyle;
	self.value = 0.0;
	
	self.color = [NSColor whiteColor];
	self.alternateColor = [NSColor colorWithDeviceWhite:0.0 alpha:0.5];
	
	NSShadow* shadow = [[NSShadow alloc] init];
		
	[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
	[shadow setShadowBlurRadius:1.5];
		
	NSColor* shadowColor = [NSColor colorWithDeviceWhite:0.0 alpha:0.6];
	[shadow setShadowColor:shadowColor];
	
	self.indicatorShadow = shadow;
}

- (void)drawRegularIndicatorInRect:(NSRect)rect {
	CGFloat numberOfLevels = 16.0;
	CGFloat currentLevel = ceilf(numberOfLevels * self.value);
	
	currentLevel = MIN(MAX(currentLevel, 0.0), numberOfLevels);
	
	CGSize indicatorSize = CGSizeMake(7.0, 9.0);
	CGFloat indicatorOffset = 2.0;
	
	for(NSInteger index = 0; index < numberOfLevels; ++index) {
		NSRect indicatorRect = NSMakeRect(
			NSMinX(rect) + indicatorSize.width * index + indicatorOffset * index,
			NSMinY(rect),
			indicatorSize.width,
			indicatorSize.height);
		
		if(index < currentLevel) {
			[NSGraphicsContext saveGraphicsState];
			
			[[self color] set];
			[[self indicatorShadow] set];
			
			NSRectFill(indicatorRect);
			
			[NSGraphicsContext restoreGraphicsState];
		} else {
			[[self alternateColor] set];
			NSRectFill(indicatorRect);
		}
	}
}

- (void)drawContinuousIndicatorInRect:(NSRect)rect {
	CGFloat valueOffset = floorf(NSWidth(rect) * self.value);
	
	NSRect valueRect = NSMakeRect(
		NSMinX(rect),
		NSMinY(rect),
		NSMinX(rect) + valueOffset,
		NSHeight(rect));
		
	CGFloat remainderWidth = NSWidth(rect) - valueOffset;
	
	NSRect remainderRect = NSMakeRect(
		NSMinX(rect) + valueOffset,
		NSMinY(rect),
		remainderWidth,
		NSHeight(rect));
	
	if(valueOffset > 0.0) {
		[NSGraphicsContext saveGraphicsState]; {
	
			[[self color] set];
			[[self shadow] set];

//			CGRect clipRect = self.bounds;
//			clipRect.size.width = CGRectGetMinX(remainderRect);
//			NSRectClip(clipRect);
			
			NSRectFill(valueRect);

		} [NSGraphicsContext restoreGraphicsState];
	}
	
	if(remainderWidth < NSWidth(rect)) {
		[NSGraphicsContext saveGraphicsState]; {
	
			[[self alternateColor] set];
			NSRectFill(remainderRect);

		} [NSGraphicsContext restoreGraphicsState];
	}
}

@end
