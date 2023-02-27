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

#import "PreferencesWindowController+Skin.h"

#import "MusicLibraryTrack.h"
#import "Skin.h"

#import "SkinController.h"
#import "NowPlayingController.h"

#import "CoverSutra.h"

@implementation PreferencesWindowController(Skin)

- (void)_initSkinPreferences {	
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_refreshSkinPreferences)
		name:PlayerDidChangeTrackNotification
		object:nil];
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_refreshSkinPreferences)
		name:PlayerDidChangeCoverNotification
		object:nil];

	[jewelboxing setBordered:NO];
	[jewelcase setBordered:NO];
	[vinyl setBordered:NO];
	
	[self _refreshSkinPreferences];
}

- (void)_refreshSkinPreferences {
	NSImage* coverImage = [[[CoverSutra self] nowPlayingController] coverImage];
	MusicLibraryTrack* track = [[[CoverSutra self] nowPlayingController] track];
	
	// Jewel Boxing Case
	Skin* skin = [[[CoverSutra self] skinController] jewelboxingSkin];
	
	if(coverImage) {
		[jewelboxing setImage:[skin albumCaseWithCover:coverImage ofSkinSize:MediumSkinSize]];
	} else {
		[jewelboxing setImage:[skin albumCaseWithTrack:track ofSkinSize:MediumSkinSize]];
	}
	
	// Jewel Case
	skin = [[[CoverSutra self] skinController] jewelcaseSkin];
	
	if(coverImage) {
		[jewelcase setImage:[skin albumCaseWithCover:coverImage ofSkinSize:MediumSkinSize]];
	} else {
		[jewelcase setImage:[skin albumCaseWithTrack:track ofSkinSize:MediumSkinSize]];
	}
	
	// Vinyl
	skin = [[[CoverSutra self] skinController] vinylSkin];
	
	if(coverImage) {
		[vinyl setImage:[skin albumCaseWithCover:coverImage ofSkinSize:MediumSkinSize]];
	} else {
		[vinyl setImage:[skin albumCaseWithTrack:track ofSkinSize:MediumSkinSize]];
	}
}

- (IBAction)selectSkin:(id)sender {
	SkinController* skinController = [[CoverSutra self] skinController];
	
	if(sender == jewelboxing) {
		[skinController setJewelboxingSelected:YES];
	}
	
	if(sender == jewelcase) {
		[skinController setJewelcaseSelected:YES];
	}
	
	if(sender == vinyl) {
		[skinController setVinylSelected:YES];
	}
}

@end
