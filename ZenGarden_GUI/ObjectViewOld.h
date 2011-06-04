//
//  ObjectView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
#import <Cocoa/Cocoa.h>
#import "ZenGarden.h"
#import "TextView.h"
#import "InletView.h"
#import "OutletView.h"


@interface ObjectView : NSView <NSTextViewDelegate> {
  
   
  ZGObject *zgObject;
  TextView *textView;
  InletView *inletView;
  OutletView *outletView;
  
  NSMutableArray *inletArray;
  NSMutableArray *outletArray;

  NSPoint updatedFrameOrigin;
  NSPoint connectionStartPoint;
  
  BOOL isObjectInstantiated;
  NSColor *objectBackgroundColour;
  
}

- (void)drawBackground:(NSRect)frame;

- (void)drawTextView:(NSRect)frame;

- (void)drawInlet:(NSRect)frame;

- (void)drawOutlet:(NSRect)frame;

- (void)instantiateObject:(ZGObject *)objectLabel;

- (void)isEditable:(BOOL)editState;

- (void)highlightObject;

- (BOOL)isObjectHighlighted;

- (void)showInletOutletCursor:(BOOL)isCursorAtInletOutlet;

- (void)setConnectionStartPoint:(NSPoint)location;

@property (nonatomic, readonly) BOOL isObjectInstantiated;

@end
*/