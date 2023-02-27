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

#import "MusicSearchMenuItemCell.h"
#import "MusicSearchMenuItemCell+Private.h"

#import "MusicSearchMenuView.h"

#import "MusicLibraryItem.h"

#import "NSColor+Additions.h"
#import "NSGradient+Additions.h"
#import "NSShadow+Additions.h"
#import "NSView+Additions.h"

#import "Utilities.h"

@implementation MusicSearchMenuItemCell

+ (BOOL)prefersTrackingUntilMouseUp {
	return YES;
}

- (id)initTextCell:(NSString*)text {
	if(![super initTextCell:text]) {
		return nil;
	}
	
	[self setTitle:@""];
	
	[self setButtonType:NSMomentaryChangeButton];
	[self setBordered:NO];
	[self setShowsBorderOnlyWhileMouseInside:YES];
	[self setBezeled:NO];
	
	[self sendActionOn:NSLeftMouseUpMask|NSLeftMouseDraggedMask];
	
	[self setImagePosition:NSImageLeft];
	[self setImageScaling:NSImageScaleProportionallyDown];
	[self setHighlightsBy:NSCellHasOverlappingImage];
	[self setShowsStateBy:NSNoCellMask];

	[self setState:NSOffState];
	[self setControlSize:NSRegularControlSize];
	[self setAlignment:NSNaturalTextAlignment];
	[self setLineBreakMode:NSLineBreakByTruncatingTail];
	
	_flags.blinking = 0;
	_flags.blinkOn = 0;
	_flags.reserved = 0;
	
	return self;
}


- (void)blink {
	NSView* controlView = [self controlView];
	
	_flags.blinking = 1;
	
	CGFloat blinkTime = 0.1;
	
	if(![self isHighlighted]) {
		[self setHighlighted:YES];
		[controlView display];
		[NSThread sleepForTimeInterval:blinkTime];
	}
	
	[self setHighlighted:NO];
	[controlView display];
	[NSThread sleepForTimeInterval:blinkTime];
	
	_flags.blinking = 0;
	
	[self setHighlighted:YES];
	[controlView display];
}

- (void)setControlSize:(NSControlSize)controlSize {
	[super setControlSize:controlSize];
	
	CGFloat fontSize = [NSFont systemFontSizeForControlSize:controlSize];
	[self setFont:
		[NSFont menuFontOfSize:fontSize]];
}

- (void)performClick:(id)sender {
	NSUInteger modifiers = self.controlView.window.currentEvent.modifierFlags;
	
	if(!(modifiers & NSControlKeyMask)) {
		[self blink];
	}

	[super performClick:sender];
}

- (void)mouseEntered:(NSEvent*)event {
	NSView* controlView = self.controlView;
	
	NSPoint currentMouseLocation = [[controlView window] mouseLocationOutsideOfEventStream];
	currentMouseLocation = [controlView convertPoint:currentMouseLocation fromView:nil];

	if([controlView mouse:currentMouseLocation inRect:controlView.bounds]) {
		[self setHighlighted:YES];
		
		// Update the current selection in the menu view
		MusicSearchMenuView* menuView = (MusicSearchMenuView*)[[self controlView]
			enclosingViewOfClass:[MusicSearchMenuView class]];
		menuView.selection = self.representedObject;
	}
}

- (void)mouseExited:(NSEvent*)event {
//	[self setHighlighted:NO];
}

- (BOOL)trackMouse:(NSEvent*)theEvent inRect:(NSRect)cellFrame ofView:(NSView*)controlView untilMouseUp:(BOOL)untilMouseUp {
	NSUInteger modifiers = theEvent.modifierFlags;
	
	if(!(modifiers & NSControlKeyMask)) {
		[self blink];
	}
	
	return [super trackMouse:theEvent inRect:cellFrame ofView:controlView untilMouseUp:untilMouseUp];
}

- (NSSize)cellSize {
	if([self image]) {
		return NSMakeSize(100.0, 21.0);
	}
	
	return NSMakeSize(100.0, 18.0);
}

- (NSSize)cellSizeForBounds:(NSRect)aRect {
	return [self cellSize];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSRect selectionFrame = cellFrame;
	
	selectionFrame.size.width -= 2.0;
	
	[NSGraphicsContext saveGraphicsState]; {
		if(_flags.blinking) {
			if(_flags.blinkOn) {
				[[self _selectedMenuItemGradient]
					drawInRect:selectionFrame
					angle:90.0];
			}
		} else {
			if([self isHighlighted] && [self isEnabled]) {
/*
				NSRect selectionFrame = NSInsetRect(cellFrame, 1.0, 0.0);
				NSBezierPath* selectionPath = [NSBezierPath bezierPathWithRoundedRect:selectionFrame
					xRadius:6.0
					yRadius:6.0];
				[[self _selectedMenuItemGradient]
					drawInBezierPath:selectionPath
					angle:90.0];
*/
				[[self _selectedMenuItemGradient]
					drawInRect:selectionFrame
					angle:90.0];
			} else {
//				CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
//				CGContextSetShouldSmoothFonts(context, NO);
			}
		}
		
		NSRect interiorFrame = NSInsetRect(cellFrame, 6.0, 0.0);
		[self drawInteriorWithFrame:interiorFrame inView:controlView];
	} [NSGraphicsContext restoreGraphicsState];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSImage* image = [self image];
	
	if(image) {
		NSRect imageFrame = NSMakeRect(
			NSMinX(cellFrame), NSMinY(cellFrame) - 0.0, // TODO
			/*image.size.width*/ 18.0, NSHeight(cellFrame));
		[self drawImage:image withFrame:imageFrame inView:controlView];
		
		cellFrame.origin.x += NSWidth(imageFrame) + 3.0;
		cellFrame.size.width -= NSWidth(imageFrame) + 3.0;
	}
	
	NSAttributedString* title = [self attributedTitle];
	
	// Colorize all track info 
	id representedObject = [self representedObject];
	
	if((![self isHighlighted] && [self isEnabled]) || ![self representedObject]) {
		NSMutableAttributedString* shadowedString = [[NSMutableAttributedString alloc] initWithAttributedString:title];
		
		[shadowedString addAttribute:NSForegroundColorAttributeName
			value:[NSColor selectedMenuItemTextColor]
			range:NSMakeRange(0, [shadowedString length])];

		title = shadowedString;
	}
	
	if(![self isHighlighted] && [self isEnabled] && [representedObject isKindOfClass:[MusicLibraryItem class]]) {
		NSString* displayName = [representedObject displayName];
		
		if([title length] >= [displayName length]) {
			NSMutableAttributedString* newTitle = [[NSMutableAttributedString alloc] initWithAttributedString:title];
		
			[newTitle addAttribute:NSForegroundColorAttributeName
				value:[NSColor menuItemLabelColor]
				range:NSMakeRange([displayName length], [title length] - [displayName length])];
			
			title = newTitle;
		}
	}
	
	if([self isHighlighted] && [self isEnabled]) {
		NSMutableAttributedString* highlightedString = [[NSMutableAttributedString alloc] initWithAttributedString:title];
		
		[highlightedString addAttribute:NSForegroundColorAttributeName
			value:[NSColor selectedMenuItemTextColor]
			range:NSMakeRange(0, [highlightedString length])];
		
		NSShadow* shadow = [[NSShadow alloc] init];
		
		[shadow setShadowOffset:NSMakeSize(0.0, 1.0)];
		[shadow setShadowBlurRadius:0.0];
		[shadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.5]];
		
		[highlightedString addAttribute:NSShadowAttributeName
			value:shadow
			range:NSMakeRange(0, [highlightedString length])];
			
			
		title = highlightedString;
	}
	
	if(![self representedObject]) {
		cellFrame.origin.x += 167.0;
		cellFrame.size.width -= 167.0;
	}
	
	[self drawTitle:title withFrame:cellFrame inView:controlView];
}

- (NSGradient*)_selectedMenuItemGradient {
	NSSize cellSize = [self cellSize];
	return [NSGradient selectedMenuItemGradientForHeight:cellSize.height];
}

@end
