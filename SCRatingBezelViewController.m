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

#import "SCRatingBezelViewController.h"

#import "SCBezelImageView.h"
#import "SCBezelTextField.h"

#import "StarRatingController.h"

#import "MusicLibraryTrack.h"

#import "NowPlayingController.h"

#import "CoverSutra.h"
#import "CoverSutra+Private.h"

#import "NSImage+Additions.h"

@implementation SCRatingBezelViewController

NSUInteger const SCRatingBezelViewControllerUpdateStarRatingAction = 1;
NSUInteger const SCRatingBezelViewControllerUpdateTrackTitleAction = 2;
NSUInteger const SCRatingBezelViewControllerUpdateAlbumCoverAction = 3;

+ (SCRatingBezelViewController*)viewController {
	return [[self alloc] initWithNibName:@"SCRatingBezelView" bundle:nil];
}

- (void)loadView {
	[super loadView];
	
	NSRect textLabelRect = textLabel.frame;
	textLabelRect.size.height += 8.0; // me might clip the shadow otherwise
	textLabelRect.origin.y -= 8.0;
	textLabel.frame = textLabelRect;
	
	[[CoverSutra self]
		addObserver:self
		forKeyPath:@"currentRatingController.rating"
		options:0
		context:(void*)SCRatingBezelViewControllerUpdateStarRatingAction];
	[[CoverSutra self]
		addObserver:self
		forKeyPath:@"currentRatingController.ratingComputed"
		options:0
		context:(void*)SCRatingBezelViewControllerUpdateStarRatingAction];
	[[CoverSutra self]
		addObserver:self
		forKeyPath:@"currentRatingController.albumRating"
		options:0
		context:(void*)SCRatingBezelViewControllerUpdateStarRatingAction];
	[[CoverSutra self]
		addObserver:self
		forKeyPath:@"currentRatingController.albumRatingComputed"
		options:0
		context:(void*)SCRatingBezelViewControllerUpdateStarRatingAction];
	
	[[CoverSutra self]
		addObserver:self
		forKeyPath:@"currentRatingController.track.displayName"
		options:0
		context:(void*)SCRatingBezelViewControllerUpdateTrackTitleAction];
	[[CoverSutra self]
		addObserver:self
		forKeyPath:@"nowPlayingController.track.displayName"
		options:0
		context:(void*)SCRatingBezelViewControllerUpdateTrackTitleAction];
		
	[[CoverSutra self]
		addObserver:self
		forKeyPath:@"nowPlayingController.coverImage"
		options:0
		context:(void*)SCRatingBezelViewControllerUpdateAlbumCoverAction];
		
	[self updateStarRating];
	[self updateTrackTitle];
	[self updateAlbumCover];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	
	[[CoverSutra self] removeObserver:self forKeyPath:@"currentRatingController.rating"];
	[[CoverSutra self] removeObserver:self forKeyPath:@"currentRatingController.ratingComputed"];
	[[CoverSutra self] removeObserver:self forKeyPath:@"currentRatingController.albumRating"];
	[[CoverSutra self] removeObserver:self forKeyPath:@"currentRatingController.albumRatingComputed"];
	[[CoverSutra self] removeObserver:self forKeyPath:@"currentRatingController.track.displayName"];
	[[CoverSutra self] removeObserver:self forKeyPath:@"nowPlayingController.track.displayName"];
	[[CoverSutra self] removeObserver:self forKeyPath:@"nowPlayingController.coverImage"];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
	NSUInteger action = (NSUInteger)context;
	
	if(action == SCRatingBezelViewControllerUpdateStarRatingAction) {
		[self updateStarRating];
	}
	
	if(action == SCRatingBezelViewControllerUpdateTrackTitleAction) {
		[self updateTrackTitle];
	}
	
	if(action == SCRatingBezelViewControllerUpdateAlbumCoverAction) {
		[self updateAlbumCover];
	}
	
	
//	if(context) {
//		SEL action = (SEL)context;
//		[self performSelector:action withObject:keyPath];
//	}
}

- (void)updateStarRating {
	NSInteger rating = 0;
	BOOL ratingComputed = NO;
	
	StarRatingController* starRatingController = [[CoverSutra self] currentRatingController];
	
	if(starRatingController) {
		rating = starRatingController.rating;
		ratingComputed = starRatingController.ratingComputed;
	} else {
		return; // Just do nothing for now
		
		MusicLibraryTrack* track = [[[CoverSutra self] nowPlayingController] track];
		
		rating = [track normalizedRating];
		ratingComputed = [track isRatingComputed];
	}
	
	NSImage* starImage = ratingComputed ?
		[NSImage templateImageNamed:@"computedStarRatingTemplate"] :
		[NSImage templateImageNamed:@"starRatingTemplate"];
	NSImage* dotImage = starImage; // [NSImage templateImageNamed:@"starRatingDotTemplate"];
	
	// 1 star
	ratingImage1.image = rating >= 20 ?
		starImage :
		dotImage;
	ratingImage1.enabled = rating >= 20;
	
	// 2 stars
	ratingImage2.image = rating >= 40 ?
		starImage :
		dotImage;
	ratingImage2.enabled = rating >= 40;
	
	// 3 stars
	ratingImage3.image = rating >= 60 ?
		starImage :
		dotImage;
	ratingImage3.enabled = rating >= 60;

	// 4 stars
	ratingImage4.image = rating >= 80 ?
		starImage :
		dotImage;
	ratingImage4.enabled = rating >= 80;
	
	// 5 stars
	ratingImage5.image = rating >= 100 ?
		starImage :
		dotImage;
	ratingImage5.enabled = rating >= 100;
}

- (void)updateTrackTitle {
	StarRatingController* starRatingController = [[CoverSutra self] currentRatingController];
	MusicLibraryTrack* track = nil;
	
	if(starRatingController) {
		track = starRatingController.track;
	} else {
		return; // Just do nothing for now
		
		track = [[[CoverSutra self] nowPlayingController] track];
	}
	
	textLabel.text = track.displayName;
}

- (void)updateAlbumCover {
	StarRatingController* starRatingController = [[CoverSutra self] currentRatingController];
	
	if(!starRatingController) {
		return; // Just do nothing for now
	}
	
	if([[starRatingController track] isEqual: [[[CoverSutra self] nowPlayingController] track]]) {
		coverView.image = [[[CoverSutra self] nowPlayingController] smallAlbumCaseImage];
	}
}

@end
