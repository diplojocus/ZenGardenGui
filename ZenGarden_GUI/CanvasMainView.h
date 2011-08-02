//
//  CanvasMainView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ObjectView.h"
#import "BangView.h"
#import "ZenGarden.h"
#import "PdAudio.h"


@interface CanvasMainView : NSView <ObjectViewDelegate, BangViewDelegate> {

  // Keywords (joewhite4:probably not the correct place to put it)
  NSMutableArray *allObjectLabels;
  NSMutableArray *builtInObjectLabels;
  
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
  float newConnectionLineWidth;
  NSPoint newConnectionStartPoint;
  NSPoint newConnectionEndPoint;
  BOOL drawNewConnection;
  
  NSMenuItem *editToggleMenuItem;
  
  BOOL isEditModeOn;
  
  // ZenGarden/PdAudio
  ZGGraph *zgGraph;
  PdAudio *pdAudio;
}

@property (nonatomic, readonly) IBOutlet NSMenuItem *editToggleMenuItem;
@property (nonatomic, readonly) BOOL isEditModeOn;
@property (nonatomic, readonly) ZGGraph *zgGraph;

- (IBAction)toggleEditMode:(id)sender;

- (IBAction)removeObject:(id)sender;

- (IBAction)putObject:(id)sender;

- (IBAction)addBang:(id)sender;

- (IBAction)removeObject:(id)sender;

- (void)resetDrawingSelectors;

- (void)moveObject:(ObjectView *)object with:(NSPoint)adjustedMousePosition;

- (void)drawBackground:(NSRect)rect;

- (void)drawSelectionRectangle:(NSPoint)startPoint toLocation:(NSPoint)endPoint;

- (NSRect)rectFromTwoPoints:(NSPoint)firstPoint toLocation:(NSPoint)secondPoint;

- (NSPoint)invertYAxis:(NSPoint)point;

- (void)resetNewConnection;

@end
