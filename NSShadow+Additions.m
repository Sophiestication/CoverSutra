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

#import "NSShadow+Additions.h"

@implementation NSShadow(CoverSutraAdditions)

+ (NSShadow*)HUDImageShadow {
	static NSShadow* _HUDImageShadow = nil;
	
	if(!_HUDImageShadow) {
		NSShadow* shadow = [[NSShadow alloc] init];
		
		[shadow setShadowOffset:NSMakeSize(0.0, -1.0)];
		[shadow setShadowBlurRadius:1.0];		
		[shadow setShadowColor:[NSColor shadowColor]];
		
		_HUDImageShadow = shadow;
	}
	
	return _HUDImageShadow;
}

+ (NSShadow*)navigationBarImageShadow {
	static NSShadow* _navigationBarImageShadow = nil;
	
	if(!_navigationBarImageShadow) {
		NSShadow* shadow = [[NSShadow alloc] init];
		
		[shadow setShadowOffset:NSMakeSize(0.0, 1.0)];
		[shadow setShadowBlurRadius:1.0];
		
		[shadow setShadowColor:
			[NSColor colorWithCalibratedWhite:0.0 alpha:0.75]];
		
		_navigationBarImageShadow = shadow;
	}
	
	return _navigationBarImageShadow;
}

+ (NSShadow*)desktopTextShadow {
	static NSShadow* _desktopTextShadow = nil;
	
	if(!_desktopTextShadow) {
		_desktopTextShadow = [[NSShadow alloc] init];
		
		[_desktopTextShadow setShadowOffset:
			NSMakeSize(1.0, -1.5)];
		[_desktopTextShadow setShadowBlurRadius:2.0];
		
		[_desktopTextShadow setShadowColor:
			[NSColor shadowColor]];
	}
	
	return _desktopTextShadow;
}

+ (NSShadow*)bezelTextShadow {
	static NSShadow* _bezelTextShadow = nil;
	
	if(!_bezelTextShadow) {
		_bezelTextShadow = [[NSShadow alloc] init];
		
		[_bezelTextShadow setShadowOffset:
			NSMakeSize(0.0, -1.0)];
		[_bezelTextShadow setShadowBlurRadius:2.0];
		
		[_bezelTextShadow setShadowColor:
			[NSColor shadowColor]];
	}
	
	return _bezelTextShadow;
}

+ (NSShadow*)searchMenuItemTextShadow {
	static NSShadow* _searchMenuItemTextShadow = nil;
	
	if(!_searchMenuItemTextShadow) {
		_searchMenuItemTextShadow = [[NSShadow alloc] init];
		
		[_searchMenuItemTextShadow setShadowOffset:
			NSMakeSize(0.0, -1.0)];
		[_searchMenuItemTextShadow setShadowBlurRadius:1.0];
		
		[_searchMenuItemTextShadow setShadowColor:
			[NSColor shadowColor]];
	}
	
	return _searchMenuItemTextShadow;
}

@end
