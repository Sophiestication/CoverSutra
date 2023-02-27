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

#import "LastDotFMHandshake.h"

/*!
    @class		 LastDotFMHandshake(Private)
    @abstract    (brief description)
    @discussion  (comprehensive description)
*/
@interface LastDotFMHandshake(Private)

- (NSURLConnection*)_URLConnection;
- (void)_setURLConnection:(NSURLConnection*)connection;

- (void)_handleOK:(NSArray*)response;
- (void)_handleBANNED:(NSArray*)response;
- (void)_handleBADAUTH:(NSArray*)response;
- (void)_handleBADTIME:(NSArray*)response;
- (void)_handleFAILED:(NSArray*)response;
- (void)_handleHardFailure:(NSArray*)response;

- (int)_scanInterval:(NSString*)string;
- (NSString*)_scanUpdateURLString:(NSString*)string;
- (NSString*)_scanFailureReason:(NSString*)string;

@end
