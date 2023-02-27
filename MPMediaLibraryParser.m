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

#import "MPMediaLibraryParser.h"
#import "MPMediaLibraryParser+Private.h"

#import <libxml/parser.h>

@implementation MPMediaLibraryParser

static xmlSAXHandler simpleSAXHandlerStruct;

@synthesize delegate = _delegate;

@synthesize parsingKey = _parsingKey;
@synthesize parsingStringValue = _parsingStringValue;
@synthesize parsingIntegerValue = _parsingIntegerValue;
@synthesize parsingDateValue = _parsingDateValue;
@synthesize parsingBooleanValue = _parsingBooleanValue;
@synthesize parsingDataValue = _parsingDataValue;
@synthesize parsingDictionary = _parsingDictionary;
@synthesize parsingTracks = _parsingTracks;
@synthesize parsedTracks = _parsedTracks;
@synthesize parsingTrack = _parsingTrack;
@synthesize parsingTracksDictionary = _parsingTracksDictionary;
@synthesize parsingPlaylists = _parsingPlaylists;
@synthesize parsingPlaylistsDictionary = _parsingPlaylistsDictionary;
@synthesize parsedPlaylists = _parsedPlaylists;
@synthesize parsingPlaylist = _parsingPlaylist;

@synthesize dictionaryLevel = _dictionaryLevel;
@synthesize arrayLevel = _arrayLevel;

@synthesize characterBuffer = _characterBuffer;
@synthesize characters = _characters;
@dynamic bufferString;
@synthesize lastKeyString = _lastKeyString;

#pragma mark -
#pragma mark Construction & Destruction

- (id)initWithURL:(NSURL*)propertyListURL delegate:(id<MPMediaLibraryParserDelegate>)delegate error:(NSError**)error {
	if(self = [super init]) {
		self.delegate = delegate;

		self.characterBuffer = [NSMutableData data];
		
		self.parsingStringValue = NO;
		self.parsingIntegerValue = NO;
		self.parsingDateValue = NO;
		self.parsingDictionary = NO;
		self.parsingBooleanValue = NO;
		self.parsingDataValue = NO;
		self.parsingTrack = NO;
		self.parsingTracks = NO;
		self.parsedTracks = NO;
		self.parsingTracksDictionary = NO;
		self.parsingPlaylists = NO;
		self.parsingPlaylistsDictionary = NO;
		self.parsedPlaylists = NO;
		self.parsingPlaylist = NO;
		
		self.dictionaryLevel = 0;
		self.arrayLevel = 0;
		
//		xmlPedanticParserDefault(0);
//		xmlKeepBlanksDefault(0);
//		xmlLineNumbersDefault(0);

		if([NSXMLParser instancesRespondToSelector:@selector(initWithStream:)]) {
			NSInputStream* stream = [NSInputStream inputStreamWithURL:propertyListURL];
			
			NSXMLParser* parser = [[NSXMLParser alloc] initWithStream:stream];
			
			[parser setDelegate:self];
			
			if(![parser parse]) {
				if(error) {
					*error = [parser parserError];
				}
			}
			
		} else {
			if(xmlSAXUserParseFile(&simpleSAXHandlerStruct, (__bridge void *)(self), [[propertyListURL relativePath] UTF8String]) != 0) {
				if(error) {
					*error = [NSError errorWithDomain:NSXMLParserErrorDomain code:NSXMLParserInternalError userInfo:nil];
				}
			}
		}
	}

	return self;
}


#pragma mark -
#pragma mark NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser*)parser {
}

- (void)parserDidEndDocument:(NSXMLParser*)parser {
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName attributes:(NSDictionary*)attributeDict {
	if([elementName isEqualToString:@"key"]) {
		self.parsingKey = YES;
		self.parsingStringValue = NO;
		self.parsingIntegerValue = NO;
		self.parsingDateValue = NO;
		self.parsingBooleanValue = NO;
		self.parsingDataValue = NO;
	} else if([elementName isEqualToString:@"string"]) {
		self.parsingKey = NO;
		self.parsingStringValue = YES;
		self.parsingIntegerValue = NO;
		self.parsingDateValue = NO;
		self.parsingBooleanValue = NO;
		self.parsingDataValue = NO;
	} else if([elementName isEqualToString:@"integer"]) {
		self.parsingKey = NO;
		self.parsingStringValue = NO;
		self.parsingIntegerValue = YES;
		self.parsingDateValue = NO;
		self.parsingBooleanValue = NO;
		self.parsingDataValue = NO;
	} else if([elementName isEqualToString:@"date"]) {
		self.parsingKey = NO;
		self.parsingStringValue = NO;
		self.parsingIntegerValue = NO;
		self.parsingDateValue = YES;
		self.parsingBooleanValue = NO;
		self.parsingDataValue = NO;
	} else if([elementName isEqualToString:@"true"] || [elementName isEqualToString:@"false"]) {
		self.parsingKey = NO;
		self.parsingStringValue = NO;
		self.parsingIntegerValue = NO;
		self.parsingDateValue = NO;
		self.parsingBooleanValue = YES;
		self.parsingDataValue = NO;
	} else if([elementName isEqualToString:@"data"]) {
		self.parsingKey = NO;
		self.parsingStringValue = NO;
		self.parsingIntegerValue = NO;
		self.parsingDateValue = NO;
		self.parsingBooleanValue = NO;
		self.parsingDataValue = YES;
	} else if([elementName isEqualToString:@"dict"]) {
		self.parsingKey = NO;
		self.parsingStringValue = NO;
		self.parsingIntegerValue = NO;
		self.parsingDateValue = NO;
		self.parsingBooleanValue = NO;
		self.parsingDataValue = NO;
		
		++self.dictionaryLevel;
		
		if(self.parsingTracks && self.dictionaryLevel == 3) {
			[[self delegate] musicLibraryParserWillStartParsingTrack:self];
		}
		
		if(self.parsingPlaylists && self.dictionaryLevel == 2) {
			[[self delegate] musicLibraryParserWillStartParsingPlaylist:self];
		}
	} else if([elementName isEqualToString:@"array"]) {
		self.parsingKey = NO;
		self.parsingStringValue = NO;
		self.parsingIntegerValue = NO;
		self.parsingDateValue = NO;
		self.parsingBooleanValue = NO;
		self.parsingDataValue = NO;

		++self.arrayLevel;
	}
	
	// Reset our character buffer
	self.characters = nil;
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString*)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString*)qName {
	if(self.parsingKey) {
		self.lastKeyString = [self characters];
		self.parsingKey = NO;
		
		if(!self.parsingTracks && !self.parsedTracks && self.dictionaryLevel == 1) {
			self.parsingTracks = [[self lastKeyString] isEqualToString:@"Tracks"];
		}
		
		if(!self.parsingPlaylists && !self.parsedPlaylists && self.dictionaryLevel == 1) {
			self.parsingPlaylists = [[self lastKeyString] isEqualToString:@"Playlists"];
		}
	} else if([elementName isEqualToString:@"dict"]) {
		if(self.parsingTracks && self.dictionaryLevel == 3) {
			[[self delegate] musicLibraryParserDidStopParsingTrack:self];
		}
		
		if(self.parsingPlaylists && self.dictionaryLevel == 2) {
			[[self delegate] musicLibraryParserDidStopParsingPlaylist:self];
		}
		
		if(self.parsingTracks && self.dictionaryLevel == 2) {
			self.parsingTracks = NO;
			self.parsedTracks = YES;
		}

		--self.dictionaryLevel;
	} else if([elementName isEqualToString:@"array"]) {
		if(self.parsedTracks && self.parsingPlaylists && self.arrayLevel == 1) {
			self.parsingPlaylists = NO;
			self.parsedPlaylists = YES;
		}

		--self.arrayLevel;
	} else if(self.parsingStringValue || self.parsingIntegerValue || self.parsingDateValue || self.parsingDataValue) {
		if(self.parsingTracks && self.dictionaryLevel == 3) {
			[[self delegate] musicLibraryParser:self parsedTrackProperty:[self lastKeyString] value:[self characters]];
		}
		
		if(self.parsingPlaylists && self.dictionaryLevel == 2) {
			[[self delegate] musicLibraryParser:self parsedPlaylistProperty:[self lastKeyString] value:[self characters]];
		}
		
//		if(self.parsingPlaylists && self.dictionaryLevel == 3) {
//			[[parser delegate] musicLibraryParser:parser parsedPlaylistTrack:[parser characters]];
//		}
	} else if(self.parsingBooleanValue) {
		if(self.parsingTracks && self.dictionaryLevel == 3) {
			[[self delegate] musicLibraryParser:self parsedTrackProperty:[self lastKeyString] value:nil];
		}
		
		if(self.parsingPlaylists && self.dictionaryLevel == 2) {
			[[self delegate] musicLibraryParser:self parsedPlaylistProperty:[self lastKeyString] value:nil];
		}
	}
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string {
	if(self.characters) {
		self.characters = [[self characters] stringByAppendingString:string];
	} else {
		self.characters = string;
	}
}

- (void)parser:(NSXMLParser*)parser parseErrorOccurred:(NSError*)parseError {
	if([[parseError domain] isEqualToString:NSXMLParserErrorDomain] && parseError.code == NSXMLParserInvalidCharacterError) {
		NSLog(@"Could not parse invalid character at line: %ld, column: %ld", (long)[parser lineNumber], (long)[parser columnNumber]);
	}
}

#pragma mark -
#pragma mark Private

- (NSString*)bufferString {
	return [[NSString alloc] initWithData:[self characterBuffer] encoding:NSUTF8StringEncoding];
}

static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes) {
	MPMediaLibraryParser* parser = (__bridge MPMediaLibraryParser*)ctx;
	
//	NSLog(@"%s", localname);
	
	if(xmlStrEqual(localname, BAD_CAST("key"))) {
		parser.parsingKey = YES;
		parser.parsingStringValue = NO;
		parser.parsingIntegerValue = NO;
		parser.parsingDateValue = NO;
		parser.parsingBooleanValue = NO;
		parser.parsingDataValue = NO;
	} else if(xmlStrEqual(localname, BAD_CAST("string"))) {
		parser.parsingKey = NO;
		parser.parsingStringValue = YES;
		parser.parsingIntegerValue = NO;
		parser.parsingDateValue = NO;
		parser.parsingBooleanValue = NO;
		parser.parsingDataValue = NO;
	} else if(xmlStrEqual(localname, BAD_CAST("integer"))) {
		parser.parsingKey = NO;
		parser.parsingStringValue = NO;
		parser.parsingIntegerValue = YES;
		parser.parsingDateValue = NO;
		parser.parsingBooleanValue = NO;
		parser.parsingDataValue = NO;
	} else if(xmlStrEqual(localname, BAD_CAST("date"))) {
		parser.parsingKey = NO;
		parser.parsingStringValue = NO;
		parser.parsingIntegerValue = NO;
		parser.parsingDateValue = YES;
		parser.parsingBooleanValue = NO;
		parser.parsingDataValue = NO;
	} else if(xmlStrEqual(localname, BAD_CAST("true")) || xmlStrEqual(localname, BAD_CAST("false"))) {
		parser.parsingKey = NO;
		parser.parsingStringValue = NO;
		parser.parsingIntegerValue = NO;
		parser.parsingDateValue = NO;
		parser.parsingBooleanValue = YES;
		parser.parsingDataValue = NO;
	} else if(xmlStrEqual(localname, BAD_CAST("data"))) {
		parser.parsingKey = NO;
		parser.parsingStringValue = NO;
		parser.parsingIntegerValue = NO;
		parser.parsingDateValue = NO;
		parser.parsingBooleanValue = NO;
		parser.parsingDataValue = YES;
	} else if(xmlStrEqual(localname, BAD_CAST("dict"))) {
		parser.parsingKey = NO;
		parser.parsingStringValue = NO;
		parser.parsingIntegerValue = NO;
		parser.parsingDateValue = NO;
		parser.parsingBooleanValue = NO;
		parser.parsingDataValue = NO;
		
		++parser.dictionaryLevel;
		
		if(parser.parsingTracks && parser.dictionaryLevel == 3) {
			[[parser delegate] musicLibraryParserWillStartParsingTrack:parser];
		}
		
		if(parser.parsingPlaylists && parser.dictionaryLevel == 2) {
			[[parser delegate] musicLibraryParserWillStartParsingPlaylist:parser];
		}
	} else if(xmlStrEqual(localname, BAD_CAST("array"))) {
		parser.parsingKey = NO;
		parser.parsingStringValue = NO;
		parser.parsingIntegerValue = NO;
		parser.parsingDateValue = NO;
		parser.parsingBooleanValue = NO;
		parser.parsingDataValue = NO;

		++parser.arrayLevel;
	}
	
	// Reset our character buffer
	[[parser characterBuffer] setData:[NSData data]];
}

static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI) {
	MPMediaLibraryParser* parser = (__bridge MPMediaLibraryParser*)ctx;
	
	if(parser.parsingKey) {
		parser.lastKeyString = [parser bufferString];
		parser.parsingKey = NO;
		
		if(!parser.parsingTracks && !parser.parsedTracks && parser.dictionaryLevel == 1) {
			parser.parsingTracks = [[parser lastKeyString] isEqualToString:@"Tracks"];
		}
		
		if(!parser.parsingPlaylists && !parser.parsedPlaylists && parser.dictionaryLevel == 1) {
			parser.parsingPlaylists = [[parser lastKeyString] isEqualToString:@"Playlists"];
		}
	} else if(xmlStrEqual(localname, BAD_CAST("dict"))) {
		if(parser.parsingTracks && parser.dictionaryLevel == 3) {
			[[parser delegate] musicLibraryParserDidStopParsingTrack:parser];
		}
		
		if(parser.parsingPlaylists && parser.dictionaryLevel == 2) {
			[[parser delegate] musicLibraryParserDidStopParsingPlaylist:parser];
		}
		
		if(parser.parsingTracks && parser.dictionaryLevel == 2) {
			parser.parsingTracks = NO;
			parser.parsedTracks = YES;
		}

		--parser.dictionaryLevel;
	} else if(xmlStrEqual(localname, BAD_CAST("array"))) {
		if(parser.parsedTracks && parser.parsingPlaylists && parser.arrayLevel == 1) {
			parser.parsingPlaylists = NO;
			parser.parsedPlaylists = YES;
		}

		--parser.arrayLevel;
	} else if(parser.parsingStringValue || parser.parsingIntegerValue || parser.parsingDateValue || parser.parsingDataValue) {
		if(parser.parsingTracks && parser.dictionaryLevel == 3) {
			NSString* string = [[NSString alloc] initWithData:[parser characterBuffer] encoding:NSUTF8StringEncoding];
		
			[[parser delegate] musicLibraryParser:parser parsedTrackProperty:[parser lastKeyString] value:string];
			
		}
		
		if(parser.parsingPlaylists && parser.dictionaryLevel == 2) {
			NSString* string = [[NSString alloc] initWithData:[parser characterBuffer] encoding:NSUTF8StringEncoding];
		
			[[parser delegate] musicLibraryParser:parser parsedPlaylistProperty:[parser lastKeyString] value:string];
			
		}
		
		if(parser.parsingPlaylists && parser.dictionaryLevel == 3) {
//			[[parser delegate] musicLibraryParser:parser parsedPlaylistTrack:[parser characterBuffer]];
		}
	} else if(parser.parsingBooleanValue) {
		if(parser.parsingTracks && parser.dictionaryLevel == 3) {
			[[parser delegate] musicLibraryParser:parser parsedTrackProperty:[parser lastKeyString] value:nil];
		}
		
		if(parser.parsingPlaylists && parser.dictionaryLevel == 2) {
			[[parser delegate] musicLibraryParser:parser parsedPlaylistProperty:[parser lastKeyString] value:nil];
		}
	}
}

static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len) {
	MPMediaLibraryParser* parser = (__bridge MPMediaLibraryParser*)ctx;
	[[parser characterBuffer] appendBytes:ch length:len];
}

static xmlEntityPtr getEntitySAX(void * ctx, const xmlChar * name) {
    return xmlGetPredefinedEntity(name);
}

static void warningEncounteredSAX(void * ctx, const char * msg, ...) {
	va_list args;

	va_start(args, msg);
	printf(msg, args);
	va_end(args);
}

static void errorEncounteredSAX(void * ctx, const char * msg, ...) {
	va_list args;

	va_start(args, msg);
	printf(msg, args);
	va_end(args);
}

// The handler struct has positions for a large number of callback functions. If NULL is supplied at a given position,
// that callback functionality won't be used. Refer to libxml documentation at http://www.xmlsoft.org for more information
// about the SAX callbacks.
static xmlSAXHandler simpleSAXHandlerStruct = {
    NULL,                       /* internalSubset */
    NULL,                       /* isStandalone   */
    NULL,                       /* hasInternalSubset */
    NULL,                       /* hasExternalSubset */
    NULL,                       /* resolveEntity */
    getEntitySAX,               /* getEntity */
    NULL,                       /* entityDecl */
    NULL,                       /* notationDecl */
    NULL,                       /* attributeDecl */
    NULL,                       /* elementDecl */
    NULL,                       /* unparsedEntityDecl */
    NULL,                       /* setDocumentLocator */
    NULL,                       /* startDocument */
    NULL,                       /* endDocument */
    NULL,                       /* startElement*/
    NULL,                       /* endElement */
    NULL,                       /* reference */
    charactersFoundSAX,         /* characters */
    NULL,                       /* ignorableWhitespace */
    NULL,                       /* processingInstruction */
    NULL,                       /* comment */
    warningEncounteredSAX,      /* warning */
    errorEncounteredSAX,        /* error */
    errorEncounteredSAX,        /* fatalError //: unused error() get all the errors */
    NULL,                       /* getParameterEntity */
    NULL,                       /* cdataBlock */
    NULL,                       /* externalSubset */
    XML_SAX2_MAGIC,             //
    NULL,
    startElementSAX,            /* startElementNs */
    endElementSAX,              /* endElementNs */
    NULL,                       /* serror */
};

@end
