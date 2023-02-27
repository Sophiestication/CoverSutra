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

#import "NSString+iTunesRating.h"

@implementation NSString(iTunesRating)

+ (NSString*)stringWithUserRating:(NSInteger)userRating {
	if(userRating >= 100) {
		return @"★★★★★";
	} else if(userRating >= 90) {
		return @"★★★★½";
	} else if(userRating >= 80) {
		return @"★★★★";
	} else if(userRating >= 70) {
		return @"★★★½";
	} else if(userRating >= 60) {
		return @"★★★";
	} else if(userRating >= 50) {
		return @"★★½";
	} else if(userRating >= 40) {
		return @"★★";
	} else if(userRating >= 30) {
		return @"★½";
	} else if(userRating >= 20) {
		return @"★";
	} else if(userRating >= 10) {
		return @"½";
	}
	
	return @"";
}

+ (NSString*)stringWithComputedUserRating:(NSInteger)computedUserRating {
	if(computedUserRating >= 100) {
		return @"☆☆☆☆☆";
	} else if(computedUserRating >= 90) {
		return @"☆☆☆☆½";
	} else if(computedUserRating >= 80) {
		return @"☆☆☆☆";
	} else if(computedUserRating >= 70) {
		return @"☆☆☆½";
	} else if(computedUserRating >= 60) {
		return @"☆☆☆";
	} else if(computedUserRating >= 50) {
		return @"☆☆½";
	} else if(computedUserRating >= 40) {
		return @"☆☆";
	} else if(computedUserRating >= 30) {
		return @"☆½";
	} else if(computedUserRating >= 20) {
		return @"☆";
	} else if(computedUserRating >= 10) {
		return @"½";
	}
	
	return @"";
}

@end
