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

#import "LastDotFMNowPlayingNotification+Private.h"

#import "LastDotFMHandshake.h"
#import "LastDotFMHandshake+Delegate.h"

#import "NSString+Additions.h"
#import "NSString+MD5.h"

#import "Utilities.h"

@implementation LastDotFMNowPlayingNotification(Private)

- (NSURLConnection*)_URLConnection {
	return _URLConnection;
}

- (void)_setURLConnection:(NSURLConnection*)URLConnection {
	_URLConnection = URLConnection;
	
	_response = [NSMutableData data];
}

- (NSString*)_requestBodyForSong:(id)song {
	NSString* sessionID = [_credentials objectForKey:LastDotFMHandshakeSessionIDKey];
	
	NSString* requestBody = [NSString stringWithFormat:@"s=%@&%@",
		[sessionID URLEncode],
		[self _requestStringForSong:song]];
		
	return requestBody;
}

- (NSString*)_requestStringForSong:(id)song {
	NSString* artist = [song objectForKey:@"artist"];
	
	// Replace localized artist with empty string
	if(EqualStrings(artist, NSLocalizedString(@"MEDIALIBRARY_NO_ARTIST", @"Missing artist description"))) {
		artist = @"";
	}
	
	NSString* title = [song objectForKey:@"title"];
	
	NSString* albumTitle = [song objectForKey:@"albumTitle"];
	
	// Replace localized album title with empty string
	if(EqualStrings(albumTitle, NSLocalizedString(@"MEDIALIBRARY_NO_ALBUM", @"Missing album title description"))) {
		albumTitle = @"";
	}
	
	NSString* musicBrainz = @"";
	
	NSNumber* trackNumber = [song objectForKey:@"trackNumber"];

	NSString* request = [NSString stringWithFormat:@"a=%@&t=%@&b=%@&l=%u&n=%@&m=%@",
		[self _stringByAddingPercentEscape:artist],
		[self _stringByAddingPercentEscape:title],
		[self _stringByAddingPercentEscape:albumTitle],
		[[song objectForKey:@"durationInSeconds"] unsignedIntValue],
		trackNumber ? (id)trackNumber : (id)@"",
		[self _stringByAddingPercentEscape:musicBrainz]];

	return request;
}

- (NSString*)_stringByAddingPercentEscape:(NSString*)string {
	if(IsEmpty(string)) {
		return @"";
	}

	return [string URLEncode];
}

@end
