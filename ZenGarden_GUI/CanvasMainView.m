//
//  CanvasMainView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CanvasMainView.h"

#define OBJECT_ORIGIN_X 100.0
#define OBJECT_ORIGIN_Y 100.0
#define DEFAULT_OBJECT_HEIGHT 100.0
#define DEFAULT_OBJECT_WIDTH 300.0

@implementation CanvasMainView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
      isEditModeOn = NO;
      enableConnectionDrawing = NO;
      connectionStartPoint = NSMakePoint(0, 0);
      connectionEndPoint = NSMakePoint(0, 0);
    }
    
    return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  [self drawBackground:dirtyRect];
  
  [[NSColor blackColor] setStroke];
  [NSBezierPath strokeLineFromPoint:NSMakePoint(0, 0) toPoint:testDraw];
}

- (void)drawBackground:(NSRect)rect {
  if (isEditModeOn) {
    [[[NSColor blueColor] colorWithAlphaComponent:0.4f] setFill];
    [NSBezierPath fillRect:rect];
  }
  else {
    [[NSColor whiteColor] setFill];
    NSRectFill(rect);
  }
}

- (void)mouseUp:(NSEvent *)theEvent {
//  enableConnectionDrawing = NO;
//  connectionStartPoint = NSMakePoint(0, 0);
//  connectionEndPoint = NSMakePoint(0, 0);
}

- (void)mouseDragged:(NSEvent *)theEvent {
  if (isEditModeOn) {
    if (enableConnectionDrawing) {
      connectionEndPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
      [self drawConnection:connectionStartPoint to:connectionEndPoint];
    }

  }
}

- (BOOL)acceptsFirstResponder { return YES; }

- (BOOL)isFlipped { return YES; }

- (void)awakeFromNib {
  
  [[self window] setAcceptsMouseMovedEvents:YES]; 
} 

- (void)toggleEditMode:(id)sender {
  isEditModeOn = !isEditModeOn;
  [sender setState:isEditModeOn ? NSOnState : NSOffState];
  if (isEditModeOn) {
    NSLog(@"Edit Mode");
  }
  else {
    NSLog(@"View Mode");
  }
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}

#pragma mark - Object drawing

-(IBAction)putObject:(id)sender {
  NSLog(@"Add Object");
  objectView = [[[ObjectView alloc] 
      initWithFrame:NSMakeRect(OBJECT_ORIGIN_X, OBJECT_ORIGIN_Y,
                               DEFAULT_OBJECT_WIDTH, DEFAULT_OBJECT_HEIGHT)] 
      autorelease];
  [self addSubview:objectView];
  [arrayOfObjects addObject:objectView];
}

- (void)moveObject:(ObjectView *)object toLocation:(NSPoint)location {
  NSLog(@"MOVE OBJECT");
  [object setFrame:NSMakeRect(location.x,
                              location.y,
                              object.frame.size.width,
                              object.frame.size.height)];
}

- (void)startConnectionDrawing:(NSPoint)location {
  enableConnectionDrawing = YES;
  connectionStartPoint = NSMakePoint(location.x, self.frame.size.height - location.y);
}

- (void)drawConnection:(NSPoint)startLocation to:(NSPoint)endLocation {
  [self becomeFirstResponder];
  [[NSColor blackColor] setStroke];
  [NSBezierPath strokeLineFromPoint:startLocation toPoint:endLocation];
  [self setNeedsDisplay:YES];
  [self needsDisplay];
  NSLog(@"Start Connection %f, %f", startLocation.x, startLocation.y);
  NSLog(@"End Connection %f, %f", endLocation.x, endLocation.y);
}

@end
