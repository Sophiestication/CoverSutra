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

#import "Skin.h"
#import "Skin+Private.h"

#import "MusicLibraryTrack.h"

#import "NSArray+Additions.h"
#import "NSFont+Additions.h"
#import "NSString+Additions.h"

@implementation Skin

NSString* const SkinCaseImageKey = @"caseImage";
NSString* const SkinEmptyCaseImageKey = @"emptyCase";
NSString* const SkinCaseSizeKey = @"caseSize";
NSString* const SkinCoverFrameKey = @"coverFrame";
NSString* const SkinCaseAlignmentRectKey = @"alignmentRect";
NSString* const SkinCoverMaskKey = @"coverMask";

NSString* const ExtraSmallSkinSize = @"CoverSutraAlbumCaseExtraSmall";
NSString* const SmallSkinSize = @"CoverSutraAlbumCaseSmall";
NSString* const MediumSkinSize = @"CoverSutraAlbumCaseMedium";
NSString* const LargeSkinSize = @"CoverSutraAlbumCaseLarge";

+ (Skin*)skinWithContentsOfFile:(NSString*)skinFile {
	return [[[self class] alloc] initWithContentsOfFile:skinFile];
}

- (id)initWithContentsOfFile:(NSString*)skinFile {
	if(![super init]) {
		return nil;
	}
	
	_caseDescriptions = [[NSMutableDictionary alloc] init];

	_path = skinFile;
	_attributes = [[NSDictionary alloc] initWithContentsOfFile:
		[_path stringByAppendingPathComponent:@"Info.plist"]];
	
	return self;
}


- (id)identifier {
	return [_attributes objectForKey:@"CFBundleIdentifier"];
}

- (NSDictionary*)caseDescriptionOfSkinSize:(NSString*)skinSize {
	NSDictionary* caseDescription = [_caseDescriptions objectForKey:skinSize];
	
	if(!caseDescription) {
		caseDescription = [self _caseDescriptionForKey:skinSize];
		
		if(caseDescription) {
			[_caseDescriptions setObject:caseDescription forKey:skinSize];
		}
	}
	
	return caseDescription;
}

- (NSImage*)albumCaseWithTrack:(MusicLibraryTrack*)track ofSkinSize:(NSString*)skinSize {
	if(EqualStrings(ExtraSmallSkinSize, skinSize)) {
		return [self albumCaseWithCover:[NSImage imageNamed:@"extraSmallBlankCover"] ofSkinSize:skinSize];
	}
	
	if(!track && (EqualStrings(MediumSkinSize, skinSize) || EqualStrings(LargeSkinSize, skinSize))) {
		NSDictionary* caseDescription = [self caseDescriptionOfSkinSize:skinSize];
		return [caseDescription objectForKey:SkinEmptyCaseImageKey];
	}
	
	NSString* displayArtist = track.displayAlbumArtist;
	NSString* displayAlbum = track.displayAlbum;
	
	NSImage* blankCover;
	NSSize blankCoverSize;
	
	if(SFEqualStrings(skinSize, LargeSkinSize)) {
		blankCover = [NSImage imageNamed:@"blankCover"];
		blankCoverSize = NSMakeSize(400.0, 400.0);
	} else {
		blankCover = [NSImage imageNamed:@"mediumBlankCover"];
		blankCoverSize = NSMakeSize(144.0, 144.0);
	}
	
	NSImage* inscriptedCover = [[NSImage alloc] initWithSize:blankCoverSize];
	
	[inscriptedCover lockFocus]; {
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		
		// Draw the blank cover
		[blankCover drawInRect:NSMakeRect(0.0, 0.0, blankCoverSize.width, blankCoverSize.height)
					  fromRect:NSZeroRect
					 operation:NSCompositeCopy
					  fraction:1.0];
		
		// Add some album descriptions
		NSMutableParagraphStyle* paragraph = [[NSMutableParagraphStyle alloc] init];
		
		[paragraph setLineBreakMode:NSLineBreakByTruncatingTail];
		[paragraph setAlignment:NSCenterTextAlignment];
		
		CGFloat margin = 8.0;
		
		CGFloat albumTextSize = 13.5;
		
		if(SFEqualStrings(skinSize, LargeSkinSize)) {
			albumTextSize = 36.0;
		}
		
		NSDictionary* albumStyle = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor colorWithCalibratedRed:(32.0 / 256.0) green:(32.0 / 256.0) blue:(32.0 / 256.0) alpha:1.0], NSForegroundColorAttributeName,
			[NSFont markerFontOfSize:albumTextSize], NSFontAttributeName,
			paragraph, NSParagraphStyleAttributeName, nil];

		NSAttributedString* albumString = [[NSAttributedString alloc] initWithString:displayAlbum ? displayAlbum : @"" attributes:albumStyle];
		
		NSRect albumRect = NSMakeRect(margin - 4.0, 74.0, blankCoverSize.width - margin, blankCoverSize.height);
		
		if(SFEqualStrings(skinSize, LargeSkinSize)) {
			albumRect = NSMakeRect(margin + 10.0, 210.0, blankCoverSize.width - margin * 2.0 - 20.0, blankCoverSize.height);
		}
		
		[albumString drawWithRect:albumRect options:NSStringDrawingOneShot];
		
		CGFloat artistTextSize = 13.0;

		if(SFEqualStrings(skinSize, LargeSkinSize)) {
			artistTextSize = 32.0;
		}
		
		NSDictionary* artistStyle = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSColor colorWithCalibratedRed:(32.0 / 256.0) green:(32.0 / 256.0) blue:(32.0 / 256.0) alpha:1.0], NSForegroundColorAttributeName,
			[NSFont markerFontOfSize:artistTextSize], NSFontAttributeName,
			paragraph, NSParagraphStyleAttributeName, nil];
		
		NSAttributedString* artistString = [[NSAttributedString alloc] initWithString:displayArtist ? displayArtist : @"" attributes:artistStyle];
		
		NSRect artistRect = NSMakeRect(margin - 4.0, 57.0, blankCoverSize.width - margin, blankCoverSize.height);
		
		if(SFEqualStrings(skinSize, LargeSkinSize)) {
			artistRect = NSMakeRect(margin + 10.0, 165.0, blankCoverSize.width - margin * 2.0 - 20.0, blankCoverSize.height);
		}
		
		[artistString drawWithRect:artistRect options:NSStringDrawingOneShot];
	} [inscriptedCover unlockFocus];
	
	return [self albumCaseWithCover:inscriptedCover ofSkinSize:skinSize];
}

- (NSImage*)albumCaseWithCover:(NSImage*)coverImage ofSkinSize:(NSString*)skinSize {
	NSDictionary* caseDescription = [self caseDescriptionOfSkinSize:skinSize];
	
	if(!caseDescription) {
		// TODO
		return coverImage;
	}
	
	if(!coverImage) {
		return [caseDescription valueForKey:SkinEmptyCaseImageKey];
	}
	
//	NSLog(@"%@ of %@", [self identifier], skinSize);
	
	// Make a new case based on our case description
	NSSize coverImageSize = [coverImage size];

	NSSize caseSize = [[caseDescription valueForKey:SkinCaseSizeKey] sizeValue];
	NSRect coverImageFrame = [[caseDescription valueForKey:SkinCoverFrameKey] rectValue];
	
	NSImage* caseImage = [caseDescription valueForKey:SkinCaseImageKey];
	
	NSImage* image = [[NSImage alloc] initWithSize:caseSize];
	
	[image lockFocus]; {
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
		
		CGFloat widthAspectRatio = coverImageSize.width / coverImageSize.height;
		CGFloat heightAspectRatio = coverImageSize.height / coverImageSize.width;
		
		if(widthAspectRatio > heightAspectRatio) {
			heightAspectRatio = 1.0;
		} else {
			widthAspectRatio = 1.0;
		}

		[NSGraphicsContext saveGraphicsState]; {
			NSRect imageRect = NSMakeRect(
				NSMinX(coverImageFrame), NSMinY(coverImageFrame),
				NSWidth(coverImageFrame) * widthAspectRatio, NSHeight(coverImageFrame) * heightAspectRatio);
			imageRect.origin = NSMakePoint(
				NSMidX(coverImageFrame) - NSWidth(imageRect) * 0.5,
				NSMidY(coverImageFrame) - NSHeight(imageRect) * 0.5);

			NSImage* maskImage = [caseDescription objectForKey:SkinCoverMaskKey];
			
			if(!maskImage) {
				NSRectClip(coverImageFrame);
			}
			
			[coverImage drawInRect:imageRect
				fromRect:NSZeroRect
				operation:NSCompositeCopy
				fraction:1.0];

			if(maskImage) {
				[maskImage drawInRect:NSMakeRect(0.0, 0.0, caseSize.width, caseSize.height) fromRect:NSZeroRect operation:NSCompositeDestinationAtop fraction:1.0];
			}
		} [NSGraphicsContext restoreGraphicsState];
		
		// Draw the case over the artwork
		[caseImage drawInRect:NSMakeRect(0.0, 0.0, caseSize.width, caseSize.height)
			fromRect:NSZeroRect
			operation:NSCompositeSourceOver
			fraction:1.0];
	} [image unlockFocus];
	
	return image;
}

- (NSDictionary*)_caseDescriptionForKey:(NSString*)key {
	NSDictionary* caseInfo = [_attributes valueForKey:key];
	
	if(!caseInfo) {
		return nil;
	}
	
	NSMutableDictionary* caseDescription = [NSMutableDictionary dictionary];
	
	// Read in the case image
	NSString* caseImagePath = [caseInfo objectForKey:@"caseImage"];
	caseImagePath = IsEmpty(caseImagePath) ? nil : [_path stringByAppendingPathComponent:caseImagePath];
	
	if(caseImagePath) {
		NSImage* caseImage = [[NSImage alloc] initByReferencingFile:caseImagePath];
		[caseDescription setObject:caseImage forKey:SkinCaseImageKey];
	}
	
	// Read in the empty case image
	NSString* emptyCaseImagePath = [caseInfo objectForKey:@"emptyCaseImage"];
	emptyCaseImagePath = IsEmpty(emptyCaseImagePath) ? nil : [_path stringByAppendingPathComponent:emptyCaseImagePath];
	
	if(emptyCaseImagePath) {
		NSImage* emptyCaseImage = [[NSImage alloc] initByReferencingFile:emptyCaseImagePath];
		[caseDescription setObject:emptyCaseImage forKey:SkinEmptyCaseImageKey];
	}
	
	// Read the cover mask image
	NSString* coverMaskPath = [caseInfo objectForKey:@"coverMask"];
	coverMaskPath = IsEmpty(coverMaskPath) ? nil : [_path stringByAppendingPathComponent:coverMaskPath];
	
	if(coverMaskPath) {
		NSImage* coverMaskImage = [[NSImage alloc] initByReferencingFile:coverMaskPath];
		[caseDescription setObject:coverMaskImage forKey:SkinCoverMaskKey];
	}

	// Read in the cover frame
	NSRect coverFrame = NSRectFromString([caseInfo objectForKey:@"coverFrame"]);
	[caseDescription setObject:[NSValue valueWithRect:coverFrame] forKey:SkinCoverFrameKey];
	
	// Read in the case size
	NSSize caseSize = NSSizeFromString([caseInfo objectForKey:@"size"]);
	[caseDescription setObject:[NSValue valueWithSize:caseSize] forKey:SkinCaseSizeKey];
	
	// Read in the alignment rect
	NSString* alignmentRectString = [caseInfo objectForKey:@"alignmentRect"];
	
	if(IsEmpty(alignmentRectString)) {
		[caseDescription setObject:[NSValue valueWithRect:NSZeroRect] forKey:SkinCaseAlignmentRectKey];
	} else {
		NSRect alignmentRect = NSRectFromString(alignmentRectString);
		[caseDescription setObject:[NSValue valueWithRect:alignmentRect] forKey:SkinCaseAlignmentRectKey];
	}
	
	return caseDescription;
}

@end
