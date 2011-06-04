//
//  ObjectView.m
//  ObjectDrawing
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ObjectView.h"


@implementation ObjectView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  [self drawBackground:dirtyRect];
  
  [self drawLet:NSMakePoint(self.bounds.origin.x + 30 , 0)];
  [self drawLet:NSMakePoint(self.bounds.origin.x + 100 , 0)];
  [self drawLet:NSMakePoint(self.bounds.origin.x + 170 , 0)];
  [self drawLet:NSMakePoint(self.bounds.origin.x + 240 , 0)];
  [self drawLet:NSMakePoint(self.bounds.origin.x + 30 , self.bounds.size.height - 10)];
}

- (void)drawBackground:(NSRect)rect {
  
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:
                              NSMakeRect(rect.origin.x + 5,
                                         rect.origin.y + 5,
                                         rect.size.width - 10,
                                         rect.size.height - 10) 
                              xRadius:20 yRadius:20];
  
  [[[NSColor lightGrayColor] colorWithAlphaComponent:0.15f] setFill];
  [path fill];
  
  [path setLineWidth:10];
  [[NSColor lightGrayColor] setStroke];
  [path stroke];
}

- (void)drawLet:(NSPoint)letOrigin { //inlet or outlet
  
  NSRect letRect = NSMakeRect(letOrigin.x, letOrigin.y, 30, 10);
  
  NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:letRect xRadius:2 yRadius:2];
  [[NSColor blackColor] setFill];
  [path fill];
}

- (BOOL)isFlipped { return YES; }

- (BOOL)acceptsFirstResponder { return YES; }

- (BOOL)becomeFirstResponder { return YES; }


- (void)mouseDown:(NSEvent *)theEvent {
  NSLog(@"OBJECT MOUSE DOWN");
}

@end
