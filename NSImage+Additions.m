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

#import "NSImage+Additions.h"

#import "NSArray+Additions.h"
#import "NSFont+Additions.h"

@implementation NSImage(Additions)

+ (NSImage*)templateImageNamed:(NSString*)imageName {
	NSImage* templateImage = [NSImage imageNamed:imageName];

	[templateImage setTemplate:YES];
	[templateImage setScalesWhenResized:YES];
	
	return templateImage;
}

+ (NSImage*)coverForArtist:(NSString*)artist album:(NSString*)album {
	NSImage* blankCover = [NSImage imageNamed:@"blankCover"];
	NSSize blankCoverSize = blankCover.size;
	
	NSImage* inscriptedCover = [[NSImage alloc] initWithSize:blankCoverSize];
	
	[inscriptedCover lockFocus]; {
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		
		// Draw the blank cover
		[blankCover drawInRect:NSMakeRect(0.0, 0.0, blankCoverSize.width, blankCoverSize.height)
			fromRect:NSZeroRect
			operation:NSCompositeSourceOver
			fraction:1.0];
		
		// Add some album descriptions
		NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
	
		[paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
		[paragraph setAlignment:NSCenterTextAlignment];

		NSDictionary* albumStyle = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor colorWithCalibratedRed:(32.0 / 256.0) green:(32.0 / 256.0) blue:(32.0 / 256.0) alpha:1.0], NSForegroundColorAttributeName,
			[NSFont markerFontOfSize:38.0], NSFontAttributeName,
			paragraph, NSParagraphStyleAttributeName, nil];
		
		NSAttributedString* albumString = [[NSAttributedString alloc] initWithString:album attributes:albumStyle];
		
		[albumString drawWithRect:NSMakeRect(0.0, 208.0, blankCoverSize.width, blankCoverSize.height)
			options:NSStringDrawingOneShot];
		
		NSDictionary* artistStyle = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor colorWithCalibratedRed:(64.0 / 256.0) green:(64.0 / 256.0) blue:(64.0 / 256.0) alpha:1.0], NSForegroundColorAttributeName,
			[NSFont markerFontOfSize:32.0], NSFontAttributeName,
			paragraph, NSParagraphStyleAttributeName, nil];
		
		NSAttributedString* artistString = [[NSAttributedString alloc] initWithString:artist attributes:artistStyle];
		
		[artistString drawWithRect:NSMakeRect(0.0, 162.0, blankCoverSize.width, blankCoverSize.height)
			options:NSStringDrawingOneShot];
	} [inscriptedCover unlockFocus];
	
	return inscriptedCover;
}

- (void)drawFlippedInRect:(NSRect)rect fromRect:(NSRect)sourceRect operation:(NSCompositingOperation)op fraction:(CGFloat)delta {
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
	CGContextSaveGState(context); {
        CGContextTranslateCTM(context, 0, NSMaxY(rect));
        CGContextScaleCTM(context, 1, -1);
        
        rect.origin.y = 0; // We've translated ourselves so it's zero
        [self drawInRect:rect fromRect:sourceRect operation:op fraction:delta];
    } CGContextRestoreGState(context);
}

- (void)drawFlippedInRect:(NSRect)rect fromRect:(NSRect)sourceRect operation:(NSCompositingOperation)op {
    [self drawFlippedInRect:rect fromRect:sourceRect operation:op fraction:1.0];
}

- (void)drawFlippedInRect:(NSRect)rect operation:(NSCompositingOperation)op fraction:(CGFloat)delta {
    [self drawFlippedInRect:rect fromRect:NSZeroRect operation:op fraction:delta];
}

- (void)drawFlippedInRect:(NSRect)rect operation:(NSCompositingOperation)op {
    [self drawFlippedInRect:rect operation:op fraction:1.0];
}

- (NSBitmapImageRep*)bitmapImageRep {
	NSBitmapImageRep* bitmapImageRep = nil;
	
	for(NSImageRep* imageRep in self.representations) {
		if([imageRep isKindOfClass:[NSBitmapImageRep class]]) {
			bitmapImageRep = (NSBitmapImageRep*)imageRep;
			break;
		}
	}
	
	if(!bitmapImageRep) {
		bitmapImageRep = [NSBitmapImageRep imageRepWithData:
			[self TIFFRepresentation]];
		[self addRepresentation:bitmapImageRep];
	}
	
	return bitmapImageRep;
}

- (CGImageRef)CGImage {
	return [[self bitmapImageRep] CGImage];
}


- (CGImageRef)CGImageForUserSpaceScaleFactor:(CGFloat)userSpaceScaleFactor {
	// TODO Actually check for the right image representation for the supplied scale factor
	return [self CGImage];
}

- (CIImage*)CIImage {
	return [[CIImage alloc] initWithBitmapImageRep:[self bitmapImageRep]];
}

@end

// ...
NSString* const ImageNameAlertTemplate = @"alertTemplate.pdf";
NSString* const ImageNameAdvancedTemplate = @"advancedTemplate.pdf";

NSString* const ImageNamePlayTemplate = @"playTemplate.pdf";
NSString* const ImageNamePauseTemplate = @"pauseTemplate.pdf";
NSString* const ImageNameFastForwardTemplate = @"fastForwardTemplate.pdf";
NSString* const ImageNameRewindTemplate = @"rewindTemplate.pdf";
NSString* const ImageNameStopTemplate = @"stopTemplate.pdf";

NSString* const ImageNameShuffleTemplate = @"shuffleOnTemplate.pdf";
NSString* const ImageNameShuffleOffTemplate = @"shuffleOffTemplate.pdf";

NSString* const ImageNameRepeatModeOffTemplate = @"repeatModeOffTemplate.pdf";
NSString* const ImageNameRepeatModeAllTemplate = @"repeatModeAllTemplate.pdf";
NSString* const ImageNameRepeatModeOneTemplate = @"repeatModeOneTemplate.pdf";

NSString* const ImageNameMinSoundVolumeTemplate = @"minSoundVolumeTemplate.pdf";
NSString* const ImageNameMaxSoundVolumeTemplate = @"maxSoundVolumeTemplate.pdf";
NSString* const ImageNameMuteSoundVolumeTemplate = @"muteSoundVolumeTemplate.pdf";

NSString* const ImageNamePlayerTemplate = @"iTunesTemplate.pdf";
