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

#import "SkinController.h"
#import "SkinController+Private.h"

#import "Skin.h"

#import "CoverSutra.h"

#import "Utilities.h"

@implementation SkinController

- (id)init {
	if(![super initWithContent:[self _skins]]) {
		return nil;
	}
	
	[self performSelector:@selector(_initFromUserDefaults)
		withObject:nil
		afterDelay:0.0];
	
	return self;
}

- (Skin*)jewelcaseSkin {
	return [self _skinForIdentifier:@"com.sophiestication.mac.CoverSutra.jewelcase"];
}

- (Skin*)jewelboxingSkin {
	return [self _skinForIdentifier:@"com.sophiestication.mac.CoverSutra.jewelboxing"];
}

- (Skin*)vinylSkin {
	return [self _skinForIdentifier:@"com.sophiestication.mac.CoverSutra.vinyl"];
}

- (BOOL)jewelcaseSelected {
	return [[self selectedObjects]
		containsObject:[self jewelcaseSkin]];
}

- (void)setJewelcaseSelected:(BOOL)selected {
	if(selected) {
		[self setSelectedObjects:
			[NSArray arrayWithObject:[self jewelcaseSkin]]];
			
		[self setJewelboxingSelected:NO];
		[self setVinylSelected:NO];
		
		[[NSUserDefaultsController sharedUserDefaultsController]
			setValue:[[self jewelcaseSkin] identifier]
			forKeyPath:@"values.albumCase"];
	} else {
		[self removeSelectedObjects:
			[NSArray arrayWithObject:[self jewelcaseSkin]]];
	}
}

- (BOOL)jewelboxingSelected {
	return [[self selectedObjects]
		containsObject:[self jewelboxingSkin]];
}

- (void)setJewelboxingSelected:(BOOL)selected {
	if(selected) {
		[self setSelectedObjects:
			[NSArray arrayWithObject:[self jewelboxingSkin]]];
			
		[self setJewelcaseSelected:NO];
		[self setVinylSelected:NO];
		
		[[NSUserDefaultsController sharedUserDefaultsController]
			setValue:[[self jewelboxingSkin] identifier]
			forKeyPath:@"values.albumCase"];
	} else {
		[self removeSelectedObjects:
			[NSArray arrayWithObject:[self jewelboxingSkin]]];
	}
}

- (BOOL)vinylSelected {
	return [[self selectedObjects]
		containsObject:[self vinylSkin]];
}

- (void)setVinylSelected:(BOOL)selected {
	if(selected) {
		[self setSelectedObjects:
			[NSArray arrayWithObject:[self vinylSkin]]];
			
		[self setJewelboxingSelected:NO];
		[self setJewelcaseSelected:NO];
		
		[[NSUserDefaultsController sharedUserDefaultsController]
			setValue:[[self vinylSkin] identifier]
			forKeyPath:@"values.albumCase"];
	} else {
		[self removeSelectedObjects:
			[NSArray arrayWithObject:[self vinylSkin]]];
	}
}

- (id)_skins {
	NSEnumerator* plugInFolders = [[[CoverSutra self] applicationPlugInFolders] objectEnumerator];
	NSString* plugInFolder = nil;
	
	NSMutableArray* skins = [NSMutableArray array];
	
	while(plugInFolder = [plugInFolders nextObject]) {
		NSString* skinFolder = plugInFolder; // [plugInFolder stringByAppendingPathComponent:@"Skins"];
		
		NSArray* files = [[NSFileManager defaultManager]
			contentsOfDirectoryAtPath:skinFolder
			error:nil];
		
		for(NSString* file in files) {
/*
			NSError* error = nil;
			
			NSString* fileUTI = [[NSWorkspace sharedWorkspace]
				typeOfFile:[skinFolder stringByAppendingPathComponent:file]
				error:&error];
			
			if([[NSWorkspace sharedWorkspace] type:fileUTI conformsToType:@"com.sophiestication.album-cover-style"]) {
				Skin* skin = [Skin skinWithContentsOfFile:[skinFolder stringByAppendingPathComponent:file]];
				
				if(skin) {
					[skins addObject:skin];
				}
			}
		}
*/
			if(EqualStrings([file pathExtension], @"coversutraSkin")) {
				Skin* skin = [Skin skinWithContentsOfFile:[skinFolder stringByAppendingPathComponent:file]];
				
				if(skin) {
					[skins addObject:skin];
				}
			}
		}
	}
	
	return skins;
}

- (Skin*)_skinForIdentifier:(id)identifier {
	id skins = [self content];
	
	unsigned numberOfSkins = [skins count];
	unsigned skinIndex = 0;
	
	for(; skinIndex < numberOfSkins; ++skinIndex) {
		Skin* skin = [skins objectAtIndex:skinIndex];
		
		if(EqualStrings([skin identifier], identifier)) {
			return skin;
		}
	}
	
	return nil;
}

- (void)_initFromUserDefaults {
	id identifier = [[NSUserDefaultsController sharedUserDefaultsController]
		valueForKeyPath:@"values.albumCase"];
		
	Skin* selectedSkin = [self _skinForIdentifier:identifier];
	
	if(!selectedSkin) {
		selectedSkin = [self jewelboxingSkin];
	}
	
	[self setSelectedObjects:
		[NSArray arrayWithObject:selectedSkin]];
}

@end
