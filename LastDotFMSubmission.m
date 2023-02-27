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

#import "LastDotFMSubmission.h"
#import "LastDotFMSubmission+Delegate.h"
#import "LastDotFMSubmission+Private.h"

#import "LastDotFMHandshake.h"
#import "LastDotFMHandshake+Delegate.h"

#import "NSArray+Additions.h"
#import "NSString+Additions.h"

#import "Utilities.h"

@implementation LastDotFMSubmission

+ (LastDotFMSubmission*)submissionWithCredentials:(id)credentials {
	return [[LastDotFMSubmission alloc] initWithCredentials:credentials];
}

- (id)initWithCredentials:(id)credentials {
	if(![super init]) {
		return nil;
	}

	_credentials = credentials;
	
	return self;
}


- (void)submitSong:(id)song {
	[self submitSongs:
		[NSArray arrayWithObject:song]];
}

- (void)submitSongs:(NSArray*)songs {
	NSString* submissionURLString = [_credentials valueForKey:LastDotFMHandshakeSubmissionURLKey];
	
	if(IsEmpty(submissionURLString)) {
		return;
	}
	
	NSURL* submissionURL = [NSURL URLWithString:submissionURLString];
	NSMutableURLRequest* request = [NSMutableURLRequest
		requestWithURL:submissionURL
		cachePolicy:NSURLRequestReloadIgnoringCacheData
		timeoutInterval:120];
	
	[request setHTTPMethod:@"POST"];
	
	[request setValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
	
	NSString* body = [self _requestBodyForSongs:songs];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
	[self _setURLConnection:connection];
	
	[self _setLocalizedErrorDescription:nil];
	
	[self _setSubmittedSongs:songs];
}

- (void)cancel {
	[[self _URLConnection] cancel];
	[self _setURLConnection:nil];
}

- (BOOL)isSubmitting {
	return [self _URLConnection] != nil;
}

- (NSArray*)submittedSongs {
	return _submittedSongs;
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
	if(connection == [self _URLConnection]) {
		[_response appendData:data];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection {
	NSString* responseString = [[NSString alloc]
		initWithData:_response
		encoding:NSUTF8StringEncoding];
	NSArray* response = [responseString componentsSeparatedByString:@"\n"];
	
	NSString* statusCode = [response firstObject];
	NSString* intervalString = [response count] > 1 ? [response objectAtIndex:1] : nil;
	int interval = [[intervalString substringStartingAfterString:@"INTERVAL "] intValue];
	
	if(statusCode) {
		if([statusCode isEqualToString:@"OK"]) {
			if([[self delegate] respondsToSelector:@selector(submission:succeededWithInfo:interval:)]) {
				[[self delegate]
					submission:self
					succeededWithInfo:nil // TODO
					interval:interval];
			}
		}
		
		if([statusCode isEqualToString:@"BADSESSION"]) {
			NSString* user = [_credentials objectForKey:@"user"];
			NSString* badAuthenticationError = NSLocalizedString(@"LASTFM_BADSESSION_ERROR", @"Bad Last.fm authentication error");
			[self _setLocalizedErrorDescription:
				[NSString stringWithFormat:badAuthenticationError, user]];
			
			if([[self delegate] respondsToSelector:@selector(submission:failedAuthentication:interval:)]) {
				[[self delegate]
					submission:self
					failedAuthentication:nil
					interval:interval];
			}
		}
		
		if([statusCode hasPrefix:@"FAILED"]) {
			NSString* reason = [statusCode substringStartingAfterString:@"FAILED "];
			[self _setLocalizedErrorDescription:reason];
			
			if([[self delegate] respondsToSelector:@selector(submission:failedWithReason:interval:)]) {
				[[self delegate]
					submission:self
					failedWithReason:[self localizedErrorDescription]
					interval:interval];
			}
		}
	}
	
	// Reset connection object
	[self _setURLConnection:nil];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*)error {
	[self _setLocalizedErrorDescription:[error localizedFailureReason]];
	
	if([[self delegate] respondsToSelector:@selector(submission:failedWithReason:interval:)]) {
		[[self delegate]
			submission:self
			failedWithReason:[self localizedErrorDescription]
			interval:-1];
	}
}

- (NSString*)localizedErrorDescription {
	return _localizedErrorDescription;
}

@end
