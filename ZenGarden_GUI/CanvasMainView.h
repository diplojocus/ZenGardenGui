//
//  CanvasMainView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ObjectView.h"


@interface CanvasMainView : NSView {

  BOOL isEditModeOn;
  
  // Object
  ObjectView *objectView;
  NSMutableArray *arrayOfObjects;
  
  NSPoint connectionStartPoint;
  NSPoint connectionEndPoint;
  BOOL enableConnectionDrawing;
  
  NSPoint testDraw;
  
}

- (IBAction)toggleEditMode:(id)sender;
- (IBAction)putObject:(id)sender;
- (void)moveObject:(ObjectView *)object toLocation:(NSPoint)location;
- (void)startConnectionDrawing:(NSPoint)location;
- (void)drawConnection:(NSPoint)startLocation to:(NSPoint)endLocation;
- (void)drawBackground:(NSRect)rect;

@end
