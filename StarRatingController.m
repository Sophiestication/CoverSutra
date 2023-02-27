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

#import "StarRatingController.h"
#import "StarRatingController+Private.h"

#import "MusicLibraryTrack.h"
#import "MusicLibraryTrack+Scripting.h"
#import "MusicLibraryTrack+Private.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "CoverSutra.h"
#import "CoverSutra+Private.h"

const NSInteger UnratedRating = 0;
const NSInteger HalfStarRating = 10;
const NSInteger OneStarRating = 20;
const NSInteger OneAndAHalfStarsRating = 30;
const NSInteger TwoStarsRating = 40;
const NSInteger TwoAndAHalfStarsRating = 50;
const NSInteger ThreeStarsRating = 60;
const NSInteger ThreeAndAHalfStarsRating = 70;
const NSInteger FourStarsRating = 80;
const NSInteger FourAndAHalfStarsRating = 90;
const NSInteger FiveStarsRating = 100;

@implementation StarRatingController

+ (NSSet*)keyPathsForValuesAffectingRating { return [NSSet setWithObject:@"track"]; }
+ (NSSet*)keyPathsForValuesAffectingRatingComputed { return [NSSet setWithObjects:@"track", @"rating", nil]; }
+ (NSSet*)keyPathsForValuesAffectingAlbumRating { return [NSSet setWithObject:@"track"]; }
+ (NSSet*)keyPathsForValuesAffectingAlbumRatingComputed { return [NSSet setWithObjects:@"track", @"albumRating", nil]; }

@synthesize track = _track;
@dynamic rating;
@dynamic ratingComputed;
@dynamic albumRating;
@dynamic albumRatingComputed;
	
- (id)initWithTrack:(MusicLibraryTrack*)track {
	if(![super init]) {
		return nil;
	}
	
	self.track = track;
	
	return self;
}

- (NSInteger)rating {
	return self.track.rating;
}

- (void)setRating:(NSInteger)ratingValue {
	// Unschedule our delayed commit
	[self unscheduleCommit];
	
	// Update the user rating
	ratingValue = MIN(MAX(ratingValue, UnratedRating), FiveStarsRating);
	
	if(ratingValue == 0) {
		if(_track.albumRatingComputed) {
			_track.rating = ratingValue;
			_track.ratingComputed = NO;
			_track.rating = ratingValue;
			_track.ratingComputed = NO;
		} else {
			_track.rating = _track.albumRating;
			_track.ratingComputed = YES;
			_track.rating = _track.albumRating;
			_track.ratingComputed = YES;
		}
	} else {
		_track.rating = ratingValue;
		_track.ratingComputed = NO;
		_track.rating = ratingValue;
		_track.ratingComputed = NO;
	}
}

- (BOOL)isRatingComputed {
	return self.track.ratingComputed;
}

- (NSInteger)albumRating {
	return self.track.albumRating;
}

- (void)setAlbumRating:(NSInteger)albumRating {
	// Unschedule our delayed commit
	[self unscheduleCommit];
	
	// Update the album user rating
	albumRating = MIN(MAX(albumRating, UnratedRating), FiveStarsRating);

	_track.albumRating = albumRating;
	_track.albumRatingComputed = NO;
	_track.albumRating = albumRating;
	_track.albumRatingComputed = NO;
		
	if(_track.ratingComputed) {
		_track.rating = albumRating;
		_track.rating = albumRating;
	}
}

- (BOOL)isAlbumRatingComputed {
	return _track.albumRatingComputed;
}

- (void)increaseRating {
	NSInteger newRating = UnratedRating;
	
	if(self.ratingComputed) {
		newRating = OneStarRating;
	} else {
		newRating = self.rating + OneStarRating;
	}
	
	self.rating = newRating;
}

- (void)decreaseRating {
	NSInteger newRating = UnratedRating;
	
	if(!self.ratingComputed) {
		newRating = self.rating - OneStarRating;
	}
	
	self.rating = newRating;
}

- (void)halfIncreaseRating {
}

- (void)halfDecreaseRating {
}

- (void)commit {
	MusicLibraryTrack* track = self.track;
	iTunesTrack* scriptingObject = [[track sourceScriptingObjects] objectForKey:@"track"];
	
	scriptingObject.rating = track.ratingComputed ? 0 : track.rating;
	
	// This could be less assy...
	if([[CoverSutra self] currentRatingController] == self) {
		[[CoverSutra self] setCurrentRatingController:nil];
	}
}

- (void)scheduleCommit {
	[self unscheduleCommit];
	[self performSelector:@selector(commit:)
		withObject:self
		afterDelay:1.25];
}

- (void)unscheduleCommit {
	[[self class] cancelPreviousPerformRequestsWithTarget:self
		selector:@selector(commit:)
		object:self];
}

- (void)commit:(id)sender {
	[self commit];
}

@end
