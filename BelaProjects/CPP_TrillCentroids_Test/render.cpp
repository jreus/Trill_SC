#include <Bela.h>
#include <cmath>
#include <libraries/Trill/Trill.h>

#define NUM_TOUCH 5 // Maximum number of centroids detected by Trill sensor

Trill ts;

AuxiliaryTask centroidReadTask;
int readInterval = 100; // read sensor every 100ms
int readIntervalSamples = 0;

// Allowable prescaler values for Trill sensor
int gPrescalerOpts[6] = {1, 2, 4, 8, 16, 32};
// Allowable noise threshold values for Trill sensor
int gThresholdOpts[7] = {0, 10, 20, 30, 40, 50, 60};


// CENTROID STATE VARIABLES
float gTouchLocations[NUM_TOUCH] = { 0.0, 0.0, 0.0, 0.0, 0.0 };
float gTouchSizes[NUM_TOUCH] = { 0.0, 0.0, 0.0, 0.0, 0.0 };
int gNumActiveTouches = 0;


void readCentroids(void*) 
{
	// Read locations from Trill sensor
	ts.readLocations();
	
	// Remap location and size so that they are expressed in a 0-1 range
	for(int i = 0; i <  ts.numberOfTouches(); i++) {
		gTouchLocations[i] = map(ts.touchLocation(i), 0, 3200, 0.f, 1.f);
		gTouchSizes[i] = ts.touchSize(i);
	 }
	 gNumActiveTouches = ts.numberOfTouches();

	 // For all innactive touches, set location and size to 0
	 for(int i = gNumActiveTouches; i <  NUM_TOUCH; i++) {
		gTouchLocations[i] = 0.f;
		gTouchSizes[i] = 0.f;
	 }
	
	// print feedback 
	printf("#%d: ", gNumActiveTouches);
	for(unsigned int i=0; i < NUM_TOUCH; i++) {
		printf("(%1.5f,%4.f) ", gTouchLocations[i], gTouchSizes[i]);			
	}
	printf("\n");
	
}

bool setup(BelaContext *context, void *userData)
{
	int thresh=6;
	int pre=1; // should be 0 for Trill Bar, adjust this value when using Trill Craft to work with your setup 
	
	// mode=Trill::NORMAL for centroid-tracking behavior
	if(ts.setup(1, 0x18, Trill::NORMAL, gThresholdOpts[thresh], gPrescalerOpts[pre]) != 0) {
		fprintf(stderr, "Unable to initialise touch sensor\n");
		return false;
	} else {
		printf("Trill sensor found: devtype %d, firmware_v %d\n", ts.deviceType(), ts.firmwareVersion());
    	printf("Initialized with i2c_bus: %d  i2c_addr: %d  mode: %d  thresh: %d  pre: %d\n", 1, 0x18, Trill::NORMAL, gThresholdOpts[thresh], gPrescalerOpts[pre]);
	}
	
	 // Exit program if sensor is a Trill 2D
	if(ts.deviceType() == Trill::TWOD) {
		fprintf(stderr, "This program calculates linear position centroids and does not work with two-dimensional trill sensors.\n");
		return false;
	}
	
	centroidReadTask = Bela_createAuxiliaryTask(readCentroids, 50, "I2C-read", NULL);
	readIntervalSamples = context->audioSampleRate * (readInterval/1000.f);

	return true;
}

void render(BelaContext *context, void *userData)
{
	static int readCount = 0;
	for(unsigned int n=0; n < context->audioFrames; n++) {
		if(++readCount >= readIntervalSamples) {
			readCount = 0;
			Bela_scheduleAuxiliaryTask(centroidReadTask); // run the aux task every so many samples
		}
	}
}

void cleanup(BelaContext *context, void *userData)
{
	ts.cleanup();
}

