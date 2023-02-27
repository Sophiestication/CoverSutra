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

#import "NSFileManager+QuickDirectories.h"

@implementation NSFileManager (QuickDirectories)

- (NSString *)documentsDirectory {
	NSString *path = nil;
	
	NSArray *directories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
	if (nil == directories || 0 == [directories count]) {
		return nil;
	}
	
	path = [directories objectAtIndex:0];
	return path;
}

- (NSString *)applicationSupportDirectory {
	NSString *path = nil;
	
	NSArray *directories = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSAllDomainsMask, YES);
	if (nil == directories || 0 == [directories count]) {
		return nil;
	}
	
	path = [directories objectAtIndex:0];
	
	if (![self fileExistsAtPath:path]) {
		NSError *directoryCreationError = nil;
		BOOL directoryCreationSuccess = [self createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&directoryCreationError];
		if (!directoryCreationSuccess) {
			// NSLog(@"%@", directoryCreationError);
			return nil;
		}
	}
	
	return path;
}

@end
