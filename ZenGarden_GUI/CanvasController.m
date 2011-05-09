//
//  CanvasController.m
//  ZenGarden_GUI
//
//  Created by Joe White on 28/04/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CanvasController.h"
#import "ZenGarden.h"

#define NUM_ITERATIONS 9999985

@implementation CanvasController

- (id)init {
  
    self = [super init];
    if (self) {
      
    }
    
    return self;
}

- (void)dealloc {
  
    [super dealloc];
}

void callbackFunction(ZGCallbackFunction function, void *userData, void *ptr) {
    switch (function) {
      case ZG_PRINT_STD: {
        printf("%s\n", (char *) ptr);
        break;
      }
      case ZG_PRINT_ERR: {
        printf("ERROR: %s\n", (char *) ptr);
        break;
      }
      default: {
        break;
      }
    }
}

-(void)main {
  
  const int numInputChannels = 2;
  const int numOutputChannels = 2;
  const int blockSize = 64;
  const float sampleRate = 22050.0f;
  
  struct timeval start;
  struct timeval end;
  
  // pass directory and filename of the patch to load
  PdContext *context = zg_new_context(numInputChannels, numOutputChannels, blockSize, sampleRate,
                                      callbackFunction, NULL);
  PdGraph *graph = zg_new_graph(context, "/Users/mhroth/workspace/ZenGarden/test/", "MessageMessageBox.pd");
  if (graph == NULL) {
    zg_delete_context(context);
  }
  
  zg_attach_graph(context, graph);
  
  float *inputBuffers = (float *) calloc(numInputChannels * blockSize, sizeof(float));
  float *outputBuffers = (float *) calloc(numOutputChannels * blockSize, sizeof(float));
  
  gettimeofday(&start, NULL);
  
  for (int i = 0; i < NUM_ITERATIONS; i++) {
    zg_process(context, inputBuffers, outputBuffers);
  }
  
  gettimeofday(&end, NULL);
  double elapsedTime = (end.tv_sec - start.tv_sec) * 1000.0; // sec to ms
  elapsedTime += (end.tv_usec - start.tv_usec) / 1000.0; // us to ms
  printf("Runtime is: %i iterations in %f milliseconds == %f iterations/second.\n", NUM_ITERATIONS,
         elapsedTime, ((double) NUM_ITERATIONS)*1000.0/elapsedTime);
  double simulatedTime = ((double) blockSize / (double) sampleRate) * (double) NUM_ITERATIONS * 1000.0; // milliseconds
  printf("Runs in realtime: %s (x%.3f)\n", (simulatedTime >= elapsedTime) ? "YES" : "NO", simulatedTime/elapsedTime);
  
  zg_delete_context(context);
  free(inputBuffers);
  free(outputBuffers);
}

@end
