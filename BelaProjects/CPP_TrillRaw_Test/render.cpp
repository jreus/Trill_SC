#include <Bela.h>
#include <cmath>
#include <libraries/Gui/Gui.h>
#include <libraries/Trill/Trill.h>

Trill ts;

AuxiliaryTask i2cReadTask;
int readInterval = 100; // read sensor every 100ms
int readIntervalSamples = 0;

// Prescaler options for Trill sensor
int gPrescalerOpts[6] = {1, 2, 4, 8, 16, 32};
// Threshold options for Trill sensor, int: 5-255
int gNoiseThreshold = 60;


void readTouch(void*) 
{
	if(ts.isReady()) {
		ts.readI2C();
		for(unsigned int i=0; i < sizeof(ts.rawData)/sizeof(int); i++) {
			printf("%5d ", ts.rawData[i]);			
		}
		printf("\n");
	}
}

bool setup(BelaContext *context, void *userData)
{
	// try a different prescaler value for different capacitances (higher is good for longer cable runs)
	// option 0 gives the highest sensitivity
	int pre = 1; 
	ts.setup(1, 0x18, Trill::DIFF, gNoiseThreshold, gPrescalerOpts[pre]);
	i2cReadTask = Bela_createAuxiliaryTask(readTouch, 50, "I2C-read", NULL);
	readIntervalSamples = context->audioSampleRate * (readInterval/1000.f);
	return true;
}

void render(BelaContext *context, void *userData)
{
	static int readCount = 0;
	for(unsigned int n=0; n < context->audioFrames; n++) {
		if(++readCount >= readIntervalSamples) {
			readCount = 0;
			Bela_scheduleAuxiliaryTask(i2cReadTask); // run the aux task every so many samples
		}
	}
}

void cleanup(BelaContext *context, void *userData)
{
	ts.cleanup();
}