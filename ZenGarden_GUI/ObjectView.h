//
//  ObjectView.h
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LetView.h"
#import "TextView.h"


@interface ObjectView : NSView <NSTextFieldDelegate> {
  
  float numberOfInlets;
  float numberOfOutlets;
  LetView *letView;
  NSMutableArray *letArray;
  
  TextView *textView;
  
  NSRect objectResizeTrackingRect;
  NSTrackingArea *objectResizeTrackingArea;
  NSCursor *cursor;
  
  NSColor *backgroundColour;
  BOOL isHighlighted;
  
@private
    
}

@property (nonatomic, readonly) NSMutableArray *letArray;

- (void)drawBackground:(NSRect)rect;
- (void)highlightObject:(BOOL)state;
- (void)addTextView:(NSRect)rect;
- (void)drawTextView:(NSRect)rect;
- (void)addTextField:(NSRect)rect;
- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)isInlet isSignal:(BOOL)isSignal;
- (void)letMouseDown:(NSPoint)location;
- (void)addObjectResizeTrackingRect:(NSRect)rect;
- (NSPoint)positionInsideObject:(NSPoint)fromEventPosition;

@end
