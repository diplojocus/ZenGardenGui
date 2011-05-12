//
//  CanvasMainView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CanvasMainView.h"
#import "ObjectView.h"

#define OBJECT_FRAME_HEIGHT @"25"
#define OBJECT_FRAME_WIDTH @"80"

@implementation CanvasMainView

// C function
void zgCallbackFunction(ZGCallbackFunction function, void *userData, void *ptr) {
  
  switch (function) {
    case ZG_PRINT_STD: {
      NSLog(@"%s", ptr);
      break;
    }
    case ZG_PRINT_ERR: {
      NSLog(@"ERROR: %s", ptr);
      break;
    }
    default: {
      NSLog(@"unknown ZGCallbackFunction received: %i", function);
      break;
    }
  }
}

- (id)initWithFrame:(NSRect)frame {
  
    self = [super initWithFrame:frame];
    if (self) {
      
      /* ZenGarden Stuff
      zgContext = zg_new_context(0,
                                 2,
                                 64,
                                 44100.0f,
                                 zgCallbackFunction,
                                 NULL);
      
      zgGraph = zg_new_empty_graph(zgContext);
      
      zgObject1 = @"osc~ 440";
      zgObject2 = @"dac~";
      
      zg_add_object(zgGraph, zgObject1, 10, 10);
      zg_add_object(zgGraph, zgObject2, 10, 30);
      zg_add_connection(zgGraph, zgObject1, 0, zgObject2, 0);
      
      zg_attach_graph(zgContext, zgGraph);
      
      float *inputBuffers = (float *) calloc(0 * 64, sizeof(float));
      float *outputBuffers = (float *) calloc(2 * 64, sizeof(float));
      
      for (int i = 0; i < 9999985; i++) {
        
      zg_process(zgContext, inputBuffers, outputBuffers);
      } */ 
       
      defaultFrameHeight = 20;
      defaultFrameWidth = 30;
      
      arrayOfObjects = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect {
  
  // colour background
  [[NSColor whiteColor] set];
  NSRectFill(rect);
  
  NSBezierPath *windowPath;
  windowPath = [NSBezierPath bezierPathWithRect:rect];
  NSColor *whiteColor = [NSColor whiteColor];
  [whiteColor set];
  [windowPath fill];
  
  selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
  NSColor *theSelectionColor = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:0.1];
  [theSelectionColor set];
  [selectionPath fill];
  
}

-(BOOL)acceptsFirstResponder {
  
  return YES;
}

-(IBAction)putObject:(id)sender {
  
  NSPoint currentMouseLocation = [[self window] mouseLocationOutsideOfEventStream];
  
  // For some reason the coordinates are from lower-left instead of upper-left
  // Invert y coordinate and center frame with respect to mouse location (not sure why 3 has to be added)
  // Not sure why 3 has to be added to center it
  currentMouseLocation.y = ([self frame].size.height + 3) - currentMouseLocation.y - (defaultFrameHeight/2);
  currentMouseLocation.x -= (defaultFrameWidth/2);
  
  // Create new object at current mouse location
  NSRect frame;
  frame.origin = currentMouseLocation;
  frame.size.width = defaultFrameWidth;
  frame.size.height = defaultFrameHeight;
  newView = [[[ObjectView alloc] initWithFrame:frame] autorelease];
  [self addSubview:newView];
  [newView setFrameOrigin:currentMouseLocation];
  [arrayOfObjects addObject:newView];
}

-(void)setObjectFrameOrigin {
  
  newView = nil;
  NSLog(@"MOUSE DOWN");
}

-(void)awakeFromNib {
  
  [[self window] setAcceptsMouseMovedEvents:YES]; 
} 

-(void)mouseMoved:(NSEvent *)theEvent {
  
  // invert y axis mouse coordinates
  NSPoint mouseLocation = NSMakePoint(([theEvent locationInWindow].x - (defaultFrameWidth/2)), 
                                      ([self frame].size.height + 3) - [theEvent locationInWindow].y - (defaultFrameHeight/2)); 
  [newView setFrameOrigin:mouseLocation];
}

- (void)mouseDown:(NSEvent *)theEvent {
  
  // release focus of objects
  [[self window] makeFirstResponder:self];
  
  // set inital selection marquee points
  selectionRect = NSMakeRect(0, 0, 0, 0);
  [self setNeedsDisplay:YES];
  firstPoint = [self convertPoint:[theEvent locationInWindow] 
                                  fromView:nil];
  secondPoint.x = firstPoint.x;
  secondPoint.y = firstPoint.y;
}

- (void)mouseDragged:(NSEvent *)theEvent {
  
  // set selection marquee points
  secondPoint = NSMakePoint(([theEvent locationInWindow].x - firstPoint.x), 
                            (([self frame].size.height + 3) - [theEvent locationInWindow].y - firstPoint.y));
  selectionRect = NSMakeRect(firstPoint.x, 
                             firstPoint.y, 
                             secondPoint.x, 
                             secondPoint.y);
  
  // Calculates if object is selected (currently not working)
  BOOL selectedObject = NSIntersectsRect(selectionRect, [newView frame]);
  NSLog(@"Object Selected %d", selectedObject);
  
  [self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
  
  selectionRect = NSMakeRect(0, 0, 0, 0);
  [self setNeedsDisplay:YES];
  firstPoint = [theEvent locationInWindow];
  secondPoint = [theEvent locationInWindow];
}

- (BOOL)isFlipped {
  
  // coordinates taken from upper-left hand corner
  return YES;
}

- (void)dealloc {
  
  [arrayOfObjects release];
  zg_delete_context(zgContext);
  
  [super dealloc];
}


@end

/*
// Given two corners, make an NSRect (C Function)
NSRect rectFromTwoPoints(NSPoint p1, NSPoint p2) {
  
  return NSMakeRect(MIN(p1.x, p2.x), 
                    MIN(p1.y, p2.y), 
                    fabs(p1.x - p2.x), 
                    fabs(p1.y - p2.y));
} */
