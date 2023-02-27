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

#import "MusicLibraryTrack.h"

#import "iTunesAPI.h"

@interface MusicLibraryTrackAdapter : MusicLibraryTrack {
@private
	iTunesTrack* _scriptingObject;
	iTunesPlaylist* _playlistScriptingObject;
	iTunesSource* _sourceScriptingObject;
	BOOL _shared;
	BOOL _streamed;
}

+ (MusicLibraryTrackAdapter*)adapterForScriptingObject:(iTunesTrack*)scriptingObject;
+ (MusicLibraryTrackAdapter*)adapterForPlayerNotification:(NSNotification*)playerNotification;

@property(readwrite, strong) iTunesTrack* scriptingObject;
@property(readwrite, strong) iTunesPlaylist* playlistScriptingObject;
@property(readwrite, strong) iTunesSource* sourceScriptingObject;

@property(readwrite, getter=isShared) BOOL shared;
@property(readwrite, getter=isStreamed) BOOL streamed;

- (void)refresh;
- (void)refreshStream;

@end
