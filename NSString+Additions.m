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

#import "NSString+Additions.h"
#import "NSShadow+Additions.h"

@implementation NSString(Additions)

+ (NSString*)uuid {
    CFUUIDRef UUID = CFUUIDCreate(NULL);
	NSString* string = CFBridgingRelease(CFUUIDCreateString(NULL, UUID));
    CFRelease(UUID);
    
	return string;
}

- (NSString*)stringByReplacingAllOccurrencesOfString:(NSString*)stringToReplace withString:(NSString*)replacement {
    NSRange searchRange = NSMakeRange(0, [self length]);
    NSRange foundRange = [self rangeOfString:stringToReplace options:0 range:searchRange];
    
    // If stringToReplace is not found, then there's nothing to replace -- just return self
    if (foundRange.length == 0)
        return [self copy];

    NSMutableString *copy = [self mutableCopy];
    unsigned int replacementLength = [replacement length];
    
    while (foundRange.length > 0) {
        [copy replaceCharactersInRange:foundRange withString:replacement];
        
        searchRange.location = foundRange.location + replacementLength;
        searchRange.length = [copy length] - searchRange.location;

        foundRange = [copy rangeOfString:stringToReplace options:0 range:searchRange];
    }
    
    // Avoid an autorelease
    NSString *result = [copy copy];
    
    return result;
}

- (NSAttributedString*)attributedStringWithAttributes:(NSDictionary*)attribute {
	NSAttributedString* attributedString = [[NSAttributedString alloc]
		initWithString:self
		attributes:attribute];
		
	return attributedString;
}

- (NSString*)substringStartingAfterString:(NSString *)aString {
    NSRange aRange;

    aRange = [self rangeOfString:aString];
    if (aRange.length == 0)
        return nil;
    return [self substringFromIndex:aRange.location + aRange.length];
}

- (NSString*)URLEncode {
	NSString* encodedString = (__bridge_transfer NSString*)CFURLCreateStringByAddingPercentEscapes(
		kCFAllocatorDefault, 
		(__bridge CFStringRef)self, 
		NULL, 
		(CFStringRef)@"&+:./@$?%", 
		kCFStringEncodingUTF8);
		
	return encodedString;
}

@end
