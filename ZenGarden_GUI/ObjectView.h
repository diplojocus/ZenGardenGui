//
//  ObjectView.h
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LetView.h"


@interface ObjectView : NSView <NSTextFieldDelegate> {
  
  float numberOfInlets;
  float numberOfOutlets;
  LetView *letView;
  LetView *letMouseDown;
  
  NSTextField *textField;
  
  NSRect objectResizeTrackingRect;
  NSTrackingArea *objectResizeTrackingArea;
  NSCursor *cursor;
  
  NSColor *backgroundColour;
  
@private
    
}

@property (nonatomic, readonly) NSMutableArray *letArray;
@property (nonatomic, readonly) BOOL isHighlighted;
@property (nonatomic, readonly) BOOL isLetMouseDown;

- (void)drawBackground:(NSRect)rect;
- (void)highlightObject:(BOOL)state;
- (void)addTextField:(NSRect)rect;
- (void)setTextFieldEditable:(BOOL)state;
- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)isInlet isSignal:(BOOL)isSignal;
- (void)setLetMouseDown:(LetView *)let withState:(BOOL)state;
- (void)addObjectResizeTrackingRect:(NSRect)rect;
- (NSPoint)positionInsideObject:(NSPoint)fromEventPosition;

@end
