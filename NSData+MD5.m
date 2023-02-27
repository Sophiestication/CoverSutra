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

#import "NSData+MD5.h"

#include <openssl/md5.h>

@implementation NSData(MD5)

- (NSData*)md5Digest {
    const size_t bufferSize = MD5_DIGEST_LENGTH;
	unsigned char buffer[bufferSize];

	memset(buffer, 0, bufferSize);
	MD5([self bytes], [self length], buffer);

    return [NSData dataWithBytes:buffer length:bufferSize];
}

- (NSString*)md5DigestString {
	const size_t bufferSize = MD5_DIGEST_LENGTH;
	unsigned char buffer[bufferSize];
	
	memset(buffer, 0, bufferSize);
	
	MD5([self bytes], [self length], buffer);
	
	NSString* digestString = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
		buffer[0],
		buffer[1],
		buffer[2],
		buffer[3],
		buffer[4],
		buffer[5],
		buffer[6],
		buffer[7],
		buffer[8],
		buffer[9],
		buffer[10],
		buffer[11],
		buffer[12],
		buffer[13],
		buffer[14],
		buffer[15]];
	
	return digestString;
}

@end
