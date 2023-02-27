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

#import "MusicSearchAlbumCell.h"
#import "MusicSearchAlbumCell+Private.h"

#import "MusicLibraryArtist.h"
#import "MusicLibraryAlbum.h"
#import "MusicLibraryRating.h"
#import "MusicLibraryGroup.h"

#import "MusicSearchMenuView.h"
#import "MusicSearchMenuView+Private.h"

#import "Skin.h"

#import "NSColor+Additions.h"
#import "NSImage+Additions.h"
#import "NSShadow+Additions.h"
#import "NSView+Additions.h"

@implementation MusicSearchAlbumCell

@synthesize
	musicLibraryItem = _musicLibraryItem,
	skin = _skin;

- (id)init {
	if(![super init]) {
		return nil;
	}

	return self;
}


- (NSSize)cellSize {
	MusicLibraryItem* musicLibraryItem = self.musicLibraryItem;
	
	if([musicLibraryItem isKindOfClass:[MusicLibraryAlbum class]]) {
		return NSMakeSize(144.0, 78.0);
	}
	
	return NSMakeSize(144.0, 18.0);
}

- (NSSize)cellSizeForBounds:(NSRect)aRect {
	return [self cellSize];
}

- (void)mouseEntered:(NSEvent*)event {
	NSView* controlView = self.controlView;
	
	NSPoint currentMouseLocation = [[controlView window] mouseLocationOutsideOfEventStream];
	currentMouseLocation = [controlView convertPoint:currentMouseLocation fromView:nil];

	if([controlView mouse:currentMouseLocation inRect:controlView.bounds]) {
		// Update the current selection in the menu view
		MusicSearchMenuView* menuView = (MusicSearchMenuView*)[[self controlView] enclosingViewOfClass:
			[MusicSearchMenuView class]];
		menuView.selection = nil;
	}
}

- (void)mouseExited:(NSEvent*)event {
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
//	[[NSColor clearColor] set];
//	NSRectFill(cellFrame);
	
	[self drawInteriorWithFrame:cellFrame inView:controlView];
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	MusicLibraryItem* musicLibraryItem = self.musicLibraryItem;
	
//	// Draw focused if needed
//	if([self isHighlighted]) {
//		NSSetFocusRingStyle(NSFocusRingBelow);
//	}
	
	if([musicLibraryItem isKindOfClass:[MusicLibraryAlbum class]]) {
		cellFrame.origin.x += 4.0;
		cellFrame.origin.y += 0.0;
		cellFrame.size.width -= 8.0;
		cellFrame.size.height -= 0.0;
		
		[self drawAlbum:(MusicLibraryAlbum*)musicLibraryItem withFrame:cellFrame inView:controlView];
	} else if([musicLibraryItem isKindOfClass:[MusicLibraryArtist class]]) {
		cellFrame = NSOffsetRect(cellFrame, 0.0, 2.0);
		cellFrame = NSInsetRect(cellFrame, 4.0, 0.0);
		
		[self drawArtist:(MusicLibraryArtist*)musicLibraryItem withFrame:cellFrame inView:controlView];
	} else if([musicLibraryItem isKindOfClass:[MusicLibraryRating class]]) {
		cellFrame = NSOffsetRect(cellFrame, 0.0, 0.0);
		cellFrame = NSInsetRect(cellFrame, 4.0, 0.0);
		
		[self drawRating:(MusicLibraryRating*)musicLibraryItem withFrame:cellFrame inView:controlView];
	} else if([musicLibraryItem isKindOfClass:[MusicLibraryGroup class]]) {
		cellFrame = NSOffsetRect(cellFrame, 0.0, 4.0);
		cellFrame = NSInsetRect(cellFrame, 4.0, 0.0);
		
		[self drawGroup:(MusicLibraryGroup*)musicLibraryItem withFrame:cellFrame inView:controlView];
	}
}

- (void)drawArtist:(MusicLibraryArtist*)artist withFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSAttributedString* artistString = [[NSAttributedString alloc]
		initWithString:artist.displayName
		attributes:[self _titleStyle]];
	NSRect artistFrame = NSMakeRect(
		NSMinX(cellFrame), NSMinY(cellFrame),
		NSWidth(cellFrame), [artistString size].height);
	[artistString drawInRect:artistFrame];
}

- (void)drawAlbum:(MusicLibraryAlbum*)album withFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	// Draw album case
	NSDictionary* musicSearchCase = [[self skin] caseDescriptionOfSkinSize:ExtraSmallSkinSize];
	NSImage* caseImage = [musicSearchCase objectForKey:SkinCaseImageKey];
	
	NSSize imageSize = [[musicSearchCase objectForKey:SkinCaseSizeKey] sizeValue];
	NSPoint imageOrigin = NSMakePoint(
		NSMaxX(cellFrame) - imageSize.width,
		NSMinY(cellFrame) + imageSize.height);
	
	NSImage* previewImage = [[(MusicSearchMenuView*)controlView.superview coverCache]
		coverForAlbum:(MusicLibraryAlbum*)self.musicLibraryItem];
	
	if(!previewImage) {
		previewImage = [NSImage imageNamed:@"extraSmallBlankCover"];
	}
	
	if(previewImage) {
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		
		NSRect coverFrame = [[musicSearchCase objectForKey:SkinCoverFrameKey] rectValue];
		NSRect coverRect = NSMakeRect(
			imageOrigin.x + NSMinX(coverFrame), imageOrigin.y - imageSize.height + NSMinY(coverFrame),
			NSWidth(coverFrame), NSHeight(coverFrame));

		CGFloat widthAspectRatio =  previewImage.size.width /  previewImage.size.height;
		CGFloat heightAspectRatio =  previewImage.size.height /  previewImage.size.width;
			
		if(widthAspectRatio > heightAspectRatio) {
			heightAspectRatio = 1.0;
		} else {
			widthAspectRatio = 1.0;
		}
		
		[NSGraphicsContext saveGraphicsState]; {
			NSRect imageRect = NSMakeRect(
				NSMinX(coverRect), NSMinY(coverRect),
				NSWidth(coverRect) * widthAspectRatio, NSHeight(coverRect) * heightAspectRatio);
			imageRect.origin = NSMakePoint(
				NSMidX(coverRect) - NSWidth(imageRect) * 0.5,
				NSMidY(coverRect) - NSHeight(imageRect) * 0.5);

			NSRectClip(coverRect);
			
			[previewImage drawFlippedInRect:imageRect
				fromRect:NSZeroRect
				operation:NSCompositeSourceOver
				fraction:1.0];
		} [NSGraphicsContext restoreGraphicsState];
		
//		[caseImage compositeToPoint:imageOrigin
//			operation:NSCompositeSourceOver
//			fraction:1.0];
		
		NSRect caseRect = NSMakeRect(imageOrigin.x, imageOrigin.y - caseImage.size.height, caseImage.size.width, caseImage.size.height);
		[caseImage drawFlippedInRect:caseRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	}
	
	// And the titles
	NSAttributedString* artistString = [[NSAttributedString alloc]
		initWithString:album.displayName
		attributes:[self _artistStyle]];
	NSRect artistFrame = NSMakeRect(
		NSMinX(cellFrame), imageOrigin.y + 0.0,
		NSWidth(cellFrame) - 1.0, [artistString size].height);
	[artistString drawInRect:artistFrame];
	
	NSAttributedString* albumString = [[NSAttributedString alloc]
		initWithString:album.displayArtist
		attributes:[self _titleStyle]];
	NSRect albumFrame = NSMakeRect(
		NSMinX(artistFrame), NSMaxY(artistFrame) + 1.0,
		NSWidth(artistFrame), [albumString size].height);
	[albumString drawInRect:albumFrame];
}

- (void)drawRating:(MusicLibraryRating*)rating withFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSAttributedString* ratingString = [[NSAttributedString alloc]
		initWithString:rating.displayName
		attributes:[self _ratingStyle]];
	NSRect ratingFrame = NSMakeRect(
		NSMinX(cellFrame), NSMinY(cellFrame),
		NSWidth(cellFrame), [ratingString size].height);
	[ratingString drawInRect:ratingFrame];
}

- (void)drawGroup:(MusicLibraryGroup*)group withFrame:(NSRect)cellFrame inView:(NSView*)controlView {
	NSAttributedString* stringValue = [[NSAttributedString alloc]
		initWithString:group.displayName
		attributes:[self _titleStyle]];
	NSRect frame = NSMakeRect(
		NSMinX(cellFrame), NSMinY(cellFrame),
		NSWidth(cellFrame), [stringValue size].height);
	[stringValue drawInRect:frame];
}

- (NSDictionary*)_titleStyle {
	static NSDictionary* _titleStyle = nil;
	
	if(!_titleStyle) {
		NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
	
		[paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
		[paragraph setAlignment:NSRightTextAlignment];

		NSDictionary* titleStyle = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor menuItemLabelColor], NSForegroundColorAttributeName,
			[NSFont systemFontOfSize:10.0], NSFontAttributeName,
			[NSShadow searchMenuItemTextShadow], NSShadowAttributeName,
			paragraph, NSParagraphStyleAttributeName,
			nil];
			
		_titleStyle = titleStyle;
	}
	
	return _titleStyle;
}

- (NSDictionary*)_artistStyle {
	static NSDictionary* _artistStyle = nil;
	
	if(!_artistStyle) {
		NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
		
		[paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
		[paragraph setAlignment:NSRightTextAlignment];
		
		NSDictionary* artistStyle = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor menuItemLabelColor], NSForegroundColorAttributeName,
			[NSFont boldSystemFontOfSize:10.0], NSFontAttributeName,
			[NSShadow searchMenuItemTextShadow], NSShadowAttributeName,
			paragraph, NSParagraphStyleAttributeName,
			nil];
	
		_artistStyle = artistStyle;
	}
	
	return _artistStyle;
}

- (NSDictionary*)_ratingStyle {
	static NSDictionary* _ratingStyle = nil;
	
	if(!_ratingStyle) {
		NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
	
		[paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
		[paragraph setAlignment:NSRightTextAlignment];

		NSDictionary* ratingStyle = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor menuItemLabelColor], NSForegroundColorAttributeName,
			[NSFont systemFontOfSize:12.0], NSFontAttributeName,
			[NSShadow searchMenuItemTextShadow], NSShadowAttributeName,
			paragraph, NSParagraphStyleAttributeName,
			[NSNumber numberWithFloat:1.0], NSKernAttributeName, // TODO
			nil];
	
		_ratingStyle = ratingStyle;
	}
	
	return _ratingStyle;
}

@end
