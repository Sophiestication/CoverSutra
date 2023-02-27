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

#import "StarRatingControlCell.h"

#import "NSShadow+Additions.h"

#import "MusicLibraryTrack.h"
#import "NowPlayingController.h"

#import "CoverSutra.h"
#import "CoverSutra+Private.h"

#import "Utilities.h"

@implementation StarRatingControlCell

+ (BOOL)prefersTrackingUntilMouseUp {
	return YES;
}

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_ratingController = [[StarRatingController alloc] initWithTrack:nil];
	
	_minValue = 0;
	_maxValue = 5;
	
	_starImage = [[NSImage imageNamed:@"starRatingStar"] copy];
	[_starImage setCacheMode:NSImageCacheNever];
	
	_alternateStarImage = [[NSImage imageNamed:@"starRatingComputedStar"] copy];
	[_alternateStarImage setCacheMode:NSImageCacheNever];
	
	_dotImage = [[NSImage imageNamed:@"starRatingDot"] copy];
	[_dotImage setCacheMode:NSImageCacheNever];
	
	_isTracking = NO;
	
	return self;
}


- (int)minValue {
	return _minValue;
}

- (void)setMinValue:(int)minValue {
	_minValue = minValue;
}

- (int)maxValue {
	return _maxValue;
}

- (void)setMaxValue:(int)maxValue {
	_maxValue = maxValue;
}

- (id)representedObject {
	return _representedObject;
}

- (void)setRepresentedObject:(id)representedObject {
	if(representedObject != _representedObject) {
		[_representedObject removeObserver:self forKeyPath:@"rating"];
		[_representedObject removeObserver:self forKeyPath:@"ratingComputed"];
		
		_representedObject = representedObject;
		
		_ratingController.track = representedObject;
		
		[_representedObject addObserver:self
			forKeyPath:@"rating"
			options:NSKeyValueObservingOptionNew
			context:NULL];
		[_representedObject addObserver:self
			forKeyPath:@"ratingComputed"
			options:NSKeyValueObservingOptionNew
			context:NULL];
			
		[self _update];
	}
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
//	NSLog(@"%@", keyPath);
	[self _update];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSRect rect = [self drawingRectForBounds:cellFrame];
	
	id representedObject = [self representedObject];
	
	CGFloat value = 0;
	CGFloat maxValue = [self maxValue];

	CGFloat rating = [representedObject rating] / 20.0;
	BOOL isRatingComputed = [representedObject isRatingComputed];
		
	if(isRatingComputed && ![representedObject isAlbumRatingComputed]) {
		rating = [representedObject albumRating] / 20.0;
	}
	
	if(_isTracking) {
		rating = [self _valueForPoint:_trackingLocation];
	}
	
	for(; value<maxValue; ++value) {
		NSRect imageRect = NSMakeRect(
			NSMinX(rect) + (NSHeight(rect) * value), NSMinY(rect),
			NSHeight(rect), NSHeight(rect));
		
		imageRect = NSInsetRect(imageRect,
			(NSWidth(imageRect) - (NSWidth(imageRect))) * 0.5,
			(NSHeight(imageRect) - (NSHeight(imageRect))) * 0.5);
		imageRect = NSIntegralRect(imageRect);
		
		if(![controlView needsToDrawRect:imageRect]) {
			continue; // We don't need to draw this rating image
		}

		if(value >= rating && ![self isEnabled]) {
			continue; // Don't draw dots if we're not enabled
		}
		
		NSString* stringValue = value >= rating ?
			@"•" :
			@"★";
		CGFloat textSize = value >= rating ?
			7.0 :
			13.5;
		
		if(value >= rating) {
			imageRect = NSOffsetRect(imageRect, 0.0, -4.0);
		}
		
		// We like to use the alternate style, which is a outlined star
		if(value < rating && !_isTracking && isRatingComputed) {
			stringValue = @"☆";
		}

//		[image drawInRect:imageRect
//			fromRect:NSZeroRect
//			operation:NSCompositeSourceOver
//			fraction:1.0];
		
		NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
		
		[paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
		[paragraph setAlignment:NSCenterTextAlignment];
		
		NSDictionary* attributes = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor whiteColor], NSForegroundColorAttributeName,
			[NSFont boldSystemFontOfSize:textSize], NSFontAttributeName,
			[NSShadow HUDImageShadow], NSShadowAttributeName,
			paragraph, NSParagraphStyleAttributeName,
			nil];

		[stringValue drawInRect:imageRect withAttributes:attributes];
	}
}

- (NSSize)cellSizeForBounds:(NSRect)rect {
	CGFloat height = NSHeight(rect);
	CGFloat width = height * [self maxValue];
	
	return NSMakeSize(width, height);
}

/*
- (NSRect)drawingRectForBounds:(NSRect)rect {
	NSSize cellSize = [self cellSizeForBounds:rect];
	NSRect drawingRect = NSMakeRect(
		NSMidX(rect) - (cellSize.width * 0.5), NSMinY(rect),
		NSWidth(rect), NSHeight(rect));
		
	return drawingRect;
}
*/

- (BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView*)controlView {
	if(![self isEnabled]) {
		return NO;
	}
	
	BOOL result = [super startTrackingAt:startPoint inView:controlView];

	if(result || YES) {
		_isTracking = YES;
		_trackingLocation = startPoint;
	}
	
	int newValue = -1;
	
	while(1) {
        NSEvent* theEvent = [NSApp nextEventMatchingMask:NSLeftMouseDraggedMask|NSLeftMouseUpMask
			untilDate:[NSDate distantFuture]
			inMode:NSEventTrackingRunLoopMode
			dequeue:NO];

        if([theEvent type] == NSLeftMouseUp) {
            [self stopTracking:_trackingLocation
				at:_trackingLocation
				inView:controlView
				mouseIsUp:YES];
			
			_isTracking = NO;
			
			newValue = [self _valueForPoint:_trackingLocation];
			
			newValue = MAX(newValue, [self minValue]);
			newValue = MIN(newValue, [self maxValue]);
			
			// _ratingController.rating = newValue * 20.0;
			
			break;
		}
           
        [NSApp nextEventMatchingMask:NSLeftMouseDraggedMask
			untilDate:[NSDate distantFuture]
			inMode:NSEventTrackingRunLoopMode
			dequeue:YES];
        
		NSPoint point = [controlView
			convertPoint:[theEvent locationInWindow]
			fromView:nil];
        
		if(![self continueTracking:_trackingLocation at:point inView:controlView]) {
			[self stopTracking:_trackingLocation
				at:point
				inView:controlView
				mouseIsUp:NO];
			
			break;
		}
		
		[controlView setNeedsDisplay:YES];
    }
	
	_isTracking = NO;
	[controlView setNeedsDisplay:YES];
	
	if(newValue >= 0) {
		_ratingController.rating = newValue * 20.0;
		[_ratingController commit];
	}
	
	return result;
}

- (BOOL)continueTracking:(NSPoint)lastPoint at:(NSPoint)currentPoint inView:(NSView*)controlView {
	_trackingLocation = currentPoint;
	
	return YES;
}

- (void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView*)controlView mouseIsUp:(BOOL)mouseIsUp {
	[super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:mouseIsUp];
	
	_isTracking = NO;
	
	if(mouseIsUp) {
	}
}

- (void)_update {
	id track = nil;
	
	if(!track) {
		track = [[[CoverSutra self] currentRatingController] track];
	}

	if(!track) {
		track = [[[CoverSutra self] nowPlayingController] track];
	}

	[self setRepresentedObject:track];

	BOOL isEnabled = ![track isShared] && ![track isStreamed];
	[self setEnabled:isEnabled];
	
	[[self controlView] setNeedsDisplay:YES];
}

- (CGFloat)_valueForPoint:(NSPoint)point {
	NSRect cellFrame = [[self controlView] bounds];
	NSRect rect = [self drawingRectForBounds:cellFrame];
	
	CGFloat width = NSWidth(rect);
	CGFloat maxValue = [self maxValue];
	
	CGFloat value = (maxValue * point.x) / width;
	value -= 0.2;
	value = ceil(value);
	
	return value;
}

- (NSShadow*)_shadow {
	if(_shadow) {
		return _shadow;
	}
	
	NSShadow* shadow = [[NSShadow alloc] init];
	
	CGFloat offset = NSHeight([[self controlView] bounds]) > 20.0 ? 1.0 : 2.0;
	
	offset -= 1.0;
	offset = MAX(1.0, offset);
	
	[shadow setShadowOffset:
		NSMakeSize(0.0, -offset)];
	[shadow setShadowBlurRadius:1.0];
	[shadow setShadowColor:
		[NSColor blackColor]];
		
	_shadow = shadow;
		
	return _shadow;
}

@end
