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

#import <Cocoa/Cocoa.h>

#import "SCLauncher.h"

int main (int argc, const char * argv[]) {
	@autoreleasepool {

		NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
		
		// Save some memory by disabled the URL cache
		[[NSURLCache sharedURLCache] setDiskCapacity:0];
		[[NSURLCache sharedURLCache] setMemoryCapacity:0];

		// Make a new launcher
		SCLauncher* launcher = [[SCLauncher alloc] init];

		// and wait for input events
		while(1) {
			BOOL keepRunning = [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]; // Wait for input events

			if(!keepRunning || launcher.needsToTerminateAgent) {
				break;
			}
		}
		
	}

    return 0;
}
