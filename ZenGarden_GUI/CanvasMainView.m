//
//  CanvasMainView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CanvasMainView.h"
#import "ObjectView.h"

@implementation CanvasMainView

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
      [[self window] setAcceptsMouseMovedEvents:YES];
      zgContext = zg_new_context(0,
                                 2,
                                 64,
                                 44100.0f,
                                 zgCallbackFunction,
                                 NULL);
      zgGraph = zg_new_empty_graph(zgContext);
      zg_attach_graph(zgContext, zgGraph);
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
  
  int frameHeight = 20;
  int frameWidth = 85;
  
  NSPoint currentMouseLocation = [[self window] mouseLocationOutsideOfEventStream];
  
  // For some reason the coordinates are from lower-left instead of upper-left
  // Invert y coordinate and center frame with respect to mouse location (not sure why 3 has to be added)
  // Not sure why 3 has to be added to center it
  currentMouseLocation.y = ([self frame].size.height + 3) - currentMouseLocation.y - (frameHeight/2);
  currentMouseLocation.x -= (frameWidth/2);
  
  // Create new object at current mouse location
  NSRect frame;
  frame.origin = currentMouseLocation;
  frame.size.width = frameWidth;
  frame.size.height = frameHeight;
  newView = [[[ObjectView alloc] initWithFrame:frame] autorelease];
  [self addSubview:newView];
  [newView setFrameOrigin:currentMouseLocation];
  
}

-(void)mouseMoved:(NSEvent *)theEvent {
  NSLog(@"Mouse");
  
  [newView setFrameOrigin:[theEvent locationInWindow]];
}

- (void)mouseDown:(NSEvent *)theEvent {
  
  newView = nil;
  
  // release focus of objects
  [[self window] makeFirstResponder:self];
  
  // set inital selection marquee points
  selectionRect = NSMakeRect(0, 0, 0, 0);
  [self setNeedsDisplay:YES];
  firstPoint = [self convertPoint:[theEvent locationInWindow] 
                                  fromView:nil];
  secondPoint.x = firstPoint.x;
  secondPoint.y = firstPoint.y;
  
  
  
  NSLog(@"firstPoint X = %f, Y = %f", firstPoint.x, firstPoint.y);
}

- (void)mouseDragged:(NSEvent *)theEvent {
  
  // set selection marquee points
  secondPoint = [self convertPoint:[theEvent locationInWindow] 
                                    fromView:self];
  selectionRect = NSMakeRect(firstPoint.x, 
                             firstPoint.y, 
                             secondPoint.x, 
                             secondPoint.y);
  [self setNeedsDisplay:YES];
  
  NSLog(@"secondPoint X = %f, Y = %f", secondPoint.x, secondPoint.y);
  
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
