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

#import "SCLyricsController.h"
#import "SCLyricsController+Private.h"
#import "SCLyricsPersistenceController.h"

#import "NowPlayingController.h"

#import "NSArray+Additions.h"
#import "NSString+Additions.h"

#import "iTunesAPI.h"
#import "iTunesAPI+Additions.h"

#import "MusicLibraryTrack+Scripting.h"

#import "CoverSutra.h"

#import "obsolete__SCLyricsWindowController.h"

NSString* const kLyricsKeyPersistentID	= @"persistentID";
NSString* const kLyricsKeyLyrics		= @"lyrics";

NSString* const kChartLyricsXMLNodeLyrics	= @"Lyric";
NSString* const kLyricsflyXMLNodeLyrics		= @"tx";

@implementation SCLyricsController

@synthesize lastRequestTimestamp = _lastRequestTimestamp,
	currentTrack = _currentTrack;

#pragma mark -
#pragma mark Construction & Destruction

- (id)init {
	if(self = [super init]) {
		_runningTransactions = [[NSMutableSet alloc] init];
		_scheduledTracks = [[NSMutableArray alloc] init];

		_requestDelay = 2.0;
		
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(playerDidChangeTrack:)
			name:PlayerDidChangeTrackNotification
			object:nil];
		
		iTunesTrack* currentTrack = CSiTunesApplication().currentTrack;
		if (![currentTrack.lyrics isEqualToString:@""]) {
			[[[CoverSutra self] lyricsWindowController] setLyrics:currentTrack.lyrics];
			[[[CoverSutra self] lyricsWindowController] setInfoText:@""];
		}
	}
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	self.lastRequestTimestamp = nil;
	self.currentTrack = nil;

	[_scheduledTracks release];
	[_runningTransactions release];
	
	[super dealloc];
}

#pragma mark -
#pragma mark SCLyricsController

- (void)requestLyricsIfNeeded:(MusicLibraryTrack*)track {
	iTunesTrack* scriptingObject = [[track sourceScriptingObjects] objectForKey:@"track"];
	NSString *existingLyrics = nil;
	if (![scriptingObject.lyrics isEqualToString:@""]) {
		existingLyrics = scriptingObject.lyrics;
	}
	if (!existingLyrics) {
		SCLyricsPersistenceController *persistenceController = [[SCLyricsPersistenceController alloc] init];
		NSString *persistentLyrics = [persistenceController lyricsForTrackWithPersistentID:scriptingObject.persistentID];
		[persistenceController release], persistenceController = nil;
		
		if (nil != persistentLyrics) {
			existingLyrics = persistentLyrics;			
		}
	}
	if (!existingLyrics) {
		[self requestLyrics:track];
	}
}

- (void)requestLyrics:(MusicLibraryTrack*)track {
	[_scheduledTracks addObject:track];
	
	if([_scheduledTracks count] > 1) {
		return;
	}
	
	NSDate* now = [NSDate date];
	NSDate* lastRequestTimestamp = self.lastRequestTimestamp;
	
	NSTimeInterval delta = !lastRequestTimestamp ?
		_requestDelay :
		[now timeIntervalSinceDate:lastRequestTimestamp];
	
	if(delta >= _requestDelay) {
		[self dequeueNextScheduledTrack];
	} else {
		NSTimeInterval delay = _requestDelay;

		[self performSelector:@selector(dequeueNextScheduledTrack)
			withObject:nil
			afterDelay:delay];
	}
}

#pragma mark -
#pragma mark Private

- (void)dequeueNextScheduledTrack {
	MusicLibraryTrack* track = [_scheduledTracks firstObject];
	
	if(track) {
		self.lastRequestTimestamp = [NSDate date];
		[self requestForChartLyrics:track];
		// [self requestForLyricsfly:track];
	
		[_scheduledTracks removeObjectAtIndex:0];
	}
}

- (void)requestForChartLyrics:(MusicLibraryTrack*)track {
	NSString* artist = track.artist;
	if(!artist) { artist = @""; }
	
	NSString* song = track.name;
	if(!song) { song = @""; }
	
	NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
		artist, @"artist",
		song, @"song",
		nil];
	NSURL* URL = [NSURL
		URLWithString:@"http://api.chartlyrics.com/apiv1.asmx/SearchLyricDirect"
		parameters:parameters];

	NSURLRequest* request = [NSURLRequest requestWithURL:URL];
	
	id completion = ^(SFHTTPTransaction* transaction) {
		if (transaction.error) {
			NSLog(@"%@", transaction.error ? transaction.error : transaction.value);
		}
		
		NSString *lyrics = nil;
		NSXMLNode* rootNode = nil;
		if ([transaction.value isKindOfClass:[NSXMLNode class]]) {
			rootNode = transaction.value;
			NSXMLNode* currentNode = rootNode;
			while (currentNode = [currentNode nextNode]) {
				NSString* localName = [currentNode localName];
				if ([localName isEqualToString:kChartLyricsXMLNodeLyrics]) {
					lyrics = [currentNode stringValue];
					break;
				}
			}
		}
		if (lyrics) {
			[_scheduledTracks removeObject:track];
			SCLyricsPersistenceController *persistenceController = [[[SCLyricsPersistenceController alloc] init] autorelease];
			NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:track.persistentID,
								  kLyricsKeyPersistentID,
								  lyrics,
								  kLyricsKeyLyrics,
								  nil];
			[persistenceController addItem:item];
			
			iTunesTrack* currentTrack = CSiTunesApplication().currentTrack;
			if ([currentTrack.persistentID isEqualToString:track.persistentID]) {
				[[[CoverSutra self] lyricsWindowController] setLyrics:lyrics];
				[[[CoverSutra self] lyricsWindowController] setInfoText:@"Lyrics by Chartlyrics.com"];
			}
		}
		[_runningTransactions removeObject:transaction];
		
		MusicLibraryTrack* nextTrack = [_scheduledTracks firstObject];
		
		if(nextTrack) {
			[[nextTrack retain] autorelease];
			[_scheduledTracks removeObjectAtIndex:0];
			
			[self requestLyrics:nextTrack];
		}
	};
	
	SFHTTPTransaction* transaction = [SFHTTPTransaction transactionWithRequest:request completion:completion];
	[_runningTransactions addObject:transaction];
}

- (void)requestForLyricsfly:(MusicLibraryTrack*)track {
	NSString* artist = track.artist;
	if(!artist) { artist = @""; }
	
	NSString* song = track.name;
	if(!song) { song = @""; }
	
	static NSString* const lyricsflyAPIKey = @"8697f4af5559f50d0-temporary.API.access";
	
	NSDictionary* parameters = [NSDictionary dictionaryWithObjectsAndKeys:
		lyricsflyAPIKey, @"i",
		artist, @"a",
		song, @"t",
		nil];
	NSURL* URL = [NSURL
		URLWithString:@"http://api.lyricsfly.com/api/api.php"
		parameters:parameters];

	NSURLRequest* request = [NSURLRequest requestWithURL:URL];
	
	id completion = ^(SFHTTPTransaction* transaction) {
		if (transaction.error) {
			NSLog(@"%@", transaction.error ? transaction.error : transaction.value);
		}
		
		NSString *lyrics = nil;
		NSXMLNode* rootNode = nil;
		if ([transaction.value isKindOfClass:[NSXMLNode class]]) {
			rootNode = transaction.value;
			NSXMLNode* currentNode = rootNode;
			while (currentNode = [currentNode nextNode]) {
				NSString* localName = [currentNode localName];
				if ([localName isEqualToString:kLyricsflyXMLNodeLyrics]) {
					lyrics = [currentNode stringValue];
					break;
				}
			}
		}
		if (lyrics) {
			[_scheduledTracks removeObject:track];
			SCLyricsPersistenceController *persistenceController = [[[SCLyricsPersistenceController alloc] init] autorelease];
			NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:track.persistentID,
								  kLyricsKeyPersistentID,
								  lyrics,
								  kLyricsKeyLyrics,
								  nil];
			[persistenceController addItem:item];
			
			iTunesTrack* currentTrack = CSiTunesApplication().currentTrack;
			if ([currentTrack.persistentID isEqualToString:track.persistentID]) {
				[[[CoverSutra self] lyricsWindowController] setLyrics:lyrics];
				[[[CoverSutra self] lyricsWindowController] setInfoText:@"Lyrics by lyricsfly.com"];
			}
		}
		[_runningTransactions removeObject:transaction];
		
		MusicLibraryTrack* nextTrack = [_scheduledTracks firstObject];
		
		if(nextTrack) {
			[[nextTrack retain] autorelease];
			[_scheduledTracks removeObjectAtIndex:0];
			
			[self requestLyrics:nextTrack];
		}
	};
	
	SFHTTPTransaction* transaction = [SFHTTPTransaction transactionWithRequest:request completion:completion];
	[_runningTransactions addObject:transaction];
}

- (void)playerDidChangeTrack:(NSNotification*)notification {
	MusicLibraryTrack* track = [[notification userInfo] objectForKey:@"track"];
	
	if (nil != self.currentTrack) {
		iTunesTrack* scriptingObject = [[self.currentTrack sourceScriptingObjects] objectForKey:@"track"];
		NSString *existingLyrics = scriptingObject.lyrics;
		if (nil == existingLyrics ||
			[@"" isEqualToString:existingLyrics]) {
			SCLyricsPersistenceController *persistenceController = [[SCLyricsPersistenceController alloc] init];
			NSString *persistentLyrics = [persistenceController lyricsForTrackWithPersistentID:scriptingObject.persistentID];
			
			if (nil != persistentLyrics) {
				scriptingObject.lyrics = persistentLyrics;
				[persistenceController removeLyricsForTrackWithPersistentID:scriptingObject.persistentID];
			}

			[persistenceController release], persistenceController = nil;
		}
	}
	
	if(track) {
		self.currentTrack = track;
		[self requestLyricsIfNeeded:track];
	}
}

@end
