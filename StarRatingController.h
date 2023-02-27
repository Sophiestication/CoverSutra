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

// Several star rating value identifiers
const NSInteger UnratedRating;
const NSInteger HalfStarRating;
const NSInteger OneStarRating;
const NSInteger OneAndAHalfStarsRating;
const NSInteger TwoStarsRating;
const NSInteger TwoAndAHalfStarsRating;
const NSInteger ThreeStarsRating;
const NSInteger ThreeAndAHalfStarsRating;
const NSInteger FourStarsRating;
const NSInteger FourAndAHalfStarsRating;
const NSInteger FiveStarsRating;

@interface StarRatingController : NSObject {
@private
	MusicLibraryTrack* _track;
}

- (id)initWithTrack:(MusicLibraryTrack*)track;

@property(readwrite, strong) MusicLibraryTrack* track;

@property(readwrite) NSInteger rating;
@property(readonly, getter=isRatingComputed) BOOL ratingComputed;

@property(readwrite) NSInteger albumRating;
@property(readonly, getter=isAlbumRatingComputed) BOOL albumRatingComputed;

- (void)increaseRating;
- (void)decreaseRating;

- (void)halfIncreaseRating;
- (void)halfDecreaseRating;

- (void)commit;
- (void)scheduleCommit;

@end
