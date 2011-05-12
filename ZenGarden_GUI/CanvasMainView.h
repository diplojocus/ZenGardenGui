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

@interface CanvasMainView : NSView {

  // Objects
  int defaultFrameWidth;
  int defaultFrameHeight;
  ObjectView *newView;
  
  // Selection Marquee
  NSPoint firstPoint;
  NSPoint secondPoint;
  NSRect selectionRect;
  NSBezierPath *selectionPath;
  
  // ZenGarden
  ZGContext *zgContext;
  ZGGraph *zgGraph;
  ZGObject *zgObject1;
  ZGObject *zgObject2;
}

-(IBAction)putObject:(id)sender;

-(void)setObjectFrameOrigin;

@end
