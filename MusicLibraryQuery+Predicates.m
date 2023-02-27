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

#import "MusicLibraryQuery+Predicates.h"

#import "NSPredicate+Additions.h"

#import "MusicLibraryTrack.h"

@implementation MusicLibraryQuery(Predicates)

+ (NSPredicate*)predicateForGenericSearch:(NSString*)searchString {
	static NSPredicate* _searchPredicateForTerm = nil;
	
	if(!_searchPredicateForTerm) {
		NSPredicate* predicate = [NSPredicate predicateWithFormat:
			@"(album like[cd] $searchTerm || (artist like[cd] $searchTerm || albumArtist like[cd] $searchTerm) || composer like[cd] $searchTerm || name like[cd] $searchTerm || grouping like[cd] $searchTerm) || genre like[cd] $searchTerm"];
			
		_searchPredicateForTerm = predicate;
	}
	
	NSArray* searchTerms = [NSPredicate searchTermsFromString:searchString];
	NSMutableArray* subPredicates = [NSMutableArray arrayWithCapacity:
		[searchTerms count]];
	
	for(NSString* searchTerm in searchTerms) {
		NSString* frontWildcard = [searchTerm length] <= 1 && [searchTerms count] == 1 ? @"" : @"*";
		NSString* wildcardSearchTerm = [NSString stringWithFormat:@"%@%@*", frontWildcard, searchTerm];
		
		NSDictionary* variables = [NSDictionary dictionaryWithObjectsAndKeys:
			wildcardSearchTerm, @"searchTerm",
			nil];
		[subPredicates addObject:
			[_searchPredicateForTerm predicateWithSubstitutionVariables:variables]];
	}
	
	return [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
}

+ (NSPredicate*)predicateForArtistSearch:(NSString*)searchString {
	static NSPredicate* _searchPredicateForArtist = nil;
	
	if(!_searchPredicateForArtist) {
		NSPredicate* predicate = [NSPredicate predicateWithFormat:
			@"(artist like[cd] $searchTerm || albumArtist like[cd] $searchTerm)"]; // || composer like[cd] $searchTerm"];
			
		_searchPredicateForArtist = predicate;
	}
	
	NSArray* searchTerms = [NSPredicate searchTermsFromString:searchString];
	NSMutableArray* subPredicates = [NSMutableArray arrayWithCapacity:
		[searchTerms count]];
	
	for(NSString* searchTerm in searchTerms) {
		NSString* frontWildcard = [searchTerm length] <= 1 && [searchTerms count] == 1 ? @"" : @"*";
		NSString* wildcardSearchTerm = [NSString stringWithFormat:@"%@%@*", frontWildcard, searchTerm];
		
		NSDictionary* variables = [NSDictionary dictionaryWithObjectsAndKeys:
			wildcardSearchTerm, @"searchTerm",
			nil];
		[subPredicates addObject:
			[_searchPredicateForArtist predicateWithSubstitutionVariables:variables]];
	}
	
	return [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
}

+ (NSPredicate*)predicateForAlbumSearch:(NSString*)searchString {
	static NSPredicate* _searchPredicateForAlbum = nil;
	
	if(!_searchPredicateForAlbum) {
		NSPredicate* predicate = [NSPredicate predicateWithFormat:
			@"(album like[cd] $searchTerm)"];
			
		_searchPredicateForAlbum = predicate;
	}
	
	NSArray* searchTerms = [NSPredicate searchTermsFromString:searchString];
	NSMutableArray* subPredicates = [NSMutableArray arrayWithCapacity:
		[searchTerms count]];
	
	for(NSString* searchTerm in searchTerms) {
		NSString* frontWildcard = [searchTerm length] <= 1 && [searchTerms count] == 1 ? @"" : @"*";
		NSString* wildcardSearchTerm = [NSString stringWithFormat:@"%@%@*", frontWildcard, searchTerm];
		
		NSDictionary* variables = [NSDictionary dictionaryWithObjectsAndKeys:
			wildcardSearchTerm, @"searchTerm",
			nil];
		[subPredicates addObject:
			[_searchPredicateForAlbum predicateWithSubstitutionVariables:variables]];
	}
	
	return [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
}

+ (NSPredicate*)predicateForSongSearch:(NSString*)searchString {
	static NSPredicate* _searchPredicateForSong = nil;
	
	if(!_searchPredicateForSong) {
		NSPredicate* predicate = [NSPredicate predicateWithFormat:
			@"(name like[cd] $searchTerm)"];
			
		_searchPredicateForSong = predicate;
	}
	
	NSArray* searchTerms = [NSPredicate searchTermsFromString:searchString];
	NSMutableArray* subPredicates = [NSMutableArray arrayWithCapacity:
		[searchTerms count]];
	
	for(NSString* searchTerm in searchTerms) {
		NSString* frontWildcard = [searchTerm length] <= 1 && [searchTerms count] == 1 ? @"" : @"*";
		NSString* wildcardSearchTerm = [NSString stringWithFormat:@"%@%@*", frontWildcard, searchTerm];
		
		NSDictionary* variables = [NSDictionary dictionaryWithObjectsAndKeys:
			wildcardSearchTerm, @"searchTerm",
			nil];
		[subPredicates addObject:
			[_searchPredicateForSong predicateWithSubstitutionVariables:variables]];
	}
	
	return [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
}

+ (NSPredicate*)predicateForUserRatingSearch:(NSUInteger)userRating {
	static NSPredicate* _searchPredicateForUserRating = nil;
	
	if(!_searchPredicateForUserRating) {
		NSPredicate* predicate = [NSPredicate predicateWithFormat:
			@"(normalizedRating >= $ratingValue)"];
			
		_searchPredicateForUserRating = predicate;
	}
	
	NSDictionary* variables = [NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithInteger:userRating], @"ratingValue",
		nil];

	return [_searchPredicateForUserRating predicateWithSubstitutionVariables:variables];
}

+ (NSPredicate*)predicateForPlaylistSearch:(NSString*)searchString {
	static NSPredicate* _searchPredicateForPlaylist = nil;
	
	if(!_searchPredicateForPlaylist) {
		NSPredicate* predicate = [NSPredicate predicateWithFormat:
			@"name like[cd] $searchTerm"];
			
		_searchPredicateForPlaylist = predicate;
	}
	
	NSArray* searchTerms = [NSPredicate searchTermsFromString:searchString];
	NSMutableArray* subPredicates = [NSMutableArray arrayWithCapacity:
		[searchTerms count]];
	
	for(NSString* searchTerm in searchTerms) {
		NSString* frontWildcard = [searchTerm length] <= 1 && [searchTerms count] == 1 ? @"" : @"*";
		NSString* wildcardSearchTerm = [NSString stringWithFormat:@"%@%@*", frontWildcard, searchTerm];
		
		NSDictionary* variables = [NSDictionary dictionaryWithObjectsAndKeys:
			wildcardSearchTerm, @"searchTerm",
			nil];
		[subPredicates addObject:
			[_searchPredicateForPlaylist predicateWithSubstitutionVariables:variables]];
	}
	
	return [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
}

+ (NSPredicate*)predicateForAlbumOfTrack:(id)track {
	NSString* album;

	if([track respondsToSelector:@selector(localizedAlbumTitle)]) {
		album = [track performSelector:@selector(localizedAlbumTitle)];
	} else {
		album = [track displayAlbum];
	}
	
	NSString* artist= [track artist];
	
	if(!artist) {
		artist = @"";
	}
	
	NSString* albumArtist = [track albumArtist];
	
	if(!albumArtist) {
		albumArtist = @"";
	}
	
	BOOL compilation = [track isCompilation];
	
	if(compilation) {
		static NSPredicate* _searchPredicateForCompilationOfTrack = nil;
		
		if(!_searchPredicateForCompilationOfTrack) {
			NSPredicate* predicate = [NSPredicate predicateWithFormat:
				@"(displayAlbum == $album && compilation == true)"];
				
			_searchPredicateForCompilationOfTrack = predicate;
		}
		
		NSDictionary* variables = [NSDictionary dictionaryWithObjectsAndKeys:
			album, @"album",
			nil];

		return [_searchPredicateForCompilationOfTrack predicateWithSubstitutionVariables:variables];
	} else {
		static NSPredicate* _searchPredicateForAlbumOfTrack = nil;
		
		if(!_searchPredicateForAlbumOfTrack) {
			NSPredicate* predicate = [NSPredicate predicateWithFormat:
				@"displayAlbum == $album && (artist == $artist || albumArtist == $albumArtist)"];
				
			_searchPredicateForAlbumOfTrack = predicate;
		}
		
		NSDictionary* variables = [NSDictionary dictionaryWithObjectsAndKeys:
			album, @"album",
			albumArtist, @"albumArtist",
			artist, @"artist",
			nil];

		return [_searchPredicateForAlbumOfTrack predicateWithSubstitutionVariables:variables];
	}

	return nil;
}

@end
