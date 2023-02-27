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

#import "ShortcutController+Private.h"

#import "Shortcut.h"
#import "Shortcut+Private.h"
#import "ShortcutEvent.h"
#import "KeyCombination.h"

@implementation ShortcutController(Private)

- (Shortcut*)_shortcutForCarbonHotKey:(EventHotKeyRef)carbonHotKey {
	NSValue* key = [NSValue valueWithPointer:carbonHotKey];
	return [_enabledShortcuts objectForKey:key];
}

- (NSValue*)_carbonHotKeyForShortcut:(Shortcut*)shortcut {
	return [[_enabledShortcuts allKeysForObject:shortcut] lastObject];
}

- (void)_readFromUserDefaults {
	id shortcuts = [[NSUserDefaultsController sharedUserDefaultsController]
		valueForKeyPath:@"values.globalShortcuts"];
	NSEnumerator* shortcutIdentifiers = [[shortcuts allKeys] objectEnumerator];
	NSString* shortcutIdentifier = nil;
	
	while(shortcutIdentifier = [shortcutIdentifiers nextObject]) {
		Shortcut* shortcut = [self shortcutForIdentifier:shortcutIdentifier];
		
		if(shortcut) {
			id keys = [shortcuts objectForKey:shortcutIdentifier];
		
			KeyCombination* keyCombination = [KeyCombination keyCombinationWithKeyCode:
				[[keys valueForKey:@"keyCode"] shortValue]
				modifiers:[[keys valueForKey:@"modifiers"] unsignedIntValue]];

			[shortcut setKeyCombination:keyCombination];
		}
	}
}

- (void)_writeToUserDefaults {
	unsigned numberOfShortcuts = [_shortcuts count];
	unsigned shortcutIndex = 0;
	
	NSMutableDictionary* shortcuts = [NSMutableDictionary dictionaryWithCapacity:numberOfShortcuts];
	
	for(; shortcutIndex < numberOfShortcuts; ++shortcutIndex) {
		Shortcut* shortcut = [_shortcuts objectAtIndex:shortcutIndex];
		KeyCombination* keyCombination = [shortcut keyCombination];
		
		if(!keyCombination || [keyCombination isEmpty]) {
			continue;
		}
		
		NSDictionary* keys = [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithUnsignedInt:[keyCombination modifiers]], @"modifiers",
			[NSNumber numberWithShort:[keyCombination keyCode]], @"keyCode",
			nil];
		
		[shortcuts setValue:keys forKey:[shortcut identifier]];
	}
	
	[[NSUserDefaultsController sharedUserDefaultsController] setValue:shortcuts forKeyPath:@"values.globalShortcuts"];
}

- (void)_updateShortcut:(Shortcut*)shortcut {
	if(![self shortcutsEnabled]) {
		return;
	}
	
	if(![self shortcutForIdentifier:[shortcut identifier]]) {
		return;
	}
	
	KeyCombination* keyCombination = [shortcut keyCombination];
	NSValue* carbonHotKey = [self _carbonHotKeyForShortcut:shortcut];
	
	if(carbonHotKey) {
		OSStatus result = UnregisterEventHotKey((EventHotKeyRef)[carbonHotKey pointerValue]);
	
		if(result != noErr) { // TODO
		}
		
		[_enabledShortcuts removeObjectForKey:carbonHotKey];
	}
	
	if(!keyCombination || [keyCombination isEmpty]) {
		return;
	}
	
	EventHotKeyID hotKeyID;
	
	hotKeyID.signature = 'CSHk';
	
	NSNumber* eventIdentifier = [[_shortcutEventIdentifier allKeysForObject:shortcut] lastObject];
	hotKeyID.id = [eventIdentifier unsignedLongValue];
	
	EventHotKeyRef eventHotKeyRef;
	
	OSStatus result = RegisterEventHotKey(
		[keyCombination keyCode],
		[keyCombination carbonModifiers],
		hotKeyID,
		GetEventDispatcherTarget(),
		0,
		&eventHotKeyRef);

	if(result != noErr) {
		NSLog(@"Could not install global shortcut");
		return;
	}

	carbonHotKey = [NSValue valueWithPointer:eventHotKeyRef];
	[_enabledShortcuts setObject:shortcut forKey:carbonHotKey];

	[self _updateEventHandler];
}

- (void)_updateEventHandler {
	if(!_eventHandlerInstalled && [_enabledShortcuts count] > 0) {
		EventTypeSpec eventSpec[2] = {
			{ kEventClassKeyboard, kEventHotKeyPressed },
			{ kEventClassKeyboard, kEventHotKeyReleased }
		};    

		OSStatus err = InstallEventHandler(
			GetEventDispatcherTarget(),
			(EventHandlerProcPtr)hotKeyEventHandler, 
			2, eventSpec,
			nil,
			nil);
			
		if(err) {
			// TODO
		}
	
		_eventHandlerInstalled = YES;
	}
}

- (void)_setShortcutsEnabled:(BOOL)shortcutsEnabled {
	if(shortcutsEnabled) {
		NSArray* shortcuts = [self allShortcuts];
	
		unsigned numberOfShortcuts = [shortcuts count];
		unsigned shortcutIndex = 0;
	
		for(; shortcutIndex < numberOfShortcuts; ++shortcutIndex) {
			[self _updateShortcut:[shortcuts objectAtIndex:shortcutIndex]];
		}
	} else {
		NSArray* carbonHotKeys = [_enabledShortcuts allKeys];
	
		unsigned numberOfCarbonHotkeys = [carbonHotKeys count];
		unsigned carbonHotKeyIndex = 0;
	
		for(; carbonHotKeyIndex < numberOfCarbonHotkeys; ++carbonHotKeyIndex) {
			NSValue* carbonHotKey = [carbonHotKeys objectAtIndex:carbonHotKeyIndex];
			OSStatus result = UnregisterEventHotKey((EventHotKeyRef)[carbonHotKey pointerValue]);
	
			if(result != noErr) { // TODO
			}

			[_enabledShortcuts removeObjectForKey:carbonHotKey];
		}
	}
}

- (void)sendEvent:(NSEvent*)event {
	if(![self shortcutsEnabled]) {
		return;
	}
	
	long subType;
	EventHotKeyRef carbonHotKey;
	
	if([event type] == NSSystemDefined) {
		subType = [event subtype];
		
		if(subType == 6) { // 6 is hot key down
			carbonHotKey = (EventHotKeyRef)[event data1]; // data1 is our hot key ref
			
			if(carbonHotKey != nil) {
				Shortcut* shortcut = [self _shortcutForCarbonHotKey:carbonHotKey];
				ShortcutEvent* shortcutEvent = [ShortcutEvent
					shortcutEventWithType:NSKeyDown
					timestamp:[event timestamp]
					shortcut:shortcut];
				[self sendShortcutEvent:shortcutEvent];
			}
		} else if(subType == 9) { // 9 is hot key up
			carbonHotKey= (EventHotKeyRef)[event data1];
			
			if(carbonHotKey != nil) {
				Shortcut* shortcut = [self _shortcutForCarbonHotKey:carbonHotKey];
				ShortcutEvent* shortcutEvent = [ShortcutEvent
					shortcutEventWithType:NSKeyUp
					timestamp:[event timestamp]
					shortcut:shortcut];
				[self sendShortcutEvent:shortcutEvent];
			}
		}
	}
}

- (void)sendShortcutEvent:(ShortcutEvent*)shortcutEvent {
	Shortcut* shortcut = [shortcutEvent shortcut];
	
	if([shortcutEvent type] == NSKeyDown) {
		[shortcut _setCurrentShortcutDownEvent:shortcutEvent];
	} else if([shortcutEvent type] == NSKeyUp) {
		[shortcut _setCurrentShortcutUpEvent:shortcutEvent];
	}
	
	SEL selector = NSSelectorFromString([NSString stringWithFormat:@"%@:", [shortcut identifier]]);
	
	BOOL performed = [NSApp tryToPerform:selector
		with:shortcutEvent];
	
	if(!performed) {
		if([shortcutEvent type] == NSKeyUp) {
			[[NSApplication sharedApplication]
				tryToPerform:@selector(shortcutUp:)
				with:shortcutEvent];
		} else {
			[[NSApplication sharedApplication]
				tryToPerform:@selector(shortcutDown:)
				with:shortcutEvent];
		}
	}
}

- (OSStatus)sendCarbonEvent:(EventRef)event {
	NSAssert(GetEventClass(event) == kEventClassKeyboard, @"Unknown event class");
	
	EventHotKeyID hotKeyID;
	OSStatus err = GetEventParameter(
		event,
		kEventParamDirectObject, 
		typeEventHotKeyID,
		NULL,
		sizeof(EventHotKeyID),
		NULL,
		&hotKeyID);

	if(err) {
		return err;
	}

	NSAssert(hotKeyID.signature == 'CSHk', @"Invalid hot key id");
	NSAssert(hotKeyID.id != 0, @"Invalid hot key id");

	Shortcut* shortcut = [_shortcutEventIdentifier objectForKey:
		[NSNumber numberWithUnsignedLong:hotKeyID.id]];
	ShortcutEvent* shortcutEvent = nil;

	switch(GetEventKind(event)) {
		case kEventHotKeyPressed:
			shortcutEvent = [ShortcutEvent shortcutEventWithType:NSKeyDown
				timestamp:GetEventTime(event)
				shortcut:shortcut];
			[self sendShortcutEvent:shortcutEvent];
		break;

		case kEventHotKeyReleased:
			shortcutEvent = [ShortcutEvent shortcutEventWithType:NSKeyUp
				timestamp:GetEventTime(event)
				shortcut:shortcut];
			[self sendShortcutEvent:shortcutEvent];
		break;

		default:
			NSAssert(0, @"Unknown event kind");
		break;
	}
	
	return noErr;
}

OSStatus hotKeyEventHandler(EventHandlerCallRef inHandlerRef, EventRef inEvent, void* refCon) {
	if(![[ShortcutController sharedShortcutController] shortcutsEnabled]) {
		return noErr;
	}
	
	return [[ShortcutController sharedShortcutController] sendCarbonEvent:inEvent];
}


@end
