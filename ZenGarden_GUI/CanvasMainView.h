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

  NSPoint firstPoint;
  NSPoint secondPoint;
  NSRect selectionRect;
  NSBezierPath *selectionPath;
  
  ObjectView *newView;
  
  ZGContext *zgContext;
  ZGGraph *zgGraph;
}

-(IBAction)putObject:(id)sender;

@end
