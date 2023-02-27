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

#import "SCLyricsPersistenceController.h"
#import "SCLyricsPersistenceController+Private.h"
#import "SCLyricsController.h"

#import "CoverSutra.h"
#import "NowPlayingController.h"
#import "PlayerController.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "NSArray+Additions.h"
#import "NSFileManager+QuickDirectories.h"
#import "NSString+Additions.h"

@implementation SCLyricsPersistenceController

#pragma mark -
#pragma mark SCLyricsPersistenceController construction & destruction

- (id)init {
	if (self = [super init]) {

	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark SCLyricsPersistenceController queue management methods

- (void)addItem:(NSDictionary*)item {
	NSString *persistentID = [item objectForKey:kLyricsKeyPersistentID];
	NSString *lyrics = [item objectForKey:kLyricsKeyLyrics];
	NSString *path = [[self storedLyricsDirectory] stringByAppendingPathComponent:persistentID];
	[lyrics writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

- (NSString*)lyricsForTrackWithPersistentID:(NSString*)persistentID {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = [[self storedLyricsDirectory] stringByAppendingPathComponent:persistentID];
	if (![fileManager fileExistsAtPath:path]) {
		return nil;
	}
	NSString *lyrics = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
	return lyrics;
}

- (void)removeLyricsForTrackWithPersistentID:(NSString*)persistentID {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *path = [[self storedLyricsDirectory] stringByAppendingPathComponent:persistentID];
	if (![fileManager fileExistsAtPath:path]) {
		return;
	}
	[fileManager removeItemAtPath:path error:nil];
}

#pragma mark -
#pragma mark SCLyricsPersistenceController local storage methods

- (NSString*)storedLyricsDirectory {
	NSString* applicationSupportDirectory = [[NSFileManager defaultManager] applicationSupportDirectory];
	NSString* coverSutraDirectory = [applicationSupportDirectory stringByAppendingPathComponent:@"CoverSutra"];
	NSString* storedLyricsDirectory = [coverSutraDirectory stringByAppendingPathComponent:@"Lyrics"];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:storedLyricsDirectory]) {
		[fileManager createDirectoryAtPath:storedLyricsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
	}
	return storedLyricsDirectory;
}

@end
