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
#define OBJECT_HEIGHT 100.0
#define OBJECT_WIDTH 300.0

@implementation CanvasMainView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  [[NSColor whiteColor] setFill];
  NSRectFill(dirtyRect);
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

#pragma mark - Object drawing

-(IBAction)putObject:(id)sender {
  NSLog(@"Add Object");
  objectView = [[[ObjectView alloc] 
      initWithFrame:NSMakeRect(OBJECT_ORIGIN_X, OBJECT_ORIGIN_Y, OBJECT_WIDTH, OBJECT_HEIGHT)] 
      autorelease];
  [self addSubview:objectView];
  [arrayOfObjects addObject:objectView];
  
}


@end
