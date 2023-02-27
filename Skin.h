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

@class MusicLibraryTrack;

extern NSString* const SkinCaseImageKey;
extern NSString* const SkinEmptyCaseImageKey;
extern NSString* const SkinCaseSizeKey;
extern NSString* const SkinCoverFrameKey;
extern NSString* const SkinCaseAlignmentRectKey;
extern NSString* const SkinCoverMaskKey;

extern NSString* const ExtraSmallSkinSize;
extern NSString* const SmallSkinSize;
extern NSString* const MediumSkinSize;
extern NSString* const LargeSkinSize;

@interface Skin : NSObject {
@private
	id _path;
	id _attributes;
	NSMutableDictionary* _caseDescriptions;
}

+ (Skin*)skinWithContentsOfFile:(NSString*)skinFile;

- (id)initWithContentsOfFile:(NSString*)skinFile;

@property(readonly, strong) id identifier;

- (NSDictionary*)caseDescriptionOfSkinSize:(NSString*)skinSize;

- (NSImage*)albumCaseWithTrack:(MusicLibraryTrack*)track ofSkinSize:(NSString*)skinSize;
- (NSImage*)albumCaseWithCover:(NSImage*)coverImage ofSkinSize:(NSString*)skinSize;

@end
