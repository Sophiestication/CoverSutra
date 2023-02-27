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

#import "WindowController.h"

@interface WindowController(Private)

- (void)_updateFadeAnimation;
- (void)_updateFadeAnimation:(NSTimer*)timer;

- (void)_orderOut:(id)sender;

@end

@implementation WindowController

@dynamic visible;

- (id)initWithWindow:(NSWindow*)window {
	if(![super initWithWindow:window]) {
		return nil;
	}
	
	_orderingOut = NO;
	
	return self;
}

- (BOOL)isVisible {
	if([self isWindowLoaded]) {
		return ![self isOrderingOut] && [[self window] isVisible];
	}
	
	return NO;
}

- (void)orderFront:(id)sender animate:(BOOL)animate {
	if(animate) {
		_orderingOut = NO;
		[self _updateFadeAnimation];
	}
	
	[[self window] orderFront:sender];
}

- (void)orderOut:(id)sender animate:(BOOL)animate {
	if(animate) {
		_orderingOut = YES;
		[self _updateFadeAnimation];
	} else {
		[[self window] orderOut:sender];
	}
}

- (BOOL)isOrderingOut {
	return _orderingOut;
}

- (float)animationOrderInTime {
	return 0.25;
}

- (float)animationOrderOutTime {
	return 0.5;
}

@end

@implementation WindowController(Private)

- (void)_updateFadeAnimation {
	if(!_orderOutTimer) {
		float animationTime = [self isOrderingOut] ? 
			[self animationOrderOutTime] :
			[self animationOrderInTime];
		
		_orderOutTimer = [NSTimer scheduledTimerWithTimeInterval:(animationTime / 10.0)
			target:self
			selector:@selector(_updateFadeAnimation:)
			userInfo:nil
			repeats:YES];
			
//		[[NSRunLoop currentRunLoop] addTimer:_orderOutTimer forMode:NSDefaultRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:_orderOutTimer forMode:NSEventTrackingRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:_orderOutTimer forMode:NSModalPanelRunLoopMode];
	}
}

- (void)_updateFadeAnimation:(NSTimer*)timer {
	NSWindow* window = [self window];
	float alphaValue = [window alphaValue];
	
	if(_orderingOut) {
		alphaValue -= 0.1;
		
		if(alphaValue <= 0.0) {
			[_orderOutTimer invalidate], _orderOutTimer = nil;
			
			[window setAlphaValue:0.0];
			[self _orderOut:timer];
		}
	} else {
		alphaValue += 0.1;
		
		if(alphaValue >= 1.0) {
			[_orderOutTimer invalidate], _orderOutTimer = nil;
			alphaValue = 1.0;
		}
	}

	[window setAlphaValue:alphaValue];
}

- (void)_orderOut:(id)sender {
	_orderingOut = NO;
	[[self window] orderOut:sender];
}

@end
