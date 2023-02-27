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

#import "LastDotFMSubmission+Private.h"

#import "LastDotFMHandshake.h"
#import "LastDotFMHandshake+Delegate.h"

#import "NSString+Additions.h"
#import "NSString+MD5.h"

#import "Utilities.h"

@implementation LastDotFMSubmission(Private)

- (NSURLConnection*)_URLConnection {
	return _URLConnection;
}

- (void)_setURLConnection:(NSURLConnection*)URLConnection {
	_URLConnection = URLConnection;
	
	_response = [NSMutableData data];
}

- (void)_setSubmittedSongs:(NSArray*)submittedSongs {
	_submittedSongs = submittedSongs;
}

- (void)_setLocalizedErrorDescription:(NSString*)localizedErrorDescription {
	_localizedErrorDescription = localizedErrorDescription;
}

- (NSString*)_requestBodyForSongs:(NSArray*)songs {
	NSString* sessionID = [_credentials objectForKey:LastDotFMHandshakeSessionIDKey];
	
	NSString* requestBody = [NSString stringWithFormat:@"s=%@&%@",
		[sessionID URLEncode],
		[self _requestStringForSongs:songs]];
		
	return requestBody;
}

- (NSString*)_requestStringForSongs:(NSArray*)songs {
	unsigned numberOfSongs = [songs count];
	unsigned songIndex = 0;
	
	NSMutableString* request = [NSMutableString string];
	
	for(; songIndex < numberOfSongs; ++songIndex) {
		NSString* s = [self _requestStringForSong:
			[songs objectAtIndex:songIndex]
			atIndex:songIndex];

		[request appendString:s];
		[request appendString:@"&"];
	}
	
	return request;
}

- (NSString*)_requestStringForSong:(id)song atIndex:(int)index {
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

	NSString* request = [NSString stringWithFormat:@"a[%u]=%@&t[%u]=%@&i[%u]=%qu&o[%u]=%@&b[%u]=%@&m[%u]=%@&l[%u]=%u&n[%u]=%@&r[%u]=%@",
		index, [self _stringByAddingPercentEscape:artist],
		index, [self _stringByAddingPercentEscape:title],
		index, (u_int64_t)[[song objectForKey:@"playedDate"] timeIntervalSince1970],
		index, @"P",
		index, [self _stringByAddingPercentEscape:albumTitle],
		index, [self _stringByAddingPercentEscape:musicBrainz],
		index, [[song objectForKey:@"durationInSeconds"] unsignedIntValue],
		index, trackNumber ? (id)trackNumber : (id)@"",
		index, @""]; // Love, Ban or Skip

	return request;
}

- (NSString*)_stringByAddingPercentEscape:(NSString*)string {
	if(IsEmpty(string)) {
		return @"";
	}

	return [string URLEncode];
}

@end
