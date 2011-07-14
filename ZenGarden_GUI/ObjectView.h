//
//  ObjectView.h
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "LetView.h"
#import "ZenGarden.h"

//@class ZGObject;

@protocol ObjectViewDelegate

- (ZGObject *)addNewObjectToGraphWithInitString:(NSString *)initString withLocation:(NSPoint)location;

@end

@interface ObjectView : NSView <NSTextFieldDelegate, LetViewDelegate> {

  // Delegate
  NSObject <ObjectViewDelegate> *delegate;
  
  // Lets
  float numberOfInlets;
  float numberOfOutlets;
  LetView *letView;
  LetView *letMouseDown;
  NSMutableArray *letArray;
  
  BOOL isLetMouseDown;
  
  // Textfield
  NSTextField *textField;
  
  // Tracking Rectangles
  NSRect objectResizeTrackingRect;
  NSTrackingArea *objectResizeTrackingArea;
  NSCursor *cursor;
  
  // Background
  BOOL isHighlighted;
  NSColor *backgroundColour;
  
  // ZenGarden
  ZGObject *zgObject;
}

@property (nonatomic, readonly) NSMutableArray *letArray;
@property (nonatomic, readonly) BOOL isHighlighted;
@property (nonatomic, readonly) BOOL isLetMouseDown;

- (id)initWithFrame:(NSRect)frame delegate:(NSObject<ObjectViewDelegate> *)aDelegate;

- (void)drawBackground:(NSRect)rect;

- (void)highlightObject:(BOOL)state;

- (void)addTextField:(NSRect)rect;

- (void)setTextFieldEditable:(BOOL)state;

- (void)addLet:(NSPoint)letOrigin isInlet:(BOOL)isInlet isSignal:(BOOL)isSignal;

- (void)setLetMouseDown:(LetView *)let withState:(BOOL)state;

- (void)addObjectResizeTrackingRect:(NSRect)rect;

- (NSPoint)positionInsideObject:(NSPoint)fromEventPosition;

@end
