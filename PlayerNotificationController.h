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

@class
	CAAnimation,
	CATextLayer,
	MusicLibraryTrack;

@interface PlayerNotificationController : NSObject<NSWindowDelegate> {
@private
	__strong NSWindow* _window;
	CALayer* _contentLayer;
	
	CALayer* _coverImageLayer;
	CATextLayer* _titleLayer;
	CATextLayer* _artistLayer;
	CATextLayer* _albumLayer;
	
	CAAnimation* _orderFrontAnimation;
	CAAnimation* _orderOutAnimation;
	
	CAAnimation* _currentOrderOutAnimation;
	
	MusicLibraryTrack* _track;
	NSDate* _lastPlayerNotificationDate;
	
	BOOL _initialRefresh;
	BOOL _mouseInside;
	BOOL _notificationsShown;
	BOOL _notificationsShownOnAlbumChange;
	BOOL _needsLayout;
	BOOL _needsRefresh;
	BOOL _orderOutScheduled;
	BOOL _coverImageLayerNeedsRefresh;
	BOOL _textLayerNeedsRefresh;
	
	CGFloat _orderOutDelay;
}

@property(nonatomic, readonly, getter=isVisible) BOOL visible;

@property(nonatomic, readonly) BOOL notificationsShown;
@property(nonatomic, readonly) BOOL notificationsShownOnAlbumChange;

- (void)layout;
- (void)layoutIfNeeded;

- (void)refresh;
- (void)refreshIfNeeded;

- (void)orderFront:(id)sender;

- (void)orderOut:(id)sender;
- (void)scheduleOrderOut:(id)sender;

@end
