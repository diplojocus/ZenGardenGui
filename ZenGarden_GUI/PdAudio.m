#import <Accelerate/Accelerate.h>
#import "PdAudio.h"

@implementation PdAudio

#define FRAMES_PER_BLOCK 256

@synthesize zgContext;
@synthesize numOutputChannels;

void renderCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer) {
  PdAudio *pdAudio = (PdAudio *) inUserData;

  // normal audio thread priority is 0.5 (default). Set it to be as high as possible.
  [NSThread setThreadPriority:1.0]; // necessary?
  
  // the buffer contains the input, and when libpd_process_float returns, it contains the output
  short *shortBuffer = (short *) inBuffer->mAudioData;
  
  inBuffer->mAudioDataByteSize = inBuffer->mAudioDataBytesCapacity; // entire buffer is filled
  int floatBufferLength = inBuffer->mAudioDataBytesCapacity / sizeof(short); // total samples
  float floatBuffer[floatBufferLength];
  memset(floatBuffer, 0, floatBufferLength * sizeof(float)); // clear the floatBuffer for input
  int numInputChannels = 0;
  
  // convert short to float, and uninterleave the samples into the float buffer
  // allow fallthrough in all cases
  switch (numInputChannels) {
    default: { // input channels > 2
      for (int i = 3; i < numInputChannels; ++i) {
        vDSP_vflt16(shortBuffer+i-1, numInputChannels, floatBuffer+(i-1)*FRAMES_PER_BLOCK, 1, FRAMES_PER_BLOCK);
      }
    }
    case 2: vDSP_vflt16(shortBuffer+1, numInputChannels, floatBuffer+FRAMES_PER_BLOCK, 1, FRAMES_PER_BLOCK);
    case 1: vDSP_vflt16(shortBuffer, numInputChannels, floatBuffer, 1, FRAMES_PER_BLOCK);
    case 0: break;
  }
  
  // convert samples to range of [-1,+1]
  float a = 0.000030517578125f;
  vDSP_vsmul(floatBuffer, 1, &a, floatBuffer, 1, floatBufferLength);
  
  // process the samples
  zg_process(pdAudio.zgContext, floatBuffer, floatBuffer);

  // clip the output to [-1,+1]
  float min = -1.0f;
  float max = 1.0f;
  vDSP_vclip(floatBuffer, 1, &min, &max, floatBuffer, 1, floatBufferLength);
  
  // scale the floating-point samples to short range
  a = 32767.0f;
  vDSP_vsmul(floatBuffer, 1, &a, floatBuffer, 1, floatBufferLength);
  
  // convert float to short and interleave into short buffer
  // allow fallthrough in all cases
  switch (pdAudio.numOutputChannels) {
    default: { // output channels > 2
      for (int i = 3; i < pdAudio.numOutputChannels; ++i) {
        vDSP_vfix16(floatBuffer+(i-1)*FRAMES_PER_BLOCK, pdAudio.numOutputChannels, shortBuffer+i-1, 1, FRAMES_PER_BLOCK);
      }
    }
    case 2: vDSP_vfix16(floatBuffer+FRAMES_PER_BLOCK, 1, shortBuffer+1, pdAudio.numOutputChannels, FRAMES_PER_BLOCK);
    case 1: vDSP_vfix16(floatBuffer, 1, shortBuffer, pdAudio.numOutputChannels, FRAMES_PER_BLOCK);
    case 0: break;
  }

  AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}


#pragma mark - PdAudio

- (id)init {
  self = [super init];
  if (self != nil) {
    numOutputChannels = 2;
    
    // configure the output audio format to standard 44100Hz 16-bit stereo
    outAsbd.mSampleRate = 44100.0;
    outAsbd.mFormatID = kAudioFormatLinearPCM;
    outAsbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked; // kAudioFormatFlagsCanonical;
    outAsbd.mBytesPerPacket = 4;
    outAsbd.mFramesPerPacket = 1;
    outAsbd.mBytesPerFrame = 4;
    outAsbd.mChannelsPerFrame = 2;
    outAsbd.mBitsPerChannel = 16;
    outAsbd.mReserved = 0;
    
    // create the new audio buffer
    // http://developer.apple.com/library/mac/#documentation/MusicAudio/Reference/AudioQueueReference/Reference/reference.html
    OSStatus err = AudioQueueNewOutput(&outAsbd, renderCallback, self, NULL, kCFRunLoopCommonModes, 0, &outAQ);
    AudioQueueSetParameter(outAQ, kAudioQueueParam_Volume, 1.0f);
    
    // create the new context
    zgContext = zg_new_context(2, 2, FRAMES_PER_BLOCK, 44100.0f, NULL, NULL);
    
    // create three audio buffers to go into the new queue and initialise them
    AudioQueueBufferRef outBuffer;
    for (int i = 0; i < 3; i++) {
      err = AudioQueueAllocateBuffer(outAQ, outAsbd.mBytesPerFrame*FRAMES_PER_BLOCK, &outBuffer);
      renderCallback(self, outAQ, outBuffer);
    }
    
    err = AudioQueuePrime(outAQ, 0, NULL);
  }
  return self;
}

- (void)dealloc {
  AudioQueueStop(outAQ, YES);
  AudioQueueDispose(outAQ, YES);
  zg_delete_context(zgContext);
  [super dealloc];
}

- (void)play {
  AudioQueueStart(outAQ, NULL);
}

- (void)pause {
  AudioQueuePause(outAQ);
}


@end
