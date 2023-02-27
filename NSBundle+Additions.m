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

#import "NSBundle+Additions.h"

@implementation NSBundle(CoverSutraAdditions)

- (NSString*)versionString {
	return [[self infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString*)shortVersionString {
	return [[self infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

- (NSString*)infoDictionaryPath {
	return [[[self bundlePath]
		stringByAppendingPathComponent:@"Contents"]
		stringByAppendingPathComponent:@"Info.plist"];
}

- (NSString*)libraryPath {
	return [[[self bundlePath]
		stringByAppendingPathComponent:@"Contents"]
		stringByAppendingPathComponent:@"Library"];
}

- (void)touchFileModificationDate {
	NSArray* arguments = [NSArray arrayWithObjects:
		@"-c",
		@"-m",
		@"-f",
		[self bundlePath],
		nil];
	NSTask* task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/touch"
		arguments:arguments];
		
	if(!task) {
		// TODO
	}
}

- (BOOL)setObject:(id)object forInfoDictionaryKey:(NSString*)key {
	NSString* infoDictionaryPath = [self infoDictionaryPath];
	
	NSMutableDictionary* infoDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:infoDictionaryPath];
	
	[infoDictionary setObject:object forKey:key];
	
	BOOL result = [infoDictionary writeToFile:infoDictionaryPath atomically:YES];
		
	return result;
}

@end
