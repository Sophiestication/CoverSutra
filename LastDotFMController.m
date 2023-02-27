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

#import "LastDotFMController.h"
#import "LastDotFMController+Private.h"

#import "LastDotFMHandshake.h"
#import "LastDotFMHandshake+Delegate.h"

#import "LastDotFMSubmission.h"
#import "LastDotFMSubmission+Delegate.h"

#import "NowPlayingController.h"

#import "Keychain.h"

#import "NSArray+Additions.h"
#import "NSString+MD5.h"

#import "CoverSutra.h"

#import "Utilities.h"

NSString* const CSLastDotFMWillConnectNotification = @"com.sophiestication.CoverSutra.lastDotFMWillConnect";
NSString* const CSLastDotFMDidConnectNotification = @"com.sophiestication.CoverSutra.lastDotFMDidConnect";

NSString* const CSLastDotFMServiceKey = @"Last.fm";

unsigned const CSLastDotFMMaxNumberOfSubmissionableSongs = 50;
unsigned const CSLastDotFMMaxSongCacheSize = 1;
unsigned const CSLastDotFMMaxNumberOfNetworkFailures = 3;

@implementation LastDotFMController

+ (NSSet*)keyPathsForValuesAffectingPassword {
	return [NSSet setWithObjects:
		@"account",
		nil];
}

+ (NSSet*)keyPathsForValuesAffectingLocalizedStatus {
	return [NSSet setWithObjects:
		@"account",
		@"status",
		@"lastSubmissionDate",
		@"lastFailedSubmissionDate",
		@"submissionsEnabled",
		@"lastFailure",
		nil];
}

- (id)init {
	if(![super init]) {
		return nil;
	}
	
	_networkFailureCount = 0;
	
	_status = LastDotFMStatusOffline;
	
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(playerDidChangeTrack:)
		name:PlayerDidChangeTrackNotification
		object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
		selector:@selector(playerDidRepeatTrack:)
		name:PlayerDidRepeatTrackNotification
		object:nil];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(_applicationWillTerminate:)
		name:NSApplicationWillTerminateNotification
		object:nil];
	
	id lastfm = [[NSUserDefaultsController sharedUserDefaultsController]
		valueForKeyPath:@"values.lastfm"];
	_recentSongs = [lastfm valueForKeyPath:@"recentSongs"];
	
	if(!_recentSongs) {
		_recentSongs = [[NSMutableArray alloc] init];
	}
	
	_account = [lastfm valueForKey:@"account"];
	
	BOOL submissionsEnabled = [[lastfm valueForKey:@"submissionsEnabled"] boolValue];
	[self setSubmissionsEnabled:submissionsEnabled];
	
	BOOL nowPlayingNotificationsEnabled = [[lastfm valueForKey:@"nowPlayingNotificationsEnabled"] boolValue];
	[self setNowPlayingNotificationsEnabled:nowPlayingNotificationsEnabled];
	
	// We like to use now playing notifications by default
	if(![lastfm valueForKey:@"nowPlayingNotificationsEnabled"]) {
		[self setNowPlayingNotificationsEnabled:YES];
	}
	
	NSDate* lastSubmissionDate = [lastfm valueForKey:@"lastSubmissionDate"];
	[self _setLastSubmissionDate:lastSubmissionDate];
	
	NSDate* lastFailedSubmissionDate = [lastfm valueForKey:@"lastFailedSubmissionDate"];
	[self _setLastFailedSubmissionDate:lastFailedSubmissionDate];

	_playDuration = 0;
	_timeWhenSongStartedPlaying = nil;
	
	[self bind:@"playerState"
		toObject:[CoverSutra self]
		withKeyPath:@"playbackController.playerState"
		options:nil];
	
	return self;
}

- (void)dealloc {
	[[CoverSutra self]
		removeObserver:self forKeyPath:@"nowPlayingController.track"];

	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[self _resetSubmission];
	[self _resetHandshake];	
}

- (BOOL)submissionsEnabled {
	return _submissionsEnabled;
}

- (void)setSubmissionsEnabled:(BOOL)submissionsEnabled {
	if(_submissionsEnabled != submissionsEnabled) {
//		[self willChangeValueForKey:@"submissionsEnabled"];
		_submissionsEnabled = submissionsEnabled;
//		[self didChangeValueForKey:@"submissionsEnabled"];
		
		if(submissionsEnabled) {
			[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(playerDidChangeTrack:)
				name:PlayerDidChangeTrackNotification
				object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:self
				selector:@selector(playerDidRepeatTrack:)
				name:PlayerDidRepeatTrackNotification
				object:nil];

			[self performSelector:@selector(_scheduleSubmission)
				withObject:nil
				afterDelay:0.5];
		} else {
			[NSObject cancelPreviousPerformRequestsWithTarget:self
				selector:@selector(_scheduleSubmission)
				object:nil];
			
			[[NSNotificationCenter defaultCenter]
				removeObserver:self
				name:PlayerDidRepeatTrackNotification
				object:nil];
			[[NSNotificationCenter defaultCenter]
				removeObserver:self
				name:PlayerDidChangeTrackNotification
				object:nil];
		}
	}
}

- (BOOL)nowPlayingNotificationsEnabled {
	return _nowPlayingNotificationsEnabled;
}

- (void)setNowPlayingNotificationsEnabled:(BOOL)nowPlayingNotificationsEnabled {
	if(nowPlayingNotificationsEnabled != _nowPlayingNotificationsEnabled) {
		_nowPlayingNotificationsEnabled = nowPlayingNotificationsEnabled;
		
		if([self isOnline]) {
			[self _submitPlayingSong];
		}
	}
}

- (NSString*)account {
	return _account;
}

- (void)setAccount:(NSString*)account {
	if(!EqualStrings(_account, account)) {
		[self willChangeValueForKey:@"account"];
		
		_account = account;

		[self didChangeValueForKey:@"account"];
		
		[self _resetSubmission]; // Reset submission object
		[self _resetHandshake]; // Reset handshake object
	}
}

- (NSString*)password {
	NSString* account = [self account];
	
	if(IsEmpty(account)) {
		return nil; // No account no password
	}
		
	NSString* password = [[Keychain defaultKeychain]
		genericPasswordForService:CSLastDotFMServiceKey
		account:account];
		
	return password;
}

- (void)setPassword:(NSString*)password {
//	[self willChangeValueForKey:@"password"];

	[[Keychain defaultKeychain] setGenericPassword:password
		forService:CSLastDotFMServiceKey
		account:[self account]];
		
//	[self didChangeValueForKey:@"password"];
	
	[self _resetSubmission]; // Reset submission object
	[self _resetHandshake]; // Reset handshake object
}

- (void)handshake {
	if(![self submissionsEnabled]) {
		return;
	}
	
	if(!_handshake) {
		id credentials = [self _credentials];
		_handshake = [LastDotFMHandshake handshakeWithCredentials:credentials];
		
		if(_handshake) {
			[self _resetSubmission];

			[_handshake setDelegate:self];
			[_handshake handshake];
			
			[self _setStatus:LastDotFMStatusConnecting];
		}
	}
}

- (NSDate*)lastSubmissionDate {
	return _lastSubmissionDate;
}

- (NSDate*)lastFailedSubmissionDate {
	return _lastFailedSubmissionDate;
}

- (BOOL)isOnline {
	return [self _status] != LastDotFMStatusOffline;
}

- (BOOL)isConnecting {
	return [self _status] == LastDotFMStatusConnecting;
}

- (BOOL)isSubmittingSongs {
	return [self _status] == LastDotFMStatusSubmitting;
}

- (NSString*)localizedStatus {
	if(![self submissionsEnabled]) {
		return NSLocalizedString(@"LASTFM_DISABLED_STATUS", nil);
	}
	
	if([self isConnecting]) {
		return [NSString stringWithFormat:NSLocalizedString(@"LASTFM_AUTHENTICATION_STATUS", nil), [self account]];
	}

	if([self isSubmittingSongs]) {
		return [NSString stringWithFormat:NSLocalizedString(@"LASTFM_SONGSUBMISSION_STATUS", nil), [self account]];
	}
	
	if([self _status] == LastDotFMStatusFailedAuthentication) {
		return [NSString stringWithFormat:NSLocalizedString(@"LASTFM_AUTHENTICATION_FAILED_STATUS", nil), [self account]];
	}
	
	NSDate* lastFailedSubmissionDate = [self lastFailedSubmissionDate];
	NSDate* lastSubmissionDate = [self lastSubmissionDate];
	
	if(lastFailedSubmissionDate || lastSubmissionDate) {
		lastFailedSubmissionDate = lastFailedSubmissionDate ? lastFailedSubmissionDate : [NSDate distantPast];
		lastSubmissionDate = lastSubmissionDate ? lastSubmissionDate : [NSDate distantPast];
	
		NSDate* laterDate = [lastSubmissionDate laterDate:lastFailedSubmissionDate];
			
		NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
		
		[dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
		
		NSString* formattedDate = [dateFormatter stringFromDate:laterDate];
		
		if(laterDate == lastFailedSubmissionDate) {
			return [NSString stringWithFormat:NSLocalizedString(@"LASTFM_SONGSUBMISSION_FAILED_STATUS", nil), formattedDate];
		} else {
			return [NSString stringWithFormat:NSLocalizedString(@"LASTFM_SONGSUBMISSION_SUCCEEDED_STATUS", nil), formattedDate];
		}
	}
	
	if([self isOnline]) {
		return [NSString stringWithFormat:NSLocalizedString(@"LASTFM_AUTHENTICATION_SUCCEEDED_STATUS", nil), [self account]];
	}
	
	return NSLocalizedString(@"LASTFM_AUTHENTICATION_NONE_STATUS", nil);
}

- (void)handshake:(LastDotFMHandshake*)handshake succeededWithInfo:(NSDictionary*)userInfo interval:(int)interval {
	_networkFailureCount = 0;
	
	_challenge = [userInfo valueForKeyPath:LastDotFMHandshakeSessionIDKey];
	
	_submissionURLString = [userInfo valueForKeyPath:LastDotFMHandshakeSubmissionURLKey];
	
	_nowPlayingURLString = [userInfo valueForKeyPath:LastDotFMHandshakeNowPlayingURLKey];
	
	[self _updateNextPossibleSubmissionDateWithInterval:interval];
//	[self _setLastSubmissionDate:nil]; // Reset submission date
	
	[self _setStatus:LastDotFMStatusOnline];
	
	[self _submitPlayingSong];
	[self _scheduleSubmission];
}

- (void)handshake:(LastDotFMHandshake*)handshake failedWithReason:(NSString*)reason interval:(int)interval {
	NSLog(@"Last.fm Handshake did fail: %@", reason);
	
	_challenge = nil;
	
	[self _setStatus:LastDotFMStatusOffline];
	
	[self _updateNextPossibleSubmissionDateWithInterval:interval];
}

- (void)handshake:(LastDotFMHandshake*)handshake failedAuthentication:(NSString*)user interval:(int)interval {
	NSLog(@"Bad Last.fm user");
	
	_challenge = nil;
	
	[self _setStatus:LastDotFMStatusFailedAuthentication];
	
	[self _updateNextPossibleSubmissionDateWithInterval:interval];
}

- (void)nowPlayingNotification:(LastDotFMNowPlayingNotification*)notification failedAuthentication:(NSString*)user {
	NSLog(@"Bad Last.fm user");
	
	_challenge = nil;
	
	[self _setStatus:LastDotFMStatusFailedAuthentication];
	
	[self _resetHandshake];
}

- (void)nowPlayingNotification:(LastDotFMNowPlayingNotification*)notification failedWithReason:(NSString*)reason {
	NSLog(@"Last.fm now playing notification did fail%@", reason ? [@": " stringByAppendingString:reason] : @"");
	
	_challenge = nil;
	
	[self _setStatus:LastDotFMStatusFailedAuthentication];
	
	[self _resetHandshake];
}

- (void)submission:(LastDotFMSubmission*)submission succeededWithInfo:(NSDictionary*)userInfo interval:(int)interval {
	_networkFailureCount = 0;
	
	[self _updateNextPossibleSubmissionDateWithInterval:interval];
	
	NSArray* recentSongs = [_recentSongs arrayByRemovingObjectsIdenticalToObjectsInArray:
		[submission submittedSongs]];
		
	_recentSongs = (NSMutableArray*)recentSongs;
	
	[self _setLastSubmissionDate:[NSDate date]];
	[self _setStatus:LastDotFMStatusOnline];
	
	// Schedule next song package
	if(!IsEmpty(_recentSongs)) {
		[self _scheduleSubmission];
	}
	
//	[[[CoverSutra self] bezelWindowController]
//		orderFrontSongSubmissionSucceededBezel:submission];
}

- (void)submission:(LastDotFMSubmission*)submission failedWithReason:(NSString*)reason interval:(int)interval {
	NSLog(@"Last.fm Song Submission did fail%@", reason ? [@": " stringByAppendingString:reason] : @"");
	
	++_networkFailureCount;
	
	[self _setLastFailedSubmissionDate:[NSDate date]];
	[self _updateNextPossibleSubmissionDateWithInterval:interval];
	
	if(_networkFailureCount >= CSLastDotFMMaxNumberOfNetworkFailures) {
		[self _resetHandshake];
	}
	
//	[[[CoverSutra self] bezelWindowController]
//		orderFrontSongSubmissionFailedBezel:submission];
}

- (void)submission:(LastDotFMSubmission*)submission failedAuthentication:(NSString*)user interval:(int)interval {
	NSLog(@"Bad Last.fm user");
	
	++_networkFailureCount;
	
	[self _setStatus:LastDotFMStatusFailedAuthentication];
	
	[self _setLastFailedSubmissionDate:[NSDate date]];
	[self _updateNextPossibleSubmissionDateWithInterval:interval];
	
//	[[[CoverSutra self] bezelWindowController]
//		orderFrontSongSubmissionFailedBezel:submission];
		
	[self _resetHandshake];
}

@end
