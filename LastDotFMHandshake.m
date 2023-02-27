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

#import "LastDotFMHandshake.h"
#import "LastDotFMHandshake+Delegate.h"
#import "LastDotFMHandshake+Private.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "NSArray+Additions.h"
#import "NSBundle+Additions.h"
#import "NSString+Additions.h"
#import "NSString+MD5.h"

#import "Utilities.h"

@implementation LastDotFMHandshake

+ (LastDotFMHandshake*)handshakeWithCredentials:(id)credentials {
	return [[[self class] alloc] initWithCredentials:credentials];
}

- (id)initWithCredentials:(id)credentials {
	if(![super init]) {
		return nil;
	}
	
	NSString* user = [credentials objectForKey:@"user"];
	NSString* password = [credentials objectForKey:@"password"];
	
	if(IsEmpty(user) || IsEmpty(password)) {
		return nil;
	}
	
	_isHandshaking = NO;
	_isAuthenticated = NO;
	
	// Determine iTunes client version
	NSString* client = @"cst";
	NSString* clientVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] URLEncode];
	
	// Get the current timestamp in standard UNIX format
	NSString* timestamp = [NSString stringWithFormat:@"%qu", (u_int64_t)[[NSDate date] timeIntervalSince1970]];
	
	// Generate the authentication token
	NSString* authenticationToken = [NSString stringWithFormat:@"%@%@",
		password,
		timestamp];
	authenticationToken = [authenticationToken md5DigestString];
	
	// Make the handshake URL
	NSString* handshakeURLString = [NSString stringWithFormat:
		@"http://post.audioscrobbler.com/?hs=true&p=1.2.1&c=%@&v=%@&u=%@&t=%@&a=%@",
        client,
		clientVersion,
        [user URLEncode],
		timestamp,
		authenticationToken];
	NSMutableURLRequest* request = [NSMutableURLRequest
		requestWithURL:[NSURL URLWithString:handshakeURLString]
		cachePolicy:NSURLRequestReloadIgnoringCacheData
		timeoutInterval:120];
	
	_request = request;
	
	return self;
}


- (void)handshake {
	if(![self isHandshaking]) {
		_isHandshaking = YES;
		_isAuthenticated = NO;
		
		NSURLConnection* connection = [NSURLConnection connectionWithRequest:_request delegate:self];
		[self _setURLConnection:connection];
	}
}

- (void)cancel {
	[[self _URLConnection] cancel];
	[self _setURLConnection:nil];
}

- (BOOL)isHandshaking {
	return _isHandshaking;
}

- (BOOL)isAuthenticated {
	return _isAuthenticated;
}

- (NSDate*)lastHandshakeDate {
	return _lastHandshakeDate;
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data {
	if(connection == [self _URLConnection]) {
		[_response appendData:data];
	}
}

-(void)connectionDidFinishLoading:(NSURLConnection*)connection {
	_isHandshaking = NO;
	
	_lastHandshakeDate = [NSDate date];
	
	NSString* responseString = [[NSString alloc]
		initWithData:_response
		encoding:NSUTF8StringEncoding];
	NSArray* response = [responseString componentsSeparatedByString:@"\n"];
	
	NSString* statusCode = [response firstObject];
	
	if(statusCode) {
//		SEL handler = NSSelectorFromString([NSString stringWithFormat:@"_handle%@:", statusCode]);
//	
//		if([self respondsToSelector:handler]) {
//			[self performSelector:handler withObject:response];
//			return;
//		}

		if([statusCode isEqualToString:@"OK"]) {
			if([self respondsToSelector:@selector(_handleOK:)]) { [self _handleOK:response]; }
		}
		
		if([statusCode isEqualToString:@"BANNED"]) {
			if([self respondsToSelector:@selector(_handleBANNED:)]) { [self _handleBANNED:response]; }
		}
		
		if([statusCode isEqualToString:@"BADAUTH"]) {
			if([self respondsToSelector:@selector(_handleBADAUTH:)]) { [self _handleBADAUTH:response]; }
		}
		
		if([statusCode isEqualToString:@"BADTIME"]) {
			if([self respondsToSelector:@selector(_handleBADTIME:)]) { [self _handleBADTIME:response]; }
		}
		
		if([statusCode isEqualToString:@"FAILED"]) {
			if([self respondsToSelector:@selector(_handleFAILED:)]) { [self _handleFAILED:response]; }
		}
	}
	
	[self _handleHardFailure:response];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError*)error {
	_isHandshaking = NO;
	_isAuthenticated = NO;
	
	_lastHandshakeDate = [NSDate date];
	
	if([[self delegate] respondsToSelector:@selector(handshake:failedWithReason:interval:)]) {
		[[self delegate]
			handshake:self
			failedWithReason:[error localizedDescription]
			interval:-1];
	}
}

@end
