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
	LastDotFMHandshake,
	LastDotFMNowPlayingNotification,
	LastDotFMSubmission;

extern NSString* const CSLastDotFMWillConnectNotification;
extern NSString* const CSLastDotFMDidConnectNotification;

extern NSString* const CSLastDotFMServiceKey;

extern unsigned const CSLastDotFMMaxNumberOfSubmissionableSongs;
extern unsigned const CSLastDotFMMaxSongCacheSize;
extern unsigned const CSLastDotFMMaxNumberOfNetworkFailures;

typedef enum _LastDotFMStatus {
	LastDotFMStatusOffline = 0,
	LastDotFMStatusOnline,
	LastDotFMStatusConnecting,
	LastDotFMStatusSubmitting,
	LastDotFMStatusFailedAuthentication,
	LastDotFMStatusBusy
} LastDotFMStatus;

/*!
    @class		 LastDotFMController
    @abstract    (brief description)
    @discussion  (comprehensive description)
*/
@interface LastDotFMController : NSObject {
@private
	BOOL _submissionsEnabled;
	BOOL _nowPlayingNotificationsEnabled;

	NSMutableArray* _recentSongs;
	
	LastDotFMHandshake* _handshake;
	LastDotFMStatus _status;
	
	LastDotFMSubmission* _submission;
	LastDotFMNowPlayingNotification* _nowPlayingNotification;
	
	NSString* _account;
	
	NSString* _challenge;
	NSString* _submissionURLString;
	NSString* _nowPlayingURLString;
	
	NSDate* _lastSubmissionDate;
	NSDate* _lastFailedSubmissionDate;
	NSDate* _nextPossibleSubmissionDate;
	
	NSString* _playerState;
	NSTimeInterval _playDuration;
	NSDate* _timeWhenSongStartedPlaying;
	
	unsigned _networkFailureCount;
}

- (BOOL)submissionsEnabled;
- (void)setSubmissionsEnabled:(BOOL)submissionsEnabled;

- (BOOL)nowPlayingNotificationsEnabled;
- (void)setNowPlayingNotificationsEnabled:(BOOL)nowPlayingNotificationsEnabled;

- (NSString*)account;
- (void)setAccount:(NSString*)account;

- (NSString*)password;
- (void)setPassword:(NSString*)password;

- (void)handshake;

- (NSDate*)lastSubmissionDate;
- (NSDate*)lastFailedSubmissionDate;

- (BOOL)isOnline;
- (BOOL)isConnecting;
- (BOOL)isSubmittingSongs;

- (NSString*)localizedStatus;

@end
