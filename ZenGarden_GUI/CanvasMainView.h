//
//  CanvasMainView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ObjectView.h"
#import "ZenGarden.h"
#import "PdAudio.h"


@interface CanvasMainView : NSView {

  // Canvas
  BOOL isEditModeOn;
  // NSCursor *currentCursorState;

  // Object
  ObjectView *objectView;
  ObjectView *objectToMove;
  NSMutableArray *arrayOfObjects;
  BOOL resizeObject;
  BOOL moveObject;
  
  // Selection Rectangle
  NSPoint selectionStartPoint;
  NSRect selectionRect;
  NSBezierPath *selectionPath;
  BOOL drawSelectionRectangle;
  
  // Connections
  NSPoint connectionStartPoint;
  NSPoint connectionEndPoint;
  BOOL drawConnection;
  
}

- (IBAction)toggleEditMode:(id)sender;
- (IBAction)putObject:(id)sender;
- (NSPoint)invertYAxis:(NSPoint)point;
- (void)resetDrawingSelectors;
- (void)moveObject:(ObjectView *)object;
- (void)startConnectionDrawing:(NSPoint)point;
- (void)drawConnection:(NSPoint)startPoint toLocation:(NSPoint)endPoint;
- (void)drawBackground:(NSRect)rect;
- (void)drawSelectionRectangle:(NSPoint)startPoint toLocation:(NSPoint)endPoint;
- (NSRect)rectFromTwoPoints:(NSPoint)firstPoint toLocation:(NSPoint)secondPoint;

@end
