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

#import "NSBezierPath+Additions.h"

@implementation NSBezierPath(CoverSutraAdditions)

+ (NSBezierPath*)missingItemBezierPath:(NSRect)rect {
	CGFloat dashPattern[2] = { 18.0, 4.0 };

	NSBezierPath* bezierPath = [NSBezierPath bezierPathWithRoundedRect:rect cornerRadius:14.0];
	[bezierPath setLineWidth:3.0];
	[bezierPath setLineDash:dashPattern count:2 phase:0.0];
	
	return bezierPath;
}

+ (NSBezierPath *) bezierPathWithRoundedRect: (NSRect)aRect cornerRadius: (float)radius inCorners:(CSCornerType)corners
{
	NSBezierPath* path = [self bezierPath];
	radius = MIN(radius, 0.5f * MIN(NSWidth(aRect), NSHeight(aRect)));
	NSRect rect = NSInsetRect(aRect, radius, radius);
	
	if (corners & CSBottomLeftCorner)
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMinY(rect)) radius:radius startAngle:180.0 endAngle:270.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMinX(aRect), NSMinY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	if (corners & CSBottomRightCorner)
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMinY(rect)) radius:radius startAngle:270.0 endAngle:360.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMaxX(aRect), NSMinY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}

	if (corners & CSTopRightCorner)
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMaxX(rect), NSMaxY(rect)) radius:radius startAngle:  0.0 endAngle: 90.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMaxX(aRect), NSMaxY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	if (corners & CSTopLeftCorner)
	{
		[path appendBezierPathWithArcWithCenter:NSMakePoint(NSMinX(rect), NSMaxY(rect)) radius:radius startAngle: 90.0 endAngle:180.0];
	}
	else
	{
		NSPoint cornerPoint = NSMakePoint(NSMinX(aRect), NSMaxY(aRect));
		[path appendBezierPathWithPoints:&cornerPoint count:1];
	}
	
	[path closePath];
	return path;	
}

+ (NSBezierPath*)bezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius {
    NSBezierPath* result = [NSBezierPath bezierPath];
    
	[result appendBezierPathWithRoundedRect:rect cornerRadius:radius];
    
	return result;
}

- (void)appendBezierPathWithRoundedRect:(NSRect)rect cornerRadius:(float)radius {
    if(!NSIsEmptyRect(rect)) {
		if(radius > 0.0) {
			// Clamp radius to be no larger than half the rect's width or height.
			float clampedRadius = MIN(radius, 0.5 * MIN(rect.size.width, rect.size.height));

			NSPoint topLeft = NSMakePoint(NSMinX(rect), NSMaxY(rect));
			NSPoint topRight = NSMakePoint(NSMaxX(rect), NSMaxY(rect));
			NSPoint bottomRight = NSMakePoint(NSMaxX(rect), NSMinY(rect));

			[self moveToPoint:NSMakePoint(NSMidX(rect), NSMaxY(rect))];
			[self appendBezierPathWithArcFromPoint:topLeft     toPoint:rect.origin radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:rect.origin toPoint:bottomRight radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:bottomRight toPoint:topRight    radius:clampedRadius];
			[self appendBezierPathWithArcFromPoint:topRight    toPoint:topLeft     radius:clampedRadius];
			
			[self closePath];
		} else {
			// When radius == 0.0, this degenerates to the simple case of a plain rectangle.
			[self appendBezierPathWithRect:rect];
		}
    }
}

- (void)appendBezierPathWithRoundedRect:(NSRect)rect1 withRect:(NSRect)rect2 cornerRadius:(float)radius {
    // Clamp radius to be no larger than half the rect's width or height.
	float clampedRadius = MIN(radius, 0.5 * MIN(MAX(NSWidth(rect1), NSWidth(rect2)), MAX(NSHeight(rect1), NSHeight(rect2))));
	
	NSPoint topLeft1 = NSMakePoint(NSMinX(rect1), NSMinY(rect1));
	NSPoint bottomLeft1 = NSMakePoint(NSMinX(rect1), NSMaxY(rect1));
	NSPoint topRight1 = NSMakePoint(NSMaxX(rect1), NSMinY(rect1));
	NSPoint bottomRight1 = NSMakePoint(NSMaxX(rect1), NSMaxY(rect1));
	
	NSPoint topLeft2 = NSMakePoint(NSMinX(rect2), NSMinY(rect2));
	NSPoint bottomLeft2 = NSMakePoint(NSMinX(rect2), NSMaxY(rect2));
	NSPoint topRight2 = NSMakePoint(NSMaxX(rect2), NSMinY(rect2));
	NSPoint bottomRight2 = NSMakePoint(NSMaxX(rect2), NSMaxY(rect2));
	
	[self moveToPoint:NSMakePoint(NSMidX(rect1), NSMinY(rect1))];
	[self appendBezierPathWithArcFromPoint:topLeft1     toPoint:bottomLeft1 radius:clampedRadius];
	[self appendBezierPathWithArcFromPoint:bottomLeft1     toPoint:topLeft2 radius:clampedRadius];
	[self appendBezierPathWithArcFromPoint:topLeft2     toPoint:bottomLeft2 radius:clampedRadius];
	
	[self appendBezierPathWithArcFromPoint:bottomLeft2     toPoint:bottomRight2 radius:clampedRadius];
	[self appendBezierPathWithArcFromPoint:bottomRight2     toPoint:topRight2 radius:clampedRadius];
	[self appendBezierPathWithArcFromPoint:topRight2     toPoint:bottomRight1 radius:clampedRadius];
	[self appendBezierPathWithArcFromPoint:bottomRight1 toPoint:topRight1    radius:clampedRadius];
	[self appendBezierPathWithArcFromPoint:topRight1    toPoint:topLeft1     radius:clampedRadius];
	
	[self closePath];
}

@end
