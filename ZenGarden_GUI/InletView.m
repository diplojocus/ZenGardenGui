//
//  InletView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 17/05/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InletView.h"


@implementation InletView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      NSLog(@"INLET");
    }
    
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  NSBezierPath * path = [NSBezierPath bezierPathWithRect:NSMakeRect(1, 0, 2, 2)];
  
  [path setLineWidth:4];
  
  [[NSColor blackColor] set];
  [path fill];
  
  [[NSColor grayColor] set]; 
  [path stroke];
}

@end
