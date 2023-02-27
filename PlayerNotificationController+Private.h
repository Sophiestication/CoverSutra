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

@interface PlayerNotificationController()

@property(nonatomic, readonly, strong) NSWindow* window;

@property(nonatomic, strong) CALayer* contentLayer;
@property(nonatomic, strong) CALayer* coverImageLayer;
@property(nonatomic, strong) CATextLayer* titleLayer;
@property(nonatomic, strong) CATextLayer* artistLayer;
@property(nonatomic, strong) CATextLayer* albumLayer;

@property(nonatomic, strong) MusicLibraryTrack* track;
@property(nonatomic, strong) NSDate* lastPlayerNotificationDate;

@property(nonatomic, readwrite) BOOL notificationsShown;
@property(nonatomic, readwrite) BOOL notificationsShownOnAlbumChange;

@property BOOL coverImageLayerNeedsRefresh;
@property BOOL textLayerNeedsRefresh;

- (void)initLayers;
- (void)initAnimations;
- (void)initTrackingAreas;
- (void)initKeyValuObservers;

- (void)playerDidChangeTrack:(NSNotification*)notification;

@end
