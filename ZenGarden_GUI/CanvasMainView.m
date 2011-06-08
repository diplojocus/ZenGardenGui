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
    }
    
    return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  [self drawBackground:dirtyRect];
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

- (void)mouseDown:(NSEvent *)theEvent {
  NSLog(@"MOUSE DOWN: X %f, Y %f", [theEvent locationInWindow].x, [theEvent locationInWindow].y);
}

- (BOOL)acceptsFirstResponder {
  return YES;
}

- (BOOL)isFlipped {
  return YES;
}

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


@end
