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

#import "SCBezelController.h"
#import "SCBezelController+Private.h"

#import "SCAlertBezelViewController.h"
#import "SCSoundVolumeBezelViewController.h"
#import "SCRatingBezelViewController.h"

#import "SCBezelView.h"
#import "SCBezelImageView.h"

#import "ApplicationWindowController.h"
#import "CoverSutra.h"

#import "Utilities.h"

#import <QuartzCore/QuartzCore.h>

@implementation SCBezelController

@synthesize visible = _visible;
@synthesize enabled = _enabled;
@synthesize window = _window;
@synthesize bezelView = _bezelView;
@dynamic selectedViewController;

#pragma mark -
#pragma mark Construction & Destruction

- (id)init {
	if((self = [super init])) {
		[self initIvars];
		[self initObservers];
	}
	
	return self;
}

- (void)dealloc {
	self.selectedViewController = nil;
	self.window.delegate = nil;
}

#pragma mark -
#pragma mark Singleton

+ (SCBezelController*)sharedController {
	static dispatch_once_t once;
    static __strong SCBezelController* sharedBezelController_;
	
    dispatch_once(&once, ^{
		sharedBezelController_ = [[self alloc] init];
	});

    return sharedBezelController_;
}

#pragma mark -
#pragma mark SCBezelController

- (void)orderFront:(id)sender {
	_shouldOrderFront = YES;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self
		selector:@selector(orderOut:)
		object:self];
	
	[self loadWindowIfNeeded];
	
	NSWindow* window = self.window;
	
	[[NSWindow class]
		cancelPreviousPerformRequestsWithTarget:window
		selector:@selector(orderOut:)
		object:self];
	
	if(![window isOnActiveSpace]) {
		_needsLayout = YES;
	}
	
	// Layout and position the window
	[self layoutIfNeeded];
	
	// Fade it in
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"alphaValue"]; 

	animation.duration = 0.2;
	animation.delegate = self;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	NSDictionary* animations = [NSDictionary dictionaryWithObjectsAndKeys:
		animation, @"alphaValue",
		nil];
	[[self window] setAnimations:animations];

	[[window animator] setAlphaValue:1.0];
	
	// Mark it as visible
	self.visible = YES;
}

- (void)orderOut:(id)sender {
	_shouldOrderFront = NO;
	self.visible = NO;
	
	CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"alphaValue"]; 

	animation.duration = 1.0;
	animation.delegate = self;
	animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
	
	NSDictionary* animations = [NSDictionary dictionaryWithObjectsAndKeys:
		animation, @"alphaValue",
		nil];
	[[self window] setAnimations:animations];

	[[[self window] animator] setAlphaValue:0.0];
}

- (void)orderOutImmediately:(id)sender {
	self.selectedViewController = nil;
	
	[[self window] orderOut:sender];
	self.visible = NO;
	
	_needsLayout = YES;
}

- (void)scheduleOrderOut:(id)sender {
	static const NSTimeInterval delay = 2.5;
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self
		selector:@selector(orderOut:)
		object:self];
	[self performSelector:@selector(orderOut:)
		withObject:self
		afterDelay:delay];
}

#pragma mark -
#pragma mark NSWindowDelegate

- (void)windowDidChangeScreen:(NSNotification*)notification {
	[self layout];
}

- (void)windowDidChangeScreenProfile:(NSNotification*)notification {
	_needsLayout = YES;
}

- (void)windowDidUpdate:(NSNotification*)notification {
	[self layoutIfNeeded];
}

#pragma mark -
#pragma mark CAAnimationDelegate

- (void)animationDidStart:(CAAnimation*)animation {
	if(_shouldOrderFront) {
		[[self window] orderFrontRegardless];
	}
}

- (void)animationDidStop:(CAAnimation*)animation finished:(BOOL)finished {
	if(finished && !_shouldOrderFront) {
		[self orderOutImmediately:animation];
	}
}

#pragma mark -
#pragma mark Private

+ (NSSize)bezelSize {
	return NSMakeSize(211.0, 206.0);
}

- (void)initIvars {
	self.visible = NO;
	
	self.enabled = [[NSUserDefaults standardUserDefaults]
		boolForKey:@"shortcutBezelShown"];

	_needsLayout = YES;
	_shouldOrderFront = NO;
}

- (void)initObservers {
}

- (void)loadWindowIfNeeded {
	if(!self.window) {
		[self loadWindow];
	}
}

- (void)loadWindow {
	NSSize bezelSize = [[self class] bezelSize];
	NSWindow* window = [[NSPanel alloc]
		initWithContentRect:NSMakeRect(0.0, 0.0, bezelSize.width, bezelSize.height)
		styleMask:NSBorderlessWindowMask|NSNonactivatingPanelMask|NSHUDWindowMask
		backing:NSBackingStoreBuffered
		defer:YES];
	
	[window setDelegate:self];
	
	[window setOpaque:NO];
	[window setBackgroundColor:[NSColor clearColor]];
	[window setAlphaValue:0.0];
	[window setHasShadow:NO];
	
	[window useOptimizedDrawing:YES];
	[window setAutodisplay:YES];

	[window setLevel:NSScreenSaverWindowLevel];
	[window setHidesOnDeactivate:NO];
	[window setCanHide:NO];
	
	[window setIgnoresMouseEvents:YES];
	[window setMovable:NO];
	
	[window setCollectionBehavior:NSWindowCollectionBehaviorIgnoresCycle|NSWindowCollectionBehaviorCanJoinAllSpaces|NSWindowCollectionBehaviorStationary|NSWindowCollectionBehaviorFullScreenAuxiliary];

	// [window setOneShot:YES];
	// [window setDisplaysWhenScreenProfileChanges:YES];
	
	self.window = window;
	
	NSRect bezelViewRect = NSMakeRect(0.0, 0.0, bezelSize.width, bezelSize.height);
	SCBezelView* bezelView = [[SCBezelView alloc] initWithFrame:bezelViewRect];

	NSNumber* bezelAlphaValue = [[NSUserDefaults standardUserDefaults]
		objectForKey:@"bezelAlphaValue"];
				
	if(bezelAlphaValue) {
		bezelView.backgroundColor = [NSColor colorWithCalibratedWhite:0.0 alpha:[bezelAlphaValue floatValue]];
	}

//	bezelView.wantsLayer = YES;
	
	self.bezelView = bezelView;
	[window setContentView:bezelView];
}

- (void)layoutIfNeeded {
	if(_needsLayout) {
		[self layout];
	}
}

- (void)layout {
	_needsLayout = NO;
	
	[self loadWindowIfNeeded];
	
	NSWindow* window = self.window;
	
	NSRect screenRect = [[window screen] frame];
	NSRect windowRect = [window frame];
	
	NSPoint newOrigin = NSMakePoint(
		floorf(NSMidX(screenRect) - NSWidth(windowRect) * 0.5),
		floorf(NSHeight(windowRect) * (1.0 - 1.0 / 3.0) + 3.0)); // + 3px to match the system bezel

	[window setFrameOrigin:newOrigin];
}

- (BOOL)canOrderFrontShortcutBezel:(id)sender; {
	return
		[self isEnabled] &&
		![[[CoverSutra self] applicationWindowController] isVisible];
}

- (id)orderFrontBezelOfClassIfNeeded:(Class)viewControllerClass sender:(id)sender {
	if([[self selectedViewController] isKindOfClass:viewControllerClass]) {
		[self orderFront:sender];
		return self.selectedViewController;
	}
	
	id viewController = [viewControllerClass viewController];
	
	if(viewController) {
		self.selectedViewController = viewController;
		[self orderFront:sender];
	}
	
	return viewController;
}

- (NSViewController*)selectedViewController {
	return _selectedViewController;
}

- (void)setSelectedViewController:(NSViewController*)selectedViewController {
	if(selectedViewController != self.selectedViewController) {
//		NSLog(@"Bezel in: %@ out: %@", NSStringFromClass([_selectedViewController class]), NSStringFromClass([selectedViewController class]));
		
		if(selectedViewController) {
			[self loadWindowIfNeeded];
		}

		NSView* currentView = self.selectedViewController.view;
		NSView* newView = selectedViewController.view;
		
		NSView* parentView = [[self window] isVisible] ?
			[[self bezelView] animator] :
			[self bezelView];

		newView.frame = self.bezelView.bounds;

		if(!newView) {
			[currentView removeFromSuperview];
		} else if(currentView) {
			[parentView replaceSubview:currentView with:newView];
		} else {
			[parentView addSubview:newView];
		}
		
		[_selectedViewController setView:nil];

		_selectedViewController = selectedViewController;
	}
}

@end
