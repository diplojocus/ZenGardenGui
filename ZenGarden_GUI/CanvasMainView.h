//
//  CanvasMainView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ObjectView.h"
//#import "ZenGarden.h"
//#import "PdAudio.h"


@interface CanvasMainView : NSView <ObjectViewDelegate> {

  // Object
  ObjectView *objectView;
  ObjectView *objectToMove;
  NSPoint mousePositionInsideObject;
  NSMutableArray *arrayOfObjects;
  BOOL resizeObject;
  BOOL moveObject;
  
  // Selection Rectangle
  NSPoint selectionStartPoint;
  NSRect selectionRect;
  NSBezierPath *selectionPath;
  BOOL drawSelectionRectangle;
  int selectedObjectsCount;
  
  // Connections
  NSPoint newConnectionStartPoint;
  NSPoint newConnectionEndPoint;
  BOOL drawConnection;
  
  NSMenuItem *editToggleMenuItem;
}

@property (nonatomic, readonly) IBOutlet NSMenuItem *editToggleMenuItem;
@property (nonatomic, readonly) BOOL isEditModeOn;

- (BOOL)isEditModeOn;

- (IBAction)toggleEditMode:(id)sender;

- (IBAction)removeObject:(id)sender;

- (IBAction)putObject:(id)sender;

- (IBAction)removeObject:(id)sender;

- (void)resetDrawingSelectors;

- (void)moveObject:(ObjectView *)object with:(NSPoint)adjustedMousePosition;

- (void)startConnectionDrawing:(NSPoint)point;

- (void)drawBackground:(NSRect)rect;

- (void)drawSelectionRectangle:(NSPoint)startPoint toLocation:(NSPoint)endPoint;

- (NSRect)rectFromTwoPoints:(NSPoint)firstPoint toLocation:(NSPoint)secondPoint;

- (NSPoint)invertYAxis:(NSPoint)point;

@end
