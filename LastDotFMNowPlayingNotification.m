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

#import "LastDotFMNowPlayingNotification.h"
#import "LastDotFMNowPlayingNotification+Delegate.h"
#import "LastDotFMNowPlayingNotification+Private.h"

#import "LastDotFMHandshake.h"
#import "LastDotFMHandshake+Delegate.h"

#import "NSArray+Additions.h"

#import "Utilities.h"

@implementation LastDotFMNowPlayingNotification

+ (LastDotFMNowPlayingNotification*)nowPlayingNotificationWithCredentials:(id)credentials {
	return [[[self class] alloc] initWithCredentials:credentials];
}

- (id)initWithCredentials:(id)credentials {
	if((self = [super init])) {
		_credentials = credentials;
	}
	
	return self;
}


- (void)submitSong:(id)song {
	if(_URLConnection) {
		[self cancel];
	}

	NSString* nowPlayingURLString = [_credentials valueForKey:LastDotFMHandshakeNowPlayingURLKey];
	
	if(IsEmpty(nowPlayingURLString)) {
		return;
	}
	
	NSURL* nowPlayingURL = [NSURL URLWithString:nowPlayingURLString];
	NSMutableURLRequest* request = [NSMutableURLRequest
		requestWithURL:nowPlayingURL
		cachePolicy:NSURLRequestReloadIgnoringCacheData
		timeoutInterval:120];
	
	[request setHTTPMethod:@"POST"];
	
	[request setValue:@"Content-Type" forHTTPHeaderField:@"application/x-www-form-urlencoded"];
	
	NSString* body = [self _requestBodyForSong:song];
	[request setHTTPBody:[body dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSURLConnection* connection = [NSURLConnection connectionWithRequest:request delegate:self];
	[self _setURLConnection:connection];
}

- (void)cancel {
	[_URLConnection cancel];
	_URLConnection = nil;
}

- (BOOL)isSubmitting {
	return _URLConnection != nil;
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

	if(statusCode) {
		if(!EqualStrings(statusCode, @"OK")) {
			NSLog(@"Last.fm now playing notification failed.");
		}
		
		if(EqualStrings(statusCode, @"BADSESSION")) {
			if([[self delegate] respondsToSelector:@selector(nowPlayingNotification:failedAuthentication:)]) {
				NSString* user = [_credentials objectForKey:@"user"];
				[[self delegate]
					nowPlayingNotification:self
					failedAuthentication:user];
			}
		}
	}
	
	// Reset connection object
	[self _setURLConnection:nil];
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
	if([[self delegate] respondsToSelector:@selector(nowPlayingNotification:failedWithReason:)]) {
		[[self delegate]
			nowPlayingNotification:self
			failedWithReason:[error localizedFailureReason]];
	}

	// Reset connection object
	[self _setURLConnection:nil];
}

@end
