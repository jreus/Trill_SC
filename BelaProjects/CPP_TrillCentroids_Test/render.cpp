#include <Bela.h>
#include <cmath>
#include <libraries/Trill/Trill.h>

#define NUM_TOUCH 5 // Maximum number of centroids detected by Trill sensor
#define I2C_ADDR 0x20// I2C Addr of Trill

Trill ts;

AuxiliaryTask centroidReadTask;
int readInterval = 100; // read sensor every 100ms
int readIntervalSamples = 0;

// CENTROID STATE VARIABLES
float gTouchLocations[NUM_TOUCH] = { 0.0, 0.0, 0.0, 0.0, 0.0 };
//int gIntTouchLocations[NUM_TOUCH] = { 0, 0, 0, 0, 0 };
float gTouchSizes[NUM_TOUCH] = { 0.0, 0.0, 0.0, 0.0, 0.0 };
int gNumActiveTouches = 0;

void readCentroids(void*) 
{
	// Read locations from Trill sensor
	ts.readI2C();
	
	// Remap location and size so that they are expressed in a 0-1 range
	for(int i = 0; i <  ts.getNumTouches(); i++) {
		//gIntTouchLocations[i] = ts.touchLocation(i);
		gTouchLocations[i] = ts.touchLocation(i);
		gTouchSizes[i] = ts.touchSize(i);
	 }
	 gNumActiveTouches = ts.getNumTouches();

	 // For all innactive touches, set location and size to 0
	 for(int i = gNumActiveTouches; i <  NUM_TOUCH; i++) {
		gTouchLocations[i] = 0.f;
		gTouchSizes[i] = 0.f;
	 }
	
	// print feedback 
	printf("#%d: ", gNumActiveTouches);
	for(unsigned int i=0; i < NUM_TOUCH; i++) {
		printf("(%1.5f,%1.3f) ", gTouchLocations[i], gTouchSizes[i]);
	}
	printf("\n");
	
}

bool setup(BelaContext *context, void *userData)
{
	float thresh = 0.016;
	int pre = 1; // adjust this value when using Trill Craft to work with your setup
	
	// mode=Trill::NORMAL for centroid-tracking behavior
	if(ts.setup(1, Trill::UNKNOWN, I2C_ADDR) != 0) {
		fprintf(stderr, "Unable to initialise touch sensor\n");
		return false;
	} else {
		printf("Trill sensor found: devtype %s, firmware_v %d\n", Trill::getNameFromDevice(ts.deviceType()).c_str(), ts.firmwareVersion());
		ts.printDetails();
	}
	ts.setNoiseThreshold(thresh);
	ts.setPrescaler(pre);
	// Exit program if sensor is a Trill 2D
	if(!ts.is1D()) {
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
}

