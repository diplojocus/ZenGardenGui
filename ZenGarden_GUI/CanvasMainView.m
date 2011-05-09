//
//  CanvasMainView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 27/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CanvasMainView.h"
#import "ObjectView.h"

// C function
NSRect NSRectFromTwoPoints(NSPoint a, NSPoint b) {
  
  NSRect r;
  r.origin.x = MIN(a.x, b.x);
  r.origin.y = MIN(a.y, b.y);
  
  r.size.width = ABS(a.x - b.x);
  r.size.height = ABS(a.y - b.y);
  
  return r;
}

@implementation CanvasMainView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
    }
    
    return self;
}

- (void)drawRect:(NSRect)rect {
  
  // colour background
  [[NSColor whiteColor] set];
  NSRectFill(rect);
  
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
  ObjectView *object = [[[ObjectView alloc] initWithFrame:frame] autorelease];
  [self addSubview:object];
  [object setFrameOrigin:currentMouseLocation];

}

/*-(void)upDateMarquee:(NSPoint)newPoint {
  
  marquee = newPoint;
  
  NSRect marqueeRectangle = NSRectFromTwoPoints(anchor, marquee);
  NSEnumerator *iteration = [[[self delegate] objects] objectEnumerator];
  
  
} */

- (void)mouseDown:(NSEvent *)theEvent {
  
  // release focus of objects
  [[self window] makeFirstResponder:self];
  
}

- (void)mouseUp:(NSEvent *)theEvent {
  
  
}

- (void)mouseDragged:(NSEvent *)theEvent {
  
}

- (BOOL)isFlipped {
  
  // coordinates taken from upper-left hand corner
  return YES;
}

- (void)dealloc
{
  [super dealloc];
}


@end
