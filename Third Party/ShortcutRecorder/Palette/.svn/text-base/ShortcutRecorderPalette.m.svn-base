//
//  ShortcutRecorderPalette.m
//  ShortcutRecorder
//
//  Copyright 2006 Contributors. All rights reserved.
//
//  License: BSD
//
//  Contributors:
//      David Dauer
//
//  Revisions:
//      2006-03-19 Created.

#import "ShortcutRecorderPalette.h"

@implementation ShortcutRecorderPalette

- (void)finishInstantiate
{	
	[super finishInstantiate];
}

@end

@implementation ShortcutRecorder (ShortcutRecorderPaletteInspector)

- (NSString *)inspectorClassName
{
    return @"ShortcutRecorderInspector";
}

@end

@implementation ShortcutRecorder (ShortcutRecorderIBAdditions)

- (NSSize)minimumFrameSizeFromKnobPosition:(IBKnobPosition)position
{
	return NSMakeSize(SRMinWidth, 17.0); // Limit width and height
}

- (NSSize)maximumFrameSizeFromKnobPosition:(IBKnobPosition)knobPosition
{
	return NSMakeSize(IB_BIG_SIZE, SRMaxHeight); // Allow maximum width but limit height
}

- (BOOL)allowsAltDragging
{
	return NO; // Since current cell implementation seems to be buggy
}

@end

@implementation ShortcutRecorderCell (ShortcutRecorderCellIBAdditions)

- (void)_saveKeyCombo
{
	// We don't want to save in IB...
}

- (void)_loadKeyCombo
{
	// ...and neither load the combo.
}

@end