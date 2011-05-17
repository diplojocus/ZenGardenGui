//
//  CanvasMainView.h
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ObjectView.h"
#import "ZenGarden.h"
#import "PdAudio.h"

@interface CanvasMainView : NSView {
  
  // Canvas
  BOOL isEditModeOn;
  
  // Objects
  int defaultFrameWidth;
  int defaultFrameHeight;
  ObjectView *objectView;
  NSMutableArray *arrayOfObjects;
  
  // Selection Marquee
  NSPoint firstPoint;
  NSPoint secondPoint;
  NSRect selectionRect;
  NSBezierPath *selectionPath;
  
  // ZenGarden/PdAudio
  ZGGraph *zgGraph;
  PdAudio *pdAudio;
}

- (IBAction)putObject:(id)sender;

- (IBAction)toggleEditMode:(id)sender;

- (void)setObjectFrameOrigin;

- (void)deleteObject;

- (ZGObject *)instantiateZgObject:(NSString *)initString atLocation:(NSPoint)location;

- (NSRect)rectFromTwoPoints:(NSPoint)p1 secondPoint:(NSPoint)p2;


@property (nonatomic, readonly) ZGGraph *zgGraph;

@property (nonatomic, readonly) BOOL isEditModeOn;

@end
