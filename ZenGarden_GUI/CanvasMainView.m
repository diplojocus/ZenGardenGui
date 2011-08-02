//
//  CanvasMainView.m
//  ZenGarden_GUI
//
//  Created by Joe White on 03/06/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CanvasMainView.h"

#define DEFAULT_OBJECT_ORIGIN_X 100.0
#define DEFAULT_OBJECT_ORIGIN_Y 100.0
#define DEFAULT_OBJECT_HEIGHT 30.0
#define DEFAULT_OBJECT_WIDTH 70.0

@implementation CanvasMainView

@synthesize editToggleMenuItem;
@synthesize isEditModeOn;
@synthesize zgGraph;

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
      pdAudio = [[PdAudio alloc] initWithInputChannels:0 OutputChannels:2 blockSize:256
                                         andSampleRate:44100.0];
      [pdAudio play];
      
      zgGraph  = zg_context_new_empty_graph(pdAudio.zgContext);
      zg_graph_attach(zgGraph);
      
      arrayOfObjects = [[NSMutableArray alloc] init];
      isEditModeOn = NO;
      [self resetDrawingSelectors];
      [self resetNewConnection];
    }
    return self;
}

- (void)awakeFromNib {
  
  [[self window] setAcceptsMouseMovedEvents:YES]; 
  
  builtInObjectLabels = [[NSMutableArray alloc] initWithObjects:@"adc~", @"+~", @"bp~", @"bang~",
  @"catch~", @"clip~", @"cos~", @"dac~", @"delread~", @"delwrite~", @"/~", @"env~", @"hip~",
  @"inlet~", @"line~", @"log~", @"lop~", @"min~", @"*~", @"noise~", @"osc~", @"outlet~",
  @"phasor~", @"print~", @"receive~", @"r~", @"rsqrt~", @"rfft~", @"rifft~", @"send~", @"s~",
  @"sig~", @"snapshot~", @"sqrt~", @"-~", @"tabplay~", @"tabread~", @"tabread4~", @"throw~",
  @"vd~", @"vcf~", @"wrap~", @"abs", @"+", @"atan", @"atan2", @"b", @"bang", @"change", @"clip",
  @"cos", @"cputime", @"dbtopow", @"dbtorms", @"declare", @"del", @"delay", @"/", @"==", @"exp",
  @"f", @"float", @"ftom", @">", @">=", @"inlet", @"int", @"<", @"<=", @"line", @"list",
  @"list append", @"list prepend", @"list split", @"list trim", @"loadbang", @"log", @"&&", @"||",
  @"max", @"msg", @"metro", @"mtof", @"min", @"mod", @"moses", @"*", @"notein", @"!=", @"openpanel",
  @"outlet", @"pack", @"pipe", @"pow", @"powtodb", @"print", @"random", @"r", @"recieve", @"%",
  @"rmstodb", @"route", @"samplerate", @"sel", @"select", @"s", @"send", @"sendcontroller", @"sin",
  @"soundfiler", @"spigot", @"sqrt", @"stripnote", @"-", @"swap", @"switch", @"symbol", @"table",
  @"tabread", @"tabwrite", @"tan", @"text", @"timer", @"tgl", @"toggle", @"t", @"trigger",
  @"unpack", @"until", @"v", @"value", @"wrap", nil];
}

- (NSArray *)allObjectLabels {
  // builds the object label array for use in type completion
  NSArray *anArray = [[[NSArray alloc] init] autorelease];
  unsigned int i, count;
  
  if (allObjectLabels == nil) {
    
    allObjectLabels = [builtInObjectLabels mutableCopy];
    
    if (anArray != nil) {
      
      count = (unsigned int)[anArray count];
      
      for (i=0; i<count; i++) {
      
        if ([allObjectLabels indexOfObject:[anArray objectAtIndex:i]] == NSNotFound) {
          [allObjectLabels addObject:[anArray objectAtIndex:i]];
        }
      }
    }
    [allObjectLabels sortUsingSelector:@selector(compare:)];
  }
  return allObjectLabels;
}

- (void)dealloc {
  [super dealloc];
  [objectView dealloc];
  [allObjectLabels dealloc];
  [builtInObjectLabels dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
  
  [self drawBackground:self.bounds];
  
  // draw selection path
  selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
  NSColor *theSelectionColor = [NSColor blackColor];
  CGFloat selectionDashArray[2] = { 5.0, 2.0 };
  [selectionPath setLineWidth:1];
  [selectionPath setLineDash: selectionDashArray count: 2 phase: 0.0];
  [theSelectionColor setStroke];
  [selectionPath stroke];
  
  // draw connection path
  if (drawNewConnection) {
    [[NSColor blackColor] setStroke];
    [NSBezierPath setDefaultLineWidth:newConnectionLineWidth];
    [NSBezierPath strokeLineFromPoint:newConnectionStartPoint
                              toPoint:newConnectionEndPoint];
  }
  /*
  // draw existing connections
  for (ObjectView *anObject in arrayOfObjects) {
    for (LetView *outletView in anObject.outletArray) {
        for (LetView *inletView in outletView.connections) {
          NSPoint startPoint = NSMakePoint(NSMidX(outletView.frame), outletView.frame.origin.y + outletView.frame.size.height);
          NSPoint endPoint = NSMakePoint(NSMidX(inletView.frame), inletView.frame.origin.y);
          // draw a line from startPoint to endPoint
        }
      }
    }
  } */
}

- (ZGContext *)zgContext {
  return pdAudio.zgContext;
}

- (ZGObject *)addNewObjectToGraphWithInitString:(NSString *)initString withLocation:(NSPoint)location {
  
  ZGObject *zgObject = zg_graph_new_object(zgGraph, (char *) [initString cStringUsingEncoding:NSASCIIStringEncoding]);
  if (zgObject != NULL) {
    zg_graph_add_object(zgGraph, zgObject, (int) location.x, (int) location.y);
  }
  return zgObject;
} 

- (BOOL)acceptsFirstResponder { return YES; }

- (BOOL)isFlipped { return YES; }

- (void)toggleEditMode:(id)sender {
  isEditModeOn = !isEditModeOn;
  [sender setState:isEditModeOn ? NSOnState : NSOffState];
  
  for (ObjectView *object in arrayOfObjects) {
    [object setTextFieldEditable:isEditModeOn];
  }
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}

- (BOOL)isEditModeOn {
  return isEditModeOn;
}

#pragma mark - Key Events

- (void)keyDown:(NSEvent *)theEvent {
  
  // Grabbing backspace AND delete key presses seems like a be-ach
  // http://www.cocoadev.com/index.pl?TrappingTheDeleteKey
  //
  // currently using just backspace and cmd+x (Cut menu item)
  unichar key = [[theEvent characters] characterAtIndex:0];
	
	if (key == NSDeleteCharacter || key == NSBackspaceCharacter)
	{
    [self removeObject:self];
    return;
  }
  [super keyDown:theEvent];
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
  
  NSLog(@"MOUSE UP");
  /* reset let mouse down selector
  for (ObjectView *object in arrayOfObjects) {
    [object setLetMouseDown:NO];
  }
  */
  
  [self resetDrawingSelectors];
  selectionStartPoint = NSMakePoint(0, 0);
  selectionRect = [self rectFromTwoPoints:selectionStartPoint toLocation:NSMakePoint(0, 0)];
  [self setNeedsDisplay:YES];
  [self needsDisplay];

}

- (void)mouseDragged:(NSEvent *)theEvent {
  NSLog(@"Canvas Mouse Dragged");
  NSPoint mousePoint = [self invertYAxis:[theEvent locationInWindow]];
  if (isEditModeOn) {
    if (moveObject) {
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
      }
      [self setNeedsDisplay:YES];
      return;
    }
  }
}

- (void)resetDrawingSelectors {
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
  
  ObjectView *anObject;
  
  // make sure edit mode is on 
  if (!isEditModeOn) {
    [self toggleEditMode:[self menu]];
    [editToggleMenuItem setState:NSOnState];
  }
  // Convert mouse location to view coordinates
  NSPoint mouseLocation = [[self window] convertScreenToBase:[NSEvent mouseLocation]];
  NSPoint viewLocation = [self convertPoint:mouseLocation fromView:nil];
  
  // If inside canvas view add object at mouse location
  if (NSPointInRect(viewLocation, [self bounds])) {
    anObject = [[ObjectView alloc] 
                initWithFrame:NSMakeRect(viewLocation.x - (DEFAULT_OBJECT_WIDTH / 2),
                                         viewLocation.y - (DEFAULT_OBJECT_HEIGHT / 2),
                                         DEFAULT_OBJECT_WIDTH,
                                         DEFAULT_OBJECT_HEIGHT) delegate:self];
    [self addSubview:anObject];
    [arrayOfObjects addObject:anObject];
  }
  // If outside canvas view add object at default location
  else {
    anObject = [[ObjectView alloc] initWithFrame:NSMakeRect(DEFAULT_OBJECT_ORIGIN_X,
                                                            DEFAULT_OBJECT_ORIGIN_Y,
                                                            DEFAULT_OBJECT_WIDTH,
                                                            DEFAULT_OBJECT_HEIGHT) delegate:self];
    [self addSubview:anObject];
    [arrayOfObjects addObject:anObject];
  }
}

- (IBAction)addBang:(id)sender {
  
  BangView *aBang;
  
  // make sure edit mode is on 
  if (!isEditModeOn) {
    [self toggleEditMode:[self menu]];
    [editToggleMenuItem setState:NSOnState];
  }
  // Convert mouse location to view coordinates
  NSPoint mouseLocation = [[self window] convertScreenToBase:[NSEvent mouseLocation]];
  NSPoint viewLocation = [self convertPoint:mouseLocation fromView:nil];
  
  // If inside canvas view add object at mouse location
  if (NSPointInRect(viewLocation, [self bounds])) {
    aBang = [[BangView alloc] 
            initWithFrame:NSMakeRect(viewLocation.x - (50 / 2),
                                     viewLocation.y - (50 / 2),
                                     50,
                                     50) delegate:self];
    [self addSubview:aBang];
    [arrayOfObjects addObject:aBang];
  }
  // If outside canvas view add object at default location
  else {
    aBang = [[ObjectView alloc] initWithFrame:NSMakeRect(50,
                                                         50,
                                                         50,
                                                         50) delegate:self];
    [self addSubview:aBang];
    [arrayOfObjects addObject:aBang];
  }
}

- (IBAction)removeObject:(id)sender { 
  // Removes all highlighted objects
  for (ObjectView *object in arrayOfObjects) {
    if ([object isHighlighted]) {
      [object removeZGObjectFromZGGraph:zgGraph];
      [object removeFromSuperview];
    }
  }
} 

- (IBAction)selectAll:(id)sender {
  // Highlights all objects
  for (ObjectView *object in arrayOfObjects) {
    [object highlightObject:YES];
  }
}

- (void)moveObject:(ObjectView *)object with:(NSPoint)adjustedMousePosition {
  moveObject = YES;
  objectToMove = object;
  mousePositionInsideObject = adjustedMousePosition;
}


#pragma mark - Connection Drawing

- (void)startNewConnectionDrawingFromLet:(LetView *)aLetView {
  
  ObjectView *fromObject = (ObjectView *)aLetView.superview;
  
  // Set a thicker line for signal connections
  if (zg_object_get_connection_type([fromObject zgObject],
                                    (unsigned int) [[fromObject outletArray] indexOfObject:aLetView]) == ZG_CONNECTION_DSP) {
    newConnectionLineWidth = 3;
  }
  else {
    newConnectionLineWidth = 1;
  }

  // Start connection drawing from mid point of let view
  newConnectionStartPoint = NSMakePoint([fromObject frame].origin.x +
                                        [aLetView frame].origin.x + NSMidX([aLetView bounds]),
                                        [fromObject frame].origin.y +
                                        [aLetView frame].origin.y + NSMidY([aLetView bounds]));
  drawNewConnection = YES;
}

- (void)setNewConnectionEndPointFromLet:(LetView *)fromLetView withEvent:(NSEvent *)theEvent {
  
  ObjectView *fromObject = (ObjectView *)fromLetView.superview;
  
  newConnectionEndPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  for (ObjectView *toObject in arrayOfObjects) {
    for (LetView *toLetView in toObject.inletArray) {
      if (NSPointInRect(newConnectionEndPoint, [self convertRect:[toLetView bounds] fromView:toLetView])) {
        if (fromObject != toObject) {
          // Snap to inlet
          newConnectionEndPoint = NSMakePoint([toObject frame].origin.x +
                                              [toLetView frame].origin.x + NSMidX([toLetView bounds]),
                                              [toObject frame].origin.y +
                                              [toLetView frame].origin.y + NSMidY([toLetView bounds]));
          [self setNeedsDisplay:YES];
          [self needsDisplay];
          toLetView.isHighlighted = YES;
          [toLetView setNeedsDisplay:YES];
          [toLetView needsDisplay];
          return;
        }
      }
      else {
        // Not an inlet   
        toLetView.isHighlighted = NO;
        [toLetView setNeedsDisplay:YES];
        [toLetView needsDisplay];
      }
    }
  }
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}

- (void)endNewConnectionDrawingFromLet:(LetView *)fromLetView withEvent:(NSEvent *)theEvent {
  
  ObjectView *fromObject = (ObjectView *)fromLetView.superview;

  newConnectionEndPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  for (ObjectView *toObject in arrayOfObjects) {
    for (LetView *toLetView in toObject.inletArray) {
      if (NSPointInRect(newConnectionEndPoint, [self convertRect:[toLetView bounds]
                                                        fromView:toLetView])) {
        if (fromObject != toObject) {
          // Is a valid inlet - add connection
          newConnectionEndPoint = NSMakePoint([toObject frame].origin.x +
                                              [toLetView frame].origin.x + NSMidX([toLetView bounds]),
                                              [toObject frame].origin.y +
                                              [toLetView frame].origin.y + NSMidY([toLetView bounds]));
          zg_graph_add_connection(zgGraph,
                                  [fromObject zgObject],
                                  (unsigned int) [[fromObject outletArray] indexOfObject:fromLetView],
                                  [toObject zgObject],
                                  (unsigned int) [[toObject inletArray] indexOfObject:toLetView]);
            
          [self setNeedsDisplay:YES];
          [self needsDisplay];
          toLetView.isHighlighted = NO;
          [toLetView setNeedsDisplay:YES];
          [toLetView needsDisplay];
          return;
        }
      }
    }
  }
  [self resetNewConnection];
  [self setNeedsDisplay:YES];
  [self needsDisplay];
}

- (void)resetNewConnection { 
  drawNewConnection = NO;
  newConnectionEndPoint = NSMakePoint(0, 0);
  newConnectionStartPoint = NSMakePoint(0 , 0);
  newConnectionLineWidth = 1;
}

@end
