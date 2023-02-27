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

@interface MPMediaLibraryParser()

@property(nonatomic) BOOL parsingKey;
@property(nonatomic) BOOL parsingStringValue;
@property(nonatomic) BOOL parsingIntegerValue;
@property(nonatomic) BOOL parsingDateValue;
@property(nonatomic) BOOL parsingBooleanValue;
@property(nonatomic) BOOL parsingDataValue;
@property(nonatomic) BOOL parsingDictionary;
@property(nonatomic) BOOL parsingTrack;
@property(nonatomic) BOOL parsingTracks;
@property(nonatomic) BOOL parsedTracks;
@property(nonatomic) BOOL parsingTracksDictionary;
@property(nonatomic) BOOL parsingPlaylists;
@property(nonatomic) BOOL parsingPlaylistsDictionary;
@property(nonatomic) BOOL parsedPlaylists;
@property(nonatomic) BOOL parsingPlaylist;

@property(nonatomic) NSUInteger dictionaryLevel;
@property(nonatomic) NSUInteger arrayLevel;

@property(nonatomic, strong) NSMutableData* characterBuffer;
@property(nonatomic, strong) NSString* characters;
@property(unsafe_unretained, nonatomic, readonly) NSString* bufferString;
@property(nonatomic, strong) NSString* lastKeyString;

// Function prototypes for SAX callbacks. This sample implements a minimal subset of SAX callbacks.
// Depending on your application's needs, you might want to implement more callbacks.
static void startElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI, int nb_namespaces, const xmlChar **namespaces, int nb_attributes, int nb_defaulted, const xmlChar **attributes);
static void	endElementSAX(void *ctx, const xmlChar *localname, const xmlChar *prefix, const xmlChar *URI);
static void	charactersFoundSAX(void * ctx, const xmlChar * ch, int len);
static void errorEncounteredSAX(void * ctx, const char * msg, ...);

@end
