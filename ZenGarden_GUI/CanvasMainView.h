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

  // Objects
  int defaultFrameWidth;
  int defaultFrameHeight;
  ObjectView *newView;
  NSMutableArray *arrayOfObjects;
  
  // Selection Marquee
  NSPoint firstPoint;
  NSPoint secondPoint;
  NSRect selectionRect;
  NSBezierPath *selectionPath;
  
  // ZenGarden
  ZGGraph *zgGraph;
  ZGObject *zgObject1;
  ZGObject *zgObject2;
  
  PdAudio *pdAudio;
}

-(IBAction)putObject:(id)sender;

-(void)setObjectFrameOrigin;

-(NSRect)rectFromTwoPoints:(NSPoint)p1 secondPoint:(NSPoint)p2;

@end
