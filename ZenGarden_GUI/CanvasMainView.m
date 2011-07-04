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
      newConnectionStartPoint = NSMakePoint(0, 0);
      newConnectionEndPoint = NSMakePoint(0, 0);
    }
    return self;
}

- (void)dealloc {
  [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  [self drawBackground:dirtyRect];
  
  selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
  NSColor *theSelectionColor = [NSColor blackColor];
  CGFloat selectionDashArray[2] = { 5.0, 2.0 };
  [selectionPath setLineDash: selectionDashArray count: 2 phase: 0.0];
  [theSelectionColor setStroke];
  [selectionPath stroke];
  
  [[NSColor blackColor] setStroke];
  [NSBezierPath strokeLineFromPoint:newConnectionStartPoint
                            toPoint:newConnectionEndPoint];
  
  
  

  /*
  for (ObjectView *objectView in arrayOfObjects) {
    for (LetView *outletView in objectView.letArray) {
      if (!outletView.isInlet) { // only consider outlets
        for (LetView *inletView in outletView.connections) {
          NSPoint startPoint = NSMakePoint(NSMidX(outletView.frame), outletView.frame.origin.y + outletView.frame.size.height);
          NSPoint endPoint = NSMakePoint(NSMidX(inletView.frame), inletView.frame.origin.y);
          // draw a line from startPoint to endPoint
        }
      }
    }
  } */
  
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

- (BOOL)isEditModeOn {
  return isEditModeOn;
}

#pragma mark - Key Events

- (void)keyDown:(NSEvent *)theEvent {
  
}

#pragma mark - Mouse Events

- (void)mouseDown:(NSEvent *)theEvent {
  selectedObjectsCount = 0;
  for (ObjectView *anObject in arrayOfObjects) {
    selectedObjectsCount++;
    [(ObjectView *)anObject highlightObject:NO];
  }
  if (isEditModeOn) {
    drawSelectionRectangle = YES;
    selectionStartPoint = [self invertYAxis:[theEvent locationInWindow]];
  }
}

- (void)mouseUp:(NSEvent *)theEvent {
  [self resetDrawingSelectors];
  NSPoint zeroPoint = NSMakePoint(0, 0);
  newConnectionStartPoint = zeroPoint;
  newConnectionEndPoint = zeroPoint;
  selectionStartPoint = zeroPoint;
  selectionRect = [self rectFromTwoPoints:selectionStartPoint toLocation:NSMakePoint(0, 0)];
  [self setNeedsDisplay:YES];

}

- (void)mouseDragged:(NSEvent *)theEvent {
  NSPoint mousePoint = [self invertYAxis:[theEvent locationInWindow]];
  if (isEditModeOn) {
    if (drawConnection) {
      newConnectionEndPoint = mousePoint;
      return;
    }
    else if (moveObject) {
      [objectToMove setFrameOrigin:NSMakePoint(mousePoint.x - mousePositionInsideObject.x,
                                               mousePoint.y - mousePositionInsideObject.y)]; 
      return;
    }
    else if (resizeObject) {
      NSLog(@"Resize Object"); 
      return;
    }
    else if (drawSelectionRectangle) {
      selectionRect = [self rectFromTwoPoints:selectionStartPoint toLocation:mousePoint];
      selectedObjectsCount = 0;
      for (ObjectView *anObject in arrayOfObjects) {
        if (NSIntersectsRect(selectionRect, [anObject frame])) {
          selectedObjectsCount++;
          [(ObjectView *)anObject highlightObject:YES];
        }
        else {
          [(ObjectView *)anObject highlightObject:NO];
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
    [[[NSColor blueColor] colorWithAlphaComponent:0.2f] setFill];
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

- (IBAction)removeObject:(id)sender {
  
}

- (void)moveObject:(ObjectView *)object with:(NSPoint)adjustedMousePosition {
  moveObject = YES;
  objectToMove = object;
  mousePositionInsideObject = adjustedMousePosition;
}


#pragma mark - Connection Drawing

- (void)startConnectionDrawing:(NSPoint)point {
  drawConnection = YES;
  newConnectionStartPoint = [self invertYAxis:point];
}

@end
