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

#import "MusicLibraryItem.h"

/*!
    @class		 MusicLibraryArtist
    @abstract    <#(brief description)#>
    @discussion  <#(comprehensive description)#>
*/
@interface MusicLibraryArtist : MusicLibraryItem<NSCopying> {
@private
	NSString* _name;
	
	NSMutableArray* _tracks;
	NSMutableArray* _albums;
	
	BOOL _needsTrackOrdering;
}

@property(nonatomic, readonly, strong) NSString* persistentID;

@property(nonatomic, readonly, strong) NSString* name;
@property(unsafe_unretained, readonly) NSString* displayName;

@property(nonatomic, readonly, strong) NSArray* albums;
@property(nonatomic, readonly, strong) NSArray* tracks;

@end
