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

#import "LastDotFMHandshake+Private.h"
#import "LastDotFMHandshake+Delegate.h"

#import "NSArray+Additions.h"
#import "NSString+Additions.h"

#import "Utilities.h"

@implementation LastDotFMHandshake(Private)

- (NSURLConnection*)_URLConnection {
	return _URLConnection;
}

- (void)_setURLConnection:(NSURLConnection*)URLConnection {
	_URLConnection = URLConnection;
	
	_response = [NSMutableData data];
}

- (void)_handleOK:(NSArray*)response {
	_isAuthenticated = YES;
			
	if([[self delegate] respondsToSelector:@selector(handshake:succeededWithInfo:interval:)]) {
		NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
		
		// MD5 challenge
		NSString* MD5Challenge = [response count] > 1 ? [response objectAtIndex:1] : nil;
		[userInfo setValue:MD5Challenge forKey:LastDotFMHandshakeSessionIDKey];
		
		// Play Now URL
		NSString* playNowURL = [response count] > 2 ? [response objectAtIndex:2] : nil;
		[userInfo setValue:playNowURL forKey:LastDotFMHandshakeNowPlayingURLKey];
		
		// Submission URL
		NSString* submissionURL = [response count] > 3 ? [response objectAtIndex:3] : nil;
		[userInfo setValue:submissionURL forKey:LastDotFMHandshakeSubmissionURLKey];
		
		// Seems like we never got a submission URL
		if(IsEmpty(submissionURL)) {
			[[self delegate]
				handshake:self
				failedWithReason:@"Invalid submission URL"
				interval:0];
		} else {
			[[self delegate] handshake:self succeededWithInfo:userInfo interval:0];
		}
	}
}

- (void)_handleBANNED:(NSArray*)response {
	[[self delegate]
		handshake:self
		failedWithReason:@"Application seems to be banned. Please update to the newest version."
		interval:0];
}

- (void)_handleBADAUTH:(NSArray*)response {
	if([[self delegate] respondsToSelector:@selector(handshake:failedAuthentication:interval:)]) {
		[[self delegate]
			handshake:self
			failedAuthentication:nil
			interval:0];
	}
}

- (void)_handleBADTIME:(NSArray*)response {
	[[self delegate]
		handshake:self
		failedWithReason:@"The computer clock may be wrong. Verify the time, day of month, month and year."
		interval:0];
}

- (void)_handleFAILED:(NSArray*)response {
	if([[self delegate] respondsToSelector:@selector(handshake:failedWithReason:interval:)]) {
		NSString* statusCode = [response firstObject];
		NSString* reason = [self _scanFailureReason:statusCode];

		[[self delegate]
			handshake:self
			failedWithReason:reason
			interval:0];
	}
}

- (void)_handleHardFailure:(NSArray*)response {
}

- (int)_scanInterval:(NSString*)string {
	int interval = [[string substringStartingAfterString:@"INTERVAL "] intValue];
	return interval;
}

- (NSString*)_scanUpdateURLString:(NSString*)string {
	return [string substringStartingAfterString:@"UPDATE "];
}

- (NSString*)_scanFailureReason:(NSString*)string {
	return [string substringStartingAfterString:@"FAILED "];
}

@end
