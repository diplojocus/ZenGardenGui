/**
 * This software is copyrighted by Reality Jockey Ltd. and Peter Brinkmann. 
 * The following terms (the "Standard Improved BSD License") apply to 
 * all files associated with the software unless explicitly disclaimed 
 * in individual files:
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * 
 * 1. Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above  
 * copyright notice, this list of conditions and the following 
 * disclaimer in the documentation and/or other materials provided
 * with the distribution.
 * 3. The name of the author may not be used to endorse or promote
 * products derived from this software without specific prior 
 * written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 * PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR
 * BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,   
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
 * IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
 * THE POSSIBILITY OF SUCH DAMAGE.
 */

#import <Accelerate/Accelerate.h>
#import "PdAudio.h"

@implementation PdAudio

@synthesize audioUnit;
@synthesize sampleRate;
@synthesize bufferSize;
@synthesize numInputChannels;
@synthesize numOutputChannels;
@synthesize microphoneVolume;
@synthesize floatBuffer;
@synthesize floatBufferLength;
@synthesize isUsingHeadphones;
@synthesize isPlaying;
@synthesize wasPlayingBeforeInterruption;

/** The render callback used by the audio unit. This is where all of the action is regarding the AU. */
// This function must be listed first (and thus defined) because a pointer to this function is used
// to define the AU later in the code during setup.
// http://developer.apple.com/iphone/library/documentation/AudioUnit/Reference/AUComponentServicesReference/Reference/reference.html#//apple_ref/doc/c_ref/AURenderCallback
OSStatus renderCallback(void *inRefCon, AudioUnitRenderActionFlags *ioActionFlags, 
                        const AudioTimeStamp *inTimeStamp, UInt32 inBusNumber,
                        UInt32 inNumberFrames, AudioBufferList *ioData) {
  
  // loop setup
  PdAudio *controller = (PdAudio *) inRefCon;
  
  // normal audio thread priority is 0.5 (default). Set it to be as high as possible.
  [NSThread setThreadPriority:1.0];
  
  // Get the remote io audio unit to render its input into the buffers
  // 1 == inBusNumber for mic input
  AudioUnitRender(controller.audioUnit, ioActionFlags, inTimeStamp, 1, inNumberFrames, ioData);
  
  // the buffer contains the input, and when libpd_process_float returns, it contains the output
  short *shortBuffer = (short *) ioData->mBuffers[0].mData;
  
  float *floatBuffer = controller.floatBuffer;
  int floatBufferLength = controller.floatBufferLength;
  int bufferSize = controller.bufferSize;
  int numInputChannels = controller.numInputChannels;
  int numOutputChannels = controller.numOutputChannels;

  // convert short to float, and uninterleave the samples into the float buffer
  // allow fallthrough in all cases
  switch (numInputChannels) {
    default: { // input channels > 2
      for (int i = 3; i < numInputChannels; ++i) {
        vDSP_vflt16(shortBuffer+i-1, numInputChannels, floatBuffer+(i-1)*bufferSize, 1, bufferSize);
      }
    }
    case 2: vDSP_vflt16(shortBuffer+1, numInputChannels, floatBuffer+bufferSize, 1, bufferSize);
    case 1: vDSP_vflt16(shortBuffer, numInputChannels, floatBuffer, 1, bufferSize);
    case 0: break;
  }

  // convert samples to range of [-1,+1], also accounting for microphone scale
  float a = 0.000030517578125f * controller.microphoneVolume; // == 1/32768 * microphone volume
  vDSP_vsmul(floatBuffer, 1, &a, floatBuffer, 1, floatBufferLength);

  // process the samples
  zg_process(zgContext, floatBuffer, floatBuffer);

  // clip the output to [-1,+1]
  float min = -1.0f;
  float max = 1.0f;
  vDSP_vclip(floatBuffer, 1, &min, &max, floatBuffer, 1, floatBufferLength);

  // scale the floating-point samples to short range
  a = 32767.0f;
  vDSP_vsmul(floatBuffer, 1, &a, floatBuffer, 1, floatBufferLength);

  // convert float to short and interleave into short buffer
  // allow fallthrough in all cases
  switch (numOutputChannels) {
    default: { // output channels > 2
      for (int i = 3; i < numOutputChannels; ++i) {
        vDSP_vfix16(floatBuffer+(i-1)*bufferSize, numOutputChannels, shortBuffer+i-1, 1, bufferSize);
      }
    }
    case 2: vDSP_vfix16(floatBuffer+bufferSize, 1, shortBuffer+1, numOutputChannels, bufferSize);
    case 1: vDSP_vfix16(floatBuffer, 1, shortBuffer, numOutputChannels, bufferSize);
    case 0: break;
  }
  
  return 0; // no errors
}
/*
- (void)printAudioSessionProperties {
  int outputBus = 0;
  int inputBus = 1;
  
  AudioStreamBasicDescription toneStreamFormatInputTest;
  memset(&toneStreamFormatInputTest, 0, sizeof(toneStreamFormatInputTest));
  UInt32 toneStreamFormatSize = sizeof(AudioStreamBasicDescription);
  AudioUnitGetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input,
      outputBus, &toneStreamFormatInputTest, &toneStreamFormatSize);
  NSLog(@"=== input stream format:");
  NSLog(@"  mSampleRate: %.0fHz", toneStreamFormatInputTest.mSampleRate);
  NSLog(@"  mFormatID: %lu", toneStreamFormatInputTest.mFormatID);
  NSLog(@"  mFormatFlags: %lu", toneStreamFormatInputTest.mFormatFlags);
  NSLog(@"  mBytesPerPacket: %lu", toneStreamFormatInputTest.mBytesPerPacket);
  NSLog(@"  mFramesPerPacket: %lu", toneStreamFormatInputTest.mFramesPerPacket);
  NSLog(@"  mBytesPerFrame: %lu", toneStreamFormatInputTest.mBytesPerFrame);
  NSLog(@"  mChannelsPerFrame: %lu", toneStreamFormatInputTest.mChannelsPerFrame);
  NSLog(@"  mBitsPerChannel: %lu", toneStreamFormatInputTest.mBitsPerChannel);
  
  
  AudioStreamBasicDescription toneStreamFormatOutputTest;
  memset (&toneStreamFormatOutputTest, 0, sizeof(toneStreamFormatOutputTest));
  AudioUnitGetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output,
      inputBus, &toneStreamFormatOutputTest, &toneStreamFormatSize);
  NSLog(@"=== output stream format:");
  NSLog(@"  mSampleRate: %.0fHz", toneStreamFormatOutputTest.mSampleRate);
  NSLog(@"  mFormatID: %lu", toneStreamFormatOutputTest.mFormatID);
  NSLog(@"  mFormatFlags: %lu", toneStreamFormatOutputTest.mFormatFlags);
  NSLog(@"  mBytesPerPacket: %lu", toneStreamFormatOutputTest.mBytesPerPacket);
  NSLog(@"  mFramesPerPacket: %lu", toneStreamFormatOutputTest.mFramesPerPacket);
  NSLog(@"  mBytesPerFrame: %lu", toneStreamFormatOutputTest.mBytesPerFrame);
  NSLog(@"  mChannelsPerFrame: %lu", toneStreamFormatOutputTest.mChannelsPerFrame);
  NSLog(@"  mBitsPerChannel: %lu", toneStreamFormatOutputTest.mBitsPerChannel);
  
  // print value of properties to check that everything was set properly
  Float64 audioSessionProperty64 = 0;
  Float32 audioSessionProperty32 = 0;
  UInt32 audioSessionPropertyU32 = 0;
  UInt32 audioSessionPropertySize64 = sizeof(audioSessionProperty64);
  UInt32 audioSessionPropertySize32 = sizeof(audioSessionProperty32);
  UInt32 audioSessionPropertySizeU32 = sizeof(audioSessionPropertyU32);
  AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareSampleRate, 
      &audioSessionPropertySize64, &audioSessionProperty64);
  NSLog(@"=== CurrentHardwareSampleRate: %.0fHz", audioSessionProperty64);
  if (sampleRate != audioSessionProperty64) {
    NSLog(@"=== WARNING: current sample rate %.0fHz is not the requested sample rate %.0fHz!",
        audioSessionProperty64, sampleRate);
  }
  
  AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareIOBufferDuration, 
      &audioSessionPropertySize32, &audioSessionProperty32);
  NSLog(@"=== CurrentHardwareIOBufferDuration: %3.2fms", audioSessionProperty32*1000.0f);
  NSLog(@"=== block size: %ld", lrint(audioSessionProperty32 * audioSessionProperty64));
  if (bufferSize != lrint(audioSessionProperty32 * audioSessionProperty64)) {
    NSLog(@"=== WARNING: current buffer size %ld is not the requested buffer size %i!",
        lrint(audioSessionProperty32 * audioSessionProperty64), bufferSize);
  }
  
  AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareInputNumberChannels, 
      &audioSessionPropertySizeU32, &audioSessionPropertyU32);
  NSLog(@"=== CurrentHardwareInputNumberChannels: %lu", audioSessionPropertyU32);
  if (numInputChannels != audioSessionPropertyU32) {
    NSLog(@"=== WARNING: current number of input channels %lu is not the requested number %i!",
        audioSessionPropertyU32, numInputChannels);
  }
  
  AudioSessionGetProperty(kAudioSessionProperty_CurrentHardwareOutputNumberChannels, 
      &audioSessionPropertySizeU32, &audioSessionPropertyU32);
  NSLog(@"=== CurrentHardwareOutputNumberChannels: %lu", audioSessionPropertyU32);
  if (numOutputChannels != audioSessionPropertyU32) {
    NSLog(@"=== WARNING: current number of output channels %lu is not the requested number %i!",
          audioSessionPropertyU32, numOutputChannels);
  }
}
*/
// the interrupt listener for the audio session
void audioSessionInterruptListener(void *inClientData, UInt32 inInterruption) {
  PdAudio *controller = (PdAudio *) inClientData;
  switch (inInterruption) {
    case kAudioSessionBeginInterruption: {
      // when the interruption begins, suspend audio playback
      NSLog(@"AudioSession === kAudioSessionBeginInterruption");
      controller.wasPlayingBeforeInterruption = controller.isPlaying;
      [controller pause];
      break;
    }
    case kAudioSessionEndInterruption: {
      // when the interruption ends, resume audio playback
      NSLog(@"AudioSession === kAudioSessionEndInterruption");
      if (controller.wasPlayingBeforeInterruption) {
        [controller play]; // do not automatially being to play. Allow the user to resume playback.
      }
      break;
    }
    default: {
      break;
    }
  }
}

// the interrupt listener for when the audio route changes (e.g., headphones are added or removed)
// NOTE(mhroth): this function is also called if we are in the background and some other app grabs
// audio priority (e.g., iPod) and receives this callback
void audioSessionRouteChangeListener(void *indata, AudioSessionPropertyID property, UInt32 dataSize,
    const void* data) {
  switch (property) {
    case kAudioSessionProperty_AudioRouteChange: {
      NSLog(@"AudioSession === kAudioSessionProperty_AudioRouteChange");
      PdAudio *controller = (PdAudio *) indata;
      BOOL wasPlayingBeforeInterrupt = controller.isPlaying;
      [controller pause];
      [controller checkForHeadphones];
      // audio route changes may also change some audio session parameters, such as buffer size
      [controller setSampleRate:controller.sampleRate];
      [controller setBufferSize:controller.bufferSize];
      if (wasPlayingBeforeInterrupt) [controller play];
      
      // print new audio session properties
      [controller printAudioSessionProperties];
      break;
    }
    default: {
      NSLog(@"AudioSession === kAudioSessionProperty_???");
      break;
    }
  }
}

- (BOOL)checkForHeadphones {
  // get the name of the next route
  NSString *route = nil;
  UInt32 routeSize = sizeof(route);
  AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &routeSize, &route);
  
  // determine if headphones are plugged in
  if ([route isEqualToString:@"HeadsetInOut"]) {
    isUsingHeadphones = YES; // headphone with microphone plugged in
  } else if ([route isEqualToString:@"HeadphonesAndMicrophone"]) {
    isUsingHeadphones = YES; // headphone with no microphone plugged in
  } else if ([route isEqualToString:@"HeadsetBT"]) {
    isUsingHeadphones = YES; // bluetooth headphones plugged in
  } else {
    isUsingHeadphones = NO;
  }
  
  [[PdBase class] performSelectorOnMainThread:@selector(sendAudioRouteChangedToDelegate:) withObject:route
      waitUntilDone:NO];
  SEL headphonesSelector = isUsingHeadphones ? @selector(sendHeadphonesAdded) : @selector(sendHeadphonesRemoved);
  [[PdBase class] performSelectorOnMainThread:headphonesSelector withObject:nil waitUntilDone:NO];
  
  NSLog(@"AudioSession === kAudioSessionProperty_AudioRoute: %@", route);
  NSLog(@"Headphones %@ plugged in.", isUsingHeadphones ? @"ARE" : @"are NOT");
  
  return isUsingHeadphones;
}

- (id)initWithSampleRate:(float)newSampleRate andTicksPerBuffer:(int)ticks 
    andNumberOfInputChannels:(int)inputChannels andNumberOfOutputChannels:(int)outputChannels {
  self = [super init];
  if (self != nil) {
    audioUnit = NULL;
    numInputChannels = inputChannels;
    numOutputChannels = outputChannels;
    sampleRate = (Float64) newSampleRate;
    microphoneVolume = 1.0f;
    
    //recording
    recording = NO;
    recordBufferWriteIndex = 0;
    
    isPlaying = NO;
    wasPlayingBeforeInterruption = NO;
    
    int numberOfChannels = (numInputChannels < numOutputChannels) ? numOutputChannels : numInputChannels;
    floatBufferLength = [PdBase getBlockSize] * ticks * numberOfChannels;
    floatBuffer = (float *) malloc(floatBufferLength * sizeof(float));
    
    [self initializeAudioSession:ticks];
    [self initializeAudioUnit];
    [PdBase openAudioWithSampleRate:sampleRate andInputChannels:numInputChannels 
        andOutputChannels:numOutputChannels andTicksPerBuffer:ticks];
    [PdBase computeAudio:YES];
  }
  return self;
}

- (void)dealloc {
  [self stopRecording];
  [self pause];
  if (recordBuffer) free(recordBuffer);
  if (floatBuffer) free(floatBuffer);
  floatBuffer = nil;
  AudioSessionSetActive(false);
  AudioComponentInstanceDispose(audioUnit);
  [super dealloc];
}

- (void)play {
  AudioSessionSetActive(true);
  AudioOutputUnitStart(audioUnit);
  isPlaying = YES;
  NSLog(@"AudioSession === starting audio unit.");
}

- (void)pause {
  AudioOutputUnitStop(audioUnit);
  AudioSessionSetActive(false);
  isPlaying = NO;
  NSLog(@"AudioSession === stopping audio unit.");
}

- (void)enableAudioSession:(BOOL)isActive {
  AudioSessionSetActive(isActive ? true : false);
  /*
  if (isActive) {
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
    AudioSessionSetActive(true);
  } else {
    AudioSessionSetActive(false);
    UInt32 audioCategory = kAudioSessionCategory_SoloAmbientSound;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
  }
  */
}

// private
- (void)initializeAudioSession:(int)ticks {
  /*** Create AudioSession interface to Core Audio === ***/
  
  // initialise the audio session
  AudioSessionInitialize(NULL, NULL, audioSessionInterruptListener, self);
  
  // set the audio category to PlayAndRecord so that we can have low-latency IO
  UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
  AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
  /*
   * NOTE(mhroth): does not seem to be working because when a BT headset is used, the samplerate
   * is dropped to 8KHz. Not sure how to reset it.
   */
  // enable bluetooth input
  UInt32 allowBluetoothInput = 1;
  AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryEnableBluetoothInput,
      sizeof(allowBluetoothInput), &allowBluetoothInput);
   
  // set the sample rate of the session
  [self setSampleRate:sampleRate];
  NSLog(@"AudioSession === setting PreferredHardwareSampleRate to %.0fHz.", sampleRate);
  
  // set buffer size
  bufferSize = [PdBase getBlockSize] * ticks; // requested buffer size
  Float32 bufferDuration = ((Float32) bufferSize) / sampleRate; // buffer duration in seconds
  [self setBufferSize:bufferSize];
  NSLog(@"AudioSession === setting PreferredHardwareIOBufferDuration to %3.2fms.", bufferDuration*1000.0);
  
  // NOTE: note that round-off errors make it hard to determine whether the requested buffersize
  // was granted. we just assume that it was and carry on.
  
  // register the audio session route change listener
  AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioSessionRouteChangeListener, self);
  
  AudioSessionSetActive(true);
  NSLog(@"AudioSession === starting Audio Session.");
  
  // check to see if headphones are plugged in
  [self checkForHeadphones];
}

- (void)setSampleRate:(Float64)newSampleRate {
  AudioQueueSetProperty(kAudioDevicePropertyNominalSampleRate, sizeof(newSampleRate), &newSampleRate);

  AudioQueueSetProperty(<#AudioQueueRef inAQ#>, <#AudioQueuePropertyID inID#>, <#const void *inData#>, <#UInt32 inDataSize#>)
}

- (void)setBufferSize:(int)newBufferSize {
  Float32 bufferDuration = ((Float32) bufferSize) / sampleRate; // buffer duration in seconds
  AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, 
      sizeof(bufferDuration), &bufferDuration);
}

- (void)initializeAudioUnit {
  // http://developer.apple.com/iphone/library/documentation/Audio/Conceptual/AudioUnitLoadingGuide_iPhoneOS/AccessingAudioUnits/LoadingIndividualAudioUnits.html#//apple_ref/doc/uid/TP40008781-CH103-SW11
  
  // create an AudioComponentDescription describing a RemoteIO audio unit
  // such a component provides an interface from microphone to speaker
  AudioComponentDescription auDescription;
  auDescription.componentType = kAudioUnitType_Output;
  auDescription.componentSubType = kAudioUnitSubType_RemoteIO;
  auDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
  auDescription.componentFlags = 0;
  auDescription.componentFlagsMask = 0;
  
  // find an audio component fitting the given description
  AudioComponent foundComponent = AudioComponentFindNext(NULL, &auDescription);
  
  // create a new audio unit instance
  AudioComponentInstanceNew(foundComponent, &audioUnit);
  
  // connect the AU to hardware input and output
  OSStatus err = 0; // http://developer.apple.com/iphone/library/documentation/AudioUnit/Reference/AUComponentServicesReference/Reference/reference.html
  UInt32 doSetProperty = 1;
  AudioUnitElement inputBus = 1;
  AudioUnitElement outputBus = 0;
  // connect the AU to the microphone 
  AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 
      inputBus, &doSetProperty, sizeof(doSetProperty));
  // connect the AU to the soundout
  AudioUnitSetProperty(audioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Output, 
      outputBus, &doSetProperty, sizeof(doSetProperty));
  
  // set the sample rate on the input and output busses
  AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Input, outputBus, 
      &sampleRate, sizeof(sampleRate));
  AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SampleRate, kAudioUnitScope_Output, inputBus, 
      &sampleRate, sizeof(sampleRate));
  
  // request the audio data stream format for input and output
  // NOTE: this really is a request. The system will set the stream to whatever it damn well pleases.
  // The settings here are what are known to work: 16-bit mono (interleaved) @ 22050
  // and thus no rigorous checking is done in order to ensure that the request stream format
  // is actually being used. It would be nice to be able to use format kAudioFormatFlagsNativeFloatPacked
  // which would allow us to avoid converting between float and int sample type manually.
  AudioStreamBasicDescription toneStreamFormatInput;
  memset (&toneStreamFormatInput, 0, sizeof (toneStreamFormatInput)); // clear all fields
  toneStreamFormatInput.mSampleRate       = sampleRate;
  toneStreamFormatInput.mFormatID         = kAudioFormatLinearPCM;
  toneStreamFormatInput.mFormatFlags      = kAudioFormatFlagsCanonical;
  toneStreamFormatInput.mBytesPerPacket   = 2 * numInputChannels;
  toneStreamFormatInput.mFramesPerPacket  = 1;
  toneStreamFormatInput.mBytesPerFrame    = 2 * numInputChannels;
  toneStreamFormatInput.mChannelsPerFrame = numInputChannels;
  toneStreamFormatInput.mBitsPerChannel   = 16;
  
  // recording
  // samples per buffer * 2 bytes per sample * 2 channels * number of buffers to store before writing
  recordBufferLength = bufferSize * 2 * 2 * 100;
  recordBufferHead = 0;
  recordPacketsWritten = 0;
  recordBuffer = (char *) calloc(recordBufferLength, sizeof(char));
  
  
  // apply the audio data stream format to bus 0 of the input scope of the Remote I/O AU. This is
  // actually the OUTPUT to the system.
  err = AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, outputBus, 
                             &toneStreamFormatInput, sizeof(toneStreamFormatInput));
  
  // set audio output format to 16-bit stereo
  AudioStreamBasicDescription toneStreamFormatOutput;
  memset (&toneStreamFormatOutput, 0, sizeof(toneStreamFormatOutput));
  toneStreamFormatOutput.mSampleRate       = sampleRate;
  toneStreamFormatOutput.mFormatID         = kAudioFormatLinearPCM;
  toneStreamFormatOutput.mFormatFlags      = kAudioFormatFlagsCanonical;
  toneStreamFormatOutput.mBytesPerPacket   = 2 * numOutputChannels;
  toneStreamFormatOutput.mFramesPerPacket  = 1;
  toneStreamFormatOutput.mBytesPerFrame    = 2 * numOutputChannels;
  toneStreamFormatOutput.mChannelsPerFrame = numOutputChannels;
  toneStreamFormatOutput.mBitsPerChannel   = 16;
  
  // apply the audio data stream format to bus 1 of the output scope of the Remote I/O AU. This is
  // actually the INPUT to the system.
  AudioUnitSetProperty(audioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, inputBus, 
                       &toneStreamFormatOutput, sizeof(toneStreamFormatOutput));
  
  // register the render callback. This is the function that the audio unit calls when it needs audio
  // the callback function (renderCallback()) is defined at the top of the page.
  AURenderCallbackStruct renderCallbackStruct;
  renderCallbackStruct.inputProc = renderCallback;
  renderCallbackStruct.inputProcRefCon = self; // this is an optional data pointer
                                               // pass the AudioController object
  
  AudioUnitSetProperty(audioUnit, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 
                       outputBus, &renderCallbackStruct, sizeof(renderCallbackStruct));
  
  // disable buffer allocation on output (necessary?)
  // http://developer.apple.com/iphone/library/documentation/Audio/Conceptual/AudioUnitLoadingGuide_iPhoneOS/AccessingAudioUnits/LoadingIndividualAudioUnits.html#//apple_ref/doc/uid/TP40008781-CH103-SW19
  doSetProperty = 0;
  AudioUnitSetProperty(audioUnit, kAudioUnitProperty_ShouldAllocateBuffer, kAudioUnitScope_Output, 
                       outputBus, &doSetProperty, sizeof(doSetProperty));
  
  // finally, initialise the audio unit. It is ready to go.
  AudioUnitInitialize(audioUnit);
  
  // ensure that all parameters and settings have been successfully applied
  [self printAudioSessionProperties];
}


@end
