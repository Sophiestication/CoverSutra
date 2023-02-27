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

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

/*!
    @category	 NSImage(CoverSutraAdditions)
    @abstract    (brief description)
    @discussion  (comprehensive description)
*/
@interface NSImage(Additions)

+ (NSImage*)templateImageNamed:(NSString*)imageName;

+ (NSImage*)coverForArtist:(NSString*)artist album:(NSString*)album;

- (void)drawFlippedInRect:(NSRect)rect fromRect:(NSRect)sourceRect operation:(NSCompositingOperation)operation fraction:(CGFloat)delta;
- (void)drawFlippedInRect:(NSRect)rect fromRect:(NSRect)sourceRect operation:(NSCompositingOperation)operation;
- (void)drawFlippedInRect:(NSRect)rect operation:(NSCompositingOperation)operation fraction:(CGFloat)delta;
- (void)drawFlippedInRect:(NSRect)rect operation:(NSCompositingOperation)operation;

- (NSBitmapImageRep*)bitmapImageRep;

- (CGImageRef)CGImage;
- (CGImageRef)CGImageForUserSpaceScaleFactor:(CGFloat)userSpaceScaleFactor;

- (CIImage*)CIImage;

@end

@interface NSImage(SnowLeopardAdditions)

- (CGImageRef)CGImageForProposedRect:(NSRect *)proposedDestRect context:(NSGraphicsContext *)referenceContext hints:(NSDictionary *)hints;

@end

/* Various template images
 */
extern NSString* const ImageNameAlertTemplate;
extern NSString* const ImageNameAdvancedTemplate;

extern NSString* const ImageNamePlayTemplate;
extern NSString* const ImageNamePauseTemplate;
extern NSString* const ImageNameFastForwardTemplate;
extern NSString* const ImageNameRewindTemplate;
extern NSString* const ImageNameStopTemplate;

extern NSString* const ImageNameShuffleTemplate;
extern NSString* const ImageNameShuffleOffTemplate;

extern NSString* const ImageNameRepeatModeOffTemplate;
extern NSString* const ImageNameRepeatModeAllTemplate;
extern NSString* const ImageNameRepeatModeOneTemplate;

extern NSString* const ImageNameMinSoundVolumeTemplate;
extern NSString* const ImageNameMaxSoundVolumeTemplate;
extern NSString* const ImageNameMuteSoundVolumeTemplate;

extern NSString* const ImageNamePlayerTemplate;
