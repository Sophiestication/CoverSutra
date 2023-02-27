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

#import "PlayerNotificationController.h"
#import "PlayerNotificationController+Private.h"

#import "MusicLibraryTrack.h"

#import "NowPlayingController.h"

#import "PlaybackController.h"
#import "PlaybackController+Private.h"

#import "PlayerController.h"
#import "PlayerNotificationController.h"
#import "ApplicationWindowController.h"
#import "MusicSearchWindowController.h"

#import "StatusItemController.h"

#import "SCBezelController.h"

#import "CoverSutra.h"

#import "NSColor+Additions.h"
#import "NSImage+Additions.h"
#import "NSFont+Additions.h"
#import "NSString+Additions.h"
#import "NSUserDefaults+Additions.h"

#import "Utilities.h"

#import <QuartzCore/QuartzCore.h>

@implementation PlayerNotificationController

@dynamic visible;

@synthesize notificationsShown = _notificationsShown;
@synthesize notificationsShownOnAlbumChange = _notificationsShownOnAlbumChange;
@synthesize window = _window;
@synthesize contentLayer = _contentLayer;
@synthesize coverImageLayer = _coverImageLayer;
@synthesize titleLayer = _titleLayer;
@synthesize artistLayer = _artistLayer;
@synthesize albumLayer = _albumLayer;
@synthesize track = _track;
@synthesize lastPlayerNotificationDate = _lastPlayerNotificationDate;
@synthesize coverImageLayerNeedsRefresh = _coverImageLayerNeedsRefresh;
@synthesize textLayerNeedsRefresh = _textLayerNeedsRefresh;

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_initialRefresh = YES;
	_mouseInside = NO;
	_needsLayout = YES;
	_needsRefresh = YES;
	_orderOutScheduled = NO;
	_notificationsShown = YES;
	_notificationsShownOnAlbumChange = NO;
	
	_orderOutDelay = 3.0; // Wait for three seconds before ordering out
	
	self.lastPlayerNotificationDate = [NSDate date];
	
	[self initKeyValuObservers];
	
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(playerDidChangeTrack:)
		name:PlayerDidChangeTrackNotification
		object:nil];
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isVisible {
	if(_window && _contentLayer) {
		return [_window isVisible];
	}
	
	return NO;
}

- (void)layout {
	NSWindow* window = self.window;
	
	NSRect screenFrame = [[NSScreen mainScreen] frame];
	NSRect windowFrame = [window frame];

	NSRect statusItemWindowFrame = [(NSWindow*)[[CoverSutra self] valueForKeyPath:@"statusItemController.statusItem.view.window"] frame];
	
	NSPoint newOrigin = NSMakePoint(
		(NSMaxX(statusItemWindowFrame) - 14.0) - NSWidth(windowFrame) * 0.5,
		NSMaxY(screenFrame) - NSHeight(windowFrame) /* - NSHeight(statusItemWindowFrame) */ /* NSMinY(statusItemWindowFrame) - NSHeight(statusItemWindowFrame) - NSHeight(windowFrame) */);
	
	newOrigin.y += 3.0 * window.userSpaceScaleFactor; // The arrow in the popup should overlap a bit
	
	[window setFrameOrigin:newOrigin];
	
	if(![window isVisible]) {
		[window orderFrontRegardless];
	}

//	_needsLayout = NO; // We always want to relayout since the status item might change it's location quite often
}

- (void)layoutIfNeeded {
	if(_needsLayout) {
		[self layout];
	}
}

- (void)refresh {
	if(_initialRefresh) {
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	}

	MusicLibraryTrack* track = [[[CoverSutra self] nowPlayingController] track];
	
	if(track) {
		self.titleLayer.string = track.displayName;
		self.artistLayer.string = track.displayArtist;
		self.albumLayer.string = track.displayAlbum;
	}
	
//	self.titleLayer.hidden = !track;
//	self.artistLayer.hidden = !track;
//	self.albumLayer.hidden = !track;

	self.titleLayer.opacity = self.artistLayer.opacity = self.albumLayer.opacity = !track ?
		0.0 :
		1.0;
		
	self.coverImageLayer.opacity = 1.0;
	
	_needsRefresh = NO;
	self.textLayerNeedsRefresh = NO;
	
	if(_initialRefresh) {
		[CATransaction commit];
		_initialRefresh = NO;
	}
}

- (void)refreshIfNeeded {
	if((_needsRefresh || self.textLayerNeedsRefresh) && self.visible) {
		[self refresh];
	}
}

- (void)orderFront:(id)sender {
	/*MusicLibraryTrack* track = [[[CoverSutra self] nowPlayingController] track];
	
	NSUserNotification* notification = [[NSUserNotification alloc] init];
	
	notification.title = track.displayName;
	notification.subtitle = track.displayArtist;
	
	[[NSUserNotificationCenter defaultUserNotificationCenter] deliverNotification:notification];
	
	return; */
	
	// Show also our status item if needed
	if(![[[CoverSutra self] statusItemController] statusItemShown]) {
		[[[CoverSutra self] statusItemController] setStatusItemShown:YES];
	}
	
	// Cancel any scheduled order outs if needed
	_orderOutScheduled = NO;
		
	[[self class] cancelPreviousPerformRequestsWithTarget:self
		selector:@selector(orderOut:)
		object:nil];

	// Remove any previously added order animations
	[[self contentLayer] removeAnimationForKey:@"orderOutAnimation"];

	// Popup the window front if we're not visible
	if(![[self window] isVisible]) {
		[[self contentLayer] addAnimation:_orderFrontAnimation forKey:@"orderAnimation"];
	}
	
	self.contentLayer.hidden = NO;
	self.contentLayer.opacity = 1.0;
	
	[[self window] orderFrontRegardless];
	
	// Layout and position the window
	[self layoutIfNeeded];
	
	// Refresh if needed
	[self refreshIfNeeded];
}

- (void)orderOut:(id)sender {
	// Cancel any scheduled order outs
	_orderOutScheduled = NO;
	[[self class] cancelPreviousPerformRequestsWithTarget:self
		selector:@selector(orderOut:)
		object:nil];

	// Order content layer out
	if(!_currentOrderOutAnimation) {
		[[self contentLayer] addAnimation:_orderOutAnimation forKey:@"orderOutAnimation"];
	}
}

- (void)scheduleOrderOut:(id)sender {
	if(!_orderOutScheduled) {
		_orderOutScheduled = YES;
		
		[self performSelector:@selector(orderOut:)
			withObject:nil // This needs to be nil to cancel this selector in orderFront: if needed
			afterDelay:_orderOutDelay];
	}
}

// Private interface

- (NSWindow*)window {
	if(!_window) {
		// Make a new window for our bezel
		NSRect contentRect = NSMakeRect(
			0.0, 0.0,
			256.0, 80.0);
		NSRect windowFrame = NSInsetRect(contentRect, -32.0, -16.0);
		
		NSPanel* window = [[NSPanel alloc] initWithContentRect:windowFrame
			styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask|NSHUDWindowMask
			backing:NSBackingStoreBuffered
			defer:YES];
		
		[window setDelegate:self];
        
        [window setOpaque:NO];
        [window setBackgroundColor:[NSColor clearColor]];
        [window setAlphaValue:1.0];
        [window setHasShadow:NO];
        
        [window useOptimizedDrawing:YES];
        [window setAutodisplay:YES];
        
        [window setHidesOnDeactivate:NO];
        [window setCanHide:NO];
        
        [window setIgnoresMouseEvents:YES];
        [window setMovable:NO];
        
        [window setLevel:kCGStatusWindowLevel];
		[window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorTransient|NSWindowCollectionBehaviorFullScreenAuxiliary];
        
        [window setOneShot:YES];
        
        [window setDisplaysWhenScreenProfileChanges:YES];
        
		// Setup our root layer
		NSView* contentView = window.contentView;
		
		// Make our content layer
		CALayer* containerLayer = [CALayer layer];
		
		containerLayer.name = @"container";
		containerLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
		containerLayer.needsDisplayOnBoundsChange = YES;
		
		contentView.wantsLayer = YES;
		contentView.layer = containerLayer;
		_window = window;

		[self initAnimations];
		[self initLayers];
		[self initTrackingAreas];
	}
	
	return _window;
}

- (void)initLayers {
	CGFloat userSpaceScaleFactor = self.window.userSpaceScaleFactor;
	
	// Init content layer
	CALayer* contentLayer = [CALayer layer];
	
	contentLayer.name = @"content";
	contentLayer.delegate = self;
	contentLayer.needsDisplayOnBoundsChange = YES;
	[contentLayer setNeedsDisplay];

	contentLayer.bounds = CGRectMake(0.0, 0.0, 256.0 * userSpaceScaleFactor, 80.0 * userSpaceScaleFactor);
	contentLayer.layoutManager = [CAConstraintLayoutManager layoutManager];
	
	contentLayer.shadowOpacity = 1.0;
	contentLayer.shadowRadius = 4.0;
	contentLayer.shadowOffset = CGSizeMake(0.0, -2.0);

	contentLayer.hidden = NO;
	
	CGFloat margin = 32.0;
	
	[contentLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX offset:margin]];
	[contentLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"superlayer" attribute:kCAConstraintMaxX offset:-margin]];
	[contentLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinY relativeTo:@"superlayer" attribute:kCAConstraintMinY offset:0.0]];
	[contentLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY offset:-10.0]];
	
	self.contentLayer = contentLayer;
	[[[[self window] contentView] layer] addSublayer:contentLayer];
	
	// Make a new layer for our album cover
	CALayer* coverLayer = [CALayer layer];

	CGFloat coverLayerWidth = 48.0 * userSpaceScaleFactor;
	
	coverLayer.delegate = self;
	
	coverLayer.name = @"coverImage";
	coverLayer.bounds = CGRectMake(0.0, 0.0, coverLayerWidth, coverLayerWidth);
	
	coverLayer.opacity = 0.0;
	
	[coverLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX offset:16.0]];
	[coverLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:@"superlayer" attribute:kCAConstraintMidY offset:-6.0]];
	
	[coverLayer setNeedsDisplay];
	
	self.coverImageLayer = coverLayer;
	[contentLayer addSublayer:coverLayer];
	
	// Add the track title layer
	CATextLayer* titleLayer = [CATextLayer layer];
	
	titleLayer.name = @"title";
	
	titleLayer.font = (__bridge CFTypeRef)([NSFont notificationFontOfSize:-1]);
	titleLayer.fontSize = 13.0 * userSpaceScaleFactor;
	titleLayer.foregroundColor = CGColorGetConstantColor(kCGColorWhite);
	titleLayer.truncationMode = kCATruncationEnd;
	
	titleLayer.opacity = 0.0;
	
	titleLayer.shadowOpacity = 1.0;
	titleLayer.shadowRadius = 0.0;
	titleLayer.shadowOffset = CGSizeMake(0.0, 1.0);
	
	[titleLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"superlayer" attribute:kCAConstraintMinX offset:82.0]];
	[titleLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"superlayer" attribute:kCAConstraintMaxX offset:-8.0]];
	[titleLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"superlayer" attribute:kCAConstraintMaxY offset:-35.0]];
	
//	[titleLayer bind:@"string"
//		toObject:[CoverSutra self]
//		withKeyPath:@"nowPlayingController.track.displayName"
//		options:nil];
	
	self.titleLayer = titleLayer;
	[contentLayer addSublayer:titleLayer];

/*
	// Add follow link image layer
	CALayer* followLinkLayer = [CALayer layer];
	NSSize followLinkSize = NSMakeSize(12.0 * userSpaceScaleFactor, 12.0 * userSpaceScaleFactor);
	
	followLinkLayer.contentsGravity = kCAGravityResizeAspect;
	followLinkLayer.bounds = CGRectMake(0.0, 0.0, followLinkSize.width, followLinkSize.height);
	
	NSImage* followLinkImage = [NSImage imageNamed:NSImageNameFollowLinkFreestandingTemplate];
	[followLinkImage setSize:NSMakeSize(followLinkSize.width, followLinkSize.height)];
	followLinkLayer.contents = (id)[followLinkImage CGImage];
	
	[followLinkLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"title" attribute:kCAConstraintMaxX offset:0.0]];
	[followLinkLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY relativeTo:@"superlayer" attribute:kCAConstraintMidY]];
	
	[contentLayer addSublayer:followLinkLayer];
*/

	// Alternate text color
	CGColorRef alternateTextColor = CGColorCreateGenericGray(0.5, 1.0);

	// Add the artist layer
	CATextLayer* artistLayer = [CATextLayer layer];
	
	artistLayer.name = @"artist";
	
	artistLayer.font = (__bridge CFTypeRef)([NSFont notificationFontOfSize:-1]);
	artistLayer.fontSize = 11.0 * userSpaceScaleFactor;
	artistLayer.foregroundColor = alternateTextColor;
	artistLayer.truncationMode = kCATruncationEnd;
	
	artistLayer.opacity = 0.0;
	
	artistLayer.shadowOpacity = 1.0;
	artistLayer.shadowRadius = 0.0;
	artistLayer.shadowOffset = CGSizeMake(0.0, 1.0);
	
	[artistLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"title" attribute:kCAConstraintMinX]];
	[artistLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"title" attribute:kCAConstraintMaxX]];
	[artistLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"title" attribute:kCAConstraintMinY offset:-1.0]];
	
//	[artistLayer bind:@"string"
//		toObject:[CoverSutra self]
//		withKeyPath:@"nowPlayingController.track.displayArtist"
//		options:nil];
	
	self.artistLayer = artistLayer;
	[contentLayer addSublayer:artistLayer];
	
	// Add the album layer
	CATextLayer* albumLayer = [CATextLayer layer];
	
	albumLayer.name = @"album";
	
	albumLayer.font = (__bridge CFTypeRef)([NSFont notificationFontOfSize:-1]);
	albumLayer.fontSize = 11.0 * userSpaceScaleFactor;
	albumLayer.foregroundColor = alternateTextColor;
	albumLayer.truncationMode = kCATruncationEnd;
	
	albumLayer.opacity = 0.0;
	
	albumLayer.shadowOpacity = 1.0;
	albumLayer.shadowRadius = 0.0;
	albumLayer.shadowOffset = CGSizeMake(0.0, 1.0);
	
	[albumLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMinX relativeTo:@"artist" attribute:kCAConstraintMinX]];
	[albumLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxX relativeTo:@"artist" attribute:kCAConstraintMaxX]];
	[albumLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMaxY relativeTo:@"artist" attribute:kCAConstraintMinY offset:-1.0]];
	
	// Release the alternate text color
	CFRelease(alternateTextColor);
	
//	[albumLayer bind:@"string"
//		toObject:[CoverSutra self]
//		withKeyPath:@"nowPlayingController.track.displayAlbum"
//		options:nil];
	
	self.albumLayer = albumLayer;
	[contentLayer addSublayer:albumLayer];
}

- (void)initAnimations {
	CAKeyframeAnimation* orderFrontAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
	
	orderFrontAnimation.delegate = self;
	orderFrontAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.25], [NSNumber numberWithFloat:1.0], nil];
	orderFrontAnimation.keyTimes = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.8], [NSNumber numberWithFloat:1.0], nil];
	orderFrontAnimation.removedOnCompletion = NO;
	
	_orderFrontAnimation = orderFrontAnimation;

	CABasicAnimation* orderOutAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
	
	orderOutAnimation.toValue = [NSNumber numberWithFloat:0.0];
	orderOutAnimation.delegate = self;
	orderOutAnimation.duration = 2.0;
	orderOutAnimation.removedOnCompletion = NO;
	orderOutAnimation.fillMode = kCAFillModeBoth;
	
	_orderOutAnimation = orderOutAnimation;
}

- (void)initTrackingAreas {
	NSView* contentView = self.window.contentView;
	
	NSRect contentRect = contentView.bounds;
	contentRect = NSInsetRect(contentRect, 32.0, 16.0);
	contentRect = NSOffsetRect(contentRect, 0.0, -10.0);
	
	NSTrackingArea* trackingArea = [[NSTrackingArea alloc] initWithRect:contentRect
		options:NSTrackingMouseEnteredAndExited|NSTrackingActiveAlways
		owner:self
		userInfo:nil];
	
	[contentView addTrackingArea:trackingArea];
	
}

- (void)initKeyValuObservers {
	[[CoverSutra self] addObserver:self forKeyPath:@"nowPlayingController.extraSmallAlbumCaseImage" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
	
	[[CoverSutra self] addObserver:self forKeyPath:@"nowPlayingController.track.displayName" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
	[[CoverSutra self] addObserver:self forKeyPath:@"nowPlayingController.track.displayArtist" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
	[[CoverSutra self] addObserver:self forKeyPath:@"nowPlayingController.track.displayAlbum" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
	
	[[NSUserDefaultsController sharedUserDefaultsController]
		addObserver:self
	 	forKeyPath:@"values.displayPlayerNotifications"
	 	options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld|NSKeyValueObservingOptionInitial
	 	context:NULL];
}

// NSKeyValueObserving interface

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
	// Update user defaults if needed
	if(EqualStrings(keyPath, @"values.displayPlayerNotifications")) {
		NSInteger displayPlayerNotifications = [[[[NSUserDefaultsController sharedUserDefaultsController] values] valueForKey:@"displayPlayerNotifications"] integerValue];
		
		self.notificationsShown = displayPlayerNotifications != 0;
		self.notificationsShownOnAlbumChange = displayPlayerNotifications == 1;
	}
	
	// Check if the value changed
	if([[change objectForKey:NSKeyValueChangeKindKey] integerValue] == NSKeyValueChangeSetting) {
		if([[change objectForKey:NSKeyValueChangeNewKey] isEqual:[change objectForKey:NSKeyValueChangeOldKey]]) {
			return; // The values are equal, no need to refresh
		}
	}
	
	// Check cover image keypaths
	if(EqualStrings(keyPath, @"nowPlayingController.extraSmallAlbumCaseImage")) {
		[[self coverImageLayer] setNeedsDisplay];
	}
	
	// Check track details
	if(EqualStrings(keyPath, @"nowPlayingController.track.displayName") ||
	   EqualStrings(keyPath, @"nowPlayingController.track.displayArtist") ||
	   EqualStrings(keyPath, @"nowPlayingController.track.displayAlbum")) {
		self.textLayerNeedsRefresh = YES;
	}
	
	if([NSThread isMainThread]) {
		[self refreshIfNeeded];
	} else {
		[self performSelectorOnMainThread:@selector(refreshIfNeeded)
			withObject:nil
			waitUntilDone:NO];
	}
}

// Notification handler

- (void)playerDidChangeTrack:(NSNotification*)notification {
	// Check if we want notifications
	if(!self.notificationsShown) {
		self.track = [[notification userInfo] objectForKey:@"track"];
		return; // Nope...
	}
	
	// Order front notification if needed
	PlaybackController* playbackController = [[CoverSutra self] playbackController];
	MusicLibraryTrack* newTrack = [[notification userInfo] objectForKey:@"track"];
	
	BOOL shouldOrderFront = NO;
	
	if(!playbackController.shouldNotNotifyAboutTrackChanges) {
		NSTimeInterval intervalSinceNow = -[_lastPlayerNotificationDate timeIntervalSinceNow];

		if(!EqualTracks(_track, newTrack) && intervalSinceNow >= 1.0) {
			if(![[[CoverSutra self] applicationWindowController] isVisible] &&
			   ![[[CoverSutra self] musicSearchWindowController] isVisible] &&
			   ![[SCBezelController sharedController] isVisible] &&
			   ![[[CoverSutra self] playerController] iTunesIsFrontmost]) {
				if(self.notificationsShownOnAlbumChange && EqualAlbums(newTrack, self.track)) {
					// We do nothing here
				} else {				
					shouldOrderFront = YES;
				}
			}

			playbackController.shouldNotNotifyAboutTrackChanges = NO;
		}
	} else {
		playbackController.shouldNotNotifyAboutTrackChanges = NO;
	}
	
	// Keep the notification window a bit longer open as long the tracks are changed
	if(((shouldOrderFront && newTrack) || self.visible) && ![[SCBezelController sharedController] isVisible]) {
		[self orderFront:notification];
			
		if(!_mouseInside) {
			[self scheduleOrderOut:notification];
		}
	}

	self.track = newTrack;
	self.lastPlayerNotificationDate = [NSDate date];
	
	// Refresh if we're ordered front
	[self refreshIfNeeded];
}

// CALayer delegate interface

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)ctx {
	if(layer == self.contentLayer) {
		NSGraphicsContext* context = [NSGraphicsContext
			graphicsContextWithGraphicsPort:ctx
			flipped:NO];

		[NSGraphicsContext saveGraphicsState]; {
			[NSGraphicsContext setCurrentContext:context];
	 
			NSImage* backgroundImage = [NSImage imageNamed:@"playerNotification"];
			
			NSSize imageSize = backgroundImage.size;
			NSRect imageRect = NSRectFromCGRect(layer.bounds);
			
			NSPoint center = NSMakePoint(
				NSMidX(imageRect) - imageSize.width * 0.5, NSMidY(imageRect) - imageSize.height * 0.5);
			
			[backgroundImage drawAtPoint:center
				fromRect:NSZeroRect
				operation:NSCompositeSourceOver
				fraction:1.0];
		} [NSGraphicsContext restoreGraphicsState];
	}
	
	if(layer == self.coverImageLayer) {
		NSGraphicsContext* context = [NSGraphicsContext
			graphicsContextWithGraphicsPort:ctx
			flipped:NO];

		[NSGraphicsContext saveGraphicsState]; {
			[NSGraphicsContext setCurrentContext:context];
			
			[context setImageInterpolation:NSImageInterpolationHigh];
			[context setShouldAntialias:YES];
	 
			NSImage* coverImage = [[[CoverSutra self] nowPlayingController] extraSmallAlbumCaseImage];
			NSRect coverImageRect = NSRectFromCGRect(layer.bounds);
			
			[coverImage drawInRect:coverImageRect
				fromRect:NSZeroRect
				operation:NSCompositeSourceOver
				fraction:1.0];
		} [NSGraphicsContext restoreGraphicsState];
	}
}

// CAAnimation delegate interface

- (void)animationDidStart:(CAAnimation*)animation {
	if([[self contentLayer] animationForKey:@"orderOutAnimation"] == animation) {
		_currentOrderOutAnimation = animation;
	}
}

- (void)animationDidStop:(CAAnimation*)animation finished:(BOOL)finished {
	if(animation == _currentOrderOutAnimation) {
		_currentOrderOutAnimation = nil;
		
		if(finished) {
			[[self window] orderOut:animation];
		}
		
		// Hide the status item if needed
		NSNumber* statusItemShown = [[[NSUserDefaultsController sharedUserDefaultsController] values]
			valueForKey:@"statusItemShown"];
	
		if(!ToBoolean(statusItemShown)) {
			[[[CoverSutra self] statusItemController] setStatusItemShown:NO];
		}
	}
}

// NSResponder interface

- (void)mouseEntered:(NSEvent*)theEvent {
	if(self.visible) {
		[self orderFront:theEvent];
		self.contentLayer.shadowRadius = 6.0;
		
		_mouseInside = YES;
	}
}

- (void)mouseExited:(NSEvent*)theEvent {
	[self scheduleOrderOut:theEvent];
	self.contentLayer.shadowRadius = 4.0;
	_mouseInside = NO;
}

@end
