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
      arrayOfObjects = [[NSMutableArray alloc] init];
      isEditModeOn = NO;
      [self resetDrawingSelectors];
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
  
  
  NSArray *selectionDashArray;
  selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
  //selectionDashArray[0] = 5.0; //segment painted with stroke color
  //selectionDashArray[1] = 2.0; //segment not painted with a color
  
  //[path setLineDash: array count: 2 phase: 0.0];
  //NSColor *theSelectionColor = [NSColor blackColor];
  //[theSelectionColor set];
  //[selectionPath fill];
}

- (void)awakeFromNib {
  [[self window] setAcceptsMouseMovedEvents:YES]; 
} 

- (BOOL)acceptsFirstResponder { return YES; }

- (BOOL)isFlipped { return YES; }

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

#pragma mark - Mouse Events

- (void)mouseDown:(NSEvent *)theEvent {
  if (isEditModeOn) {
    selectionStartPoint = [self invertYAxis:[theEvent locationInWindow]];
  }
}

- (void)mouseUp:(NSEvent *)theEvent {
  [self resetDrawingSelectors];
  NSPoint zeroPoint = NSMakePoint(0, 0);
  connectionStartPoint = zeroPoint;
  connectionEndPoint = zeroPoint;
  selectionStartPoint = zeroPoint;

}

- (void)mouseDragged:(NSEvent *)theEvent {
  NSLog(@"DRAGGED");
  NSPoint mousePoint = [self invertYAxis:[theEvent locationInWindow]];
  drawSelectionRectangle = YES;
  if (isEditModeOn) {
    if (drawConnection) {
      NSLog(@"Draw Connection");
      connectionEndPoint = mousePoint;
      //connectionEndPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
      [self drawConnection:connectionStartPoint toLocation:connectionEndPoint];
      return;
    }
    else if (moveObject) {
      [objectToMove setFrameOrigin:mousePoint]; 
      return;
    }
    else if (resizeObject) {
      NSLog(@"Resize Object"); 
      return;
    }
    else if (drawSelectionRectangle) {
      [self drawSelectionRectangle:selectionStartPoint toLocation:mousePoint];
      int selectedObjectsCount = 0;
      for (ObjectView *anObject in arrayOfObjects) {
        if (NSIntersectsRect(selectionRect, [anObject frame])) {
          selectedObjectsCount++;
          [(ObjectView *)anObject isObjectHighlighted:YES];
        }
        else {
          [(ObjectView *)anObject isObjectHighlighted:NO];
        }
        [self setNeedsDisplay:YES];
      }
      return;
    }
  }
}

- (void)resetDrawingSelectors {
  drawConnection = NO;
  drawSelectionRectangle = NO;
  resizeObject = NO;
  moveObject = NO;
}
       
- (NSPoint)invertYAxis:(NSPoint)point {
  point = NSMakePoint(point.x, self.frame.size.height - point.y);
  return point;
}


#pragma mark - Background Drawing

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


#pragma mark - Selection Rectangle Drawing
       
- (void)drawSelectionRectangle:(NSPoint)startPoint toLocation:(NSPoint)endPoint {
  selectionRect = [self rectFromTwoPoints:startPoint toLocation:endPoint];
}
       
- (NSRect)rectFromTwoPoints:(NSPoint)firstPoint toLocation:(NSPoint)secondPoint {
  return NSMakeRect(MIN(firstPoint.x, secondPoint.x),
                    MIN(firstPoint.y, secondPoint.y),
                    fabs(firstPoint.x - secondPoint.x),
                    fabs(firstPoint.y - secondPoint.y));
} 


#pragma mark - Object Drawing

-(IBAction)putObject:(id)sender {
  NSLog(@"Add Object");
  objectView = [[[ObjectView alloc] 
      initWithFrame:NSMakeRect(OBJECT_ORIGIN_X, OBJECT_ORIGIN_Y,
                               DEFAULT_OBJECT_WIDTH, DEFAULT_OBJECT_HEIGHT)] autorelease];
  [self addSubview:objectView];
  [arrayOfObjects addObject:objectView];
}

- (void)moveObject:(ObjectView *)object {
  moveObject = YES;
  objectToMove = object;
}


#pragma mark - Connection Drawing

- (void)startConnectionDrawing:(NSPoint)point {
  drawConnection = YES;
  connectionStartPoint = [self invertYAxis:point];
}

- (void)drawConnection:(NSPoint)startPoint toLocation:(NSPoint)endPoint {
  [self becomeFirstResponder];
  [[NSColor blackColor] setStroke];
  [NSBezierPath strokeLineFromPoint:startPoint toPoint:endPoint];
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}

@end
