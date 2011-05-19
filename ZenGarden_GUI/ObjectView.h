//
//  ObjectView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "InletView.h"
#import "ZenGarden.h"


@interface ObjectView : NSView <NSTextFieldDelegate> {
  
   
  ZGObject *zgObject;
  NSTextField *textField;
  NSMutableArray *inletArray;
  NSMutableArray *outletArray;

  NSPoint updatedFrameOrigin;
  
  BOOL isObjectInstantiated;
  NSColor *objectBackgroundColour;
  
}

- (void)drawInlet:(NSRect)frame;

- (void)drawOutlet:(NSRect)frame;

- (void)drawBackground:(NSRect)frame;

- (void)drawTextField:(NSRect)frame;

- (void)instantiateObject:(BOOL)selector;

- (void)highlightObject;

- (BOOL)isObjectHighlighted;

@end
