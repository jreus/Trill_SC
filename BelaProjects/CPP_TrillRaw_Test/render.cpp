#include <Bela.h>
#include <cmath>
#include <libraries/Gui/Gui.h>
#include <libraries/Trill/Trill.h>

#define I2C_ADDR 0x30

Trill ts;

AuxiliaryTask i2cReadTask;
int readInterval = 100; // read sensor every 100ms
int readIntervalSamples = 0;

void readTouch(void*) 
{
	ts.readI2C();
	for(unsigned int i=0; i < ts.rawData.size(); i++) {
		printf("%5.3f ", ts.rawData[i]);
	}
	printf("\n");
}

bool setup(BelaContext *context, void *userData)
{
	// try a different prescaler value for different capacitances (higher is good for longer cable runs)
	// option 0 gives the highest sensitivity
	int pre = 1; 
	// Threshold options for Trill sensor, float between 0 and 255.0/(2^numBits)
	float noiseThreshold = 0.0625;
	ts.setup(1, Trill::UNKNOWN, I2C_ADDR);
	ts.setMode(Trill::DIFF);
	ts.setNoiseThreshold(noiseThreshold);
	ts.setPrescaler(pre);
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
}
