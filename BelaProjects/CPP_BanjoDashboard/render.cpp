 /**
	Banjo Status Dashboard

 * 
 * 
 **/
#include <Bela.h>
#include <cmath>
#include <libraries/Gui/Gui.h>
#include <libraries/Trill/Trill.h>


/** Audio Input Channel Mappings **/
#define MIC_INCHAN 0

/** Analog Input Channel Mappings **/
#define STRING1_INCHAN 1
#define STRING2_INCHAN 1
#define STRING3_INCHAN 1
#define STRING4_INCHAN 1
#define STRING5_INCHAN 0
#define MAG1_INCHAN 2
#define MAG2_INCHAN 3

int gAudioFramesPerAnalogFrame = 0;

/** Trill Sensor **/
#define NUM_TOUCH 5 // Number of simultaneous touches detectable on Trill sensor

Trill touchSensor;
int gPrescalerOpts[6] = {1, 2, 4, 8, 16, 32}; // possible prescaler (sensitivity) settings, lower = more sensitvive
int gThresholdOpts[7] = {0, 10, 20, 30, 40, 50, 60}; // noise threshhold settings

// Touch range on which the re-mapping will be done
int gTouchSizeRange[2] = { 100, 6000 };

// Touchpad state variables
float gTouchLocation[NUM_TOUCH] = { 0.0, 0.0, 0.0, 0.0, 0.0 }; // touch positions
float gTouchSize[NUM_TOUCH] = { 0.0, 0.0, 0.0, 0.0, 0.0 }; // touch sizes
int gNumActiveTouches = 0; // Number of active touches

// Sleep time (microseconds) for auxiliary sensor read task
int gTaskSleepTime = 1000;


/** GUI **/
Gui gui;
#define GUI_FRAME_RATE 30; // gui framerate (in Hz) -> should match framerate of P5 sketch
#define GUI_BUFFER_LENGTH 256 // this number must match the buffer length in sketch.js
float gTimePeriod; // period (in seconds) between data sends to the GUI


// arrays for sending data to the gui
float sigString1[GUI_BUFFER_LENGTH];
float sigString2[GUI_BUFFER_LENGTH];
float sigString3[GUI_BUFFER_LENGTH];
float sigString4[GUI_BUFFER_LENGTH];
float sigString5[GUI_BUFFER_LENGTH];

// compress two mag signals into a single array as a hack around the 10 index limit for GUI data buffers
float sigMag[GUI_BUFFER_LENGTH * 2];
/*
float sigMag1[GUI_BUFFER_LENGTH];
float sigMag2[GUI_BUFFER_LENGTH];
*/
float sigMic[GUI_BUFFER_LENGTH];





/*
* Function to be run on an auxiliary task that reads data from the Trill sensor.
* Here, a loop is defined so that the task runs recurrently for as long as the
* audio thread is running.
*/
void auxiliarySensorReadLoop(void*)
{
 // ????? Where is gShouldStop defined?
 while(!gShouldStop)
 {
	 // Read locations from Trill sensor
	 touchSensor.readLocations();
	 
	 // Normalize location and size so that they are expressed in a 0-1 range
	 for(int i = 0; i <  touchSensor.numberOfTouches(); i++) {
		 gTouchLocation[i] = map(touchSensor.touchLocation(i), 0, 3200, 0, 1);
		 gTouchLocation[i] = constrain(gTouchLocation[i], 0, 1);
		 gTouchSize[i] = map(touchSensor.touchSize(i), gTouchSizeRange[0], gTouchSizeRange[1], 0, 1);
		 gTouchSize[i] = constrain(gTouchSize[i], 0, 1);
	 }
	 gNumActiveTouches = touchSensor.numberOfTouches();
	 // For all innactive touches, set location and size to 0
	 for(int i = gNumActiveTouches; i <  NUM_TOUCH; i++) {
		 gTouchLocation[i] = 0.0;
		 gTouchSize[i] = 0.0;
	 }

	 // Sleep for ... micro seconds
	 usleep(gTaskSleepTime);
 }
}

// send data back to the browser gui
void updateGui() {
			// Send touch sensor data
			gui.sendBuffer(0, gNumActiveTouches);
			gui.sendBuffer(1, gTouchLocation);
			gui.sendBuffer(2, gTouchSize);

			// Send string/audio signals
			gui.sendBuffer(3, sigString1); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(4, sigString2); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(5, sigString3); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(6, sigString4); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(7, sigString5); // Bela.data.buffers[idx], value (scalar, array, vector)
		
			
			// Send mag sensor values
			//gui.sendBuffer(8, sigMag1); // Bela.data.buffers[idx], value (scalar, array, vector)
			//gui.sendBuffer(9, sigMag2); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(8, sigMag); // hack

			// Send mic input signal
			//gui.sendBuffer(10, sigMic);	
			gui.sendBuffer(9, sigMic); // hack
}	



bool setup(BelaContext *context, void *userData)			
{
	int optpre = 1, optthresh = 6;
	
	// Check if analog channels are enabled
	if(context->analogFrames == 0 || context->analogFrames > context->audioFrames) {
		rt_printf("Error: analog must be enabled with 8 channels\n");
		return false;
	}

	// useful calculations
	if(context->analogFrames)
		gAudioFramesPerAnalogFrame = context->audioFrames / context->analogFrames;

	gTimePeriod = 1.0 / GUI_FRAME_RATE; 

	rt_printf("Audio Frames Per Analog Frame: %d", gAudioFramesPerAnalogFrame);
	
	// zero GUI buffers
	for(int i = 0; i < GUI_BUFFER_LENGTH; i++) {
		sigString1[i] = 0.0;
		sigString2[i] = 0.0;
		sigString3[i] = 0.0;
		sigString4[i] = 0.0;
		sigString5[i] = 0.0;
		//sigMag1[i] = 0.0;
		//sigMag2[i] = 0.0;
		sigMag[i] = 0.0; // hack
		sigMic[i] = 0.0;
	}
	
	// Init trill state, NORMAL==centroid, DIFF==different from baseline
	// baseline can be recomputed using touchSensor.updateBaseline()
	if(touchSensor.setup(1, 0x18, Trill::NORMAL, gThresholdOpts[optthresh], gPrescalerOpts[optpre]) != 0) {
		fprintf(stderr, "Unable to initialise touch sensor\n");
		return false;
	}

	touchSensor.printDetails();

	 // Exit program if sensor is not a Trill Bar
	if(touchSensor.deviceType() != Trill::ONED) {
		fprintf(stderr, "This example is supposed to work only with a One-Dimensional Trill Sensor. \n You may have to adapt it to make it work with other Trill devices.\n");
		return false;
	}

	// Set and schedule auxiliary task for reading sensor data from the I2C bus
	Bela_scheduleAuxiliaryTask(Bela_createAuxiliaryTask(auxiliarySensorReadLoop, 50, "I2C-read", NULL));

	// Setup the GUI
	gui.setup(context->projectName);
	return true;
}

void render(BelaContext *context, void *userData)
{	
	static unsigned int cg = 0, c = 0;
	unsigned int m = 0;
	float s1 = 0.0, s2 = 0.0, s3 = 0.0, s4 = 0.0, s5 = 0.0, mag1 = 0.0, mag2 = 0.0, mic = 0.0;
	float mixL = 0.0, mixR = 0.0;
	
	float amp = 0.8;
		
	for(unsigned int n = 0; n < context->audioFrames; n++) {
		
		if(gAudioFramesPerAnalogFrame && !(n % gAudioFramesPerAnalogFrame)) {
			m = n / gAudioFramesPerAnalogFrame;
			s1 = analogRead(context, m, STRING1_INCHAN) - 0.5;
			s2 = analogRead(context, m, STRING2_INCHAN) - 0.5;
			s3 = analogRead(context, m, STRING3_INCHAN) - 0.5;
			s4 = analogRead(context, m, STRING4_INCHAN) - 0.5;
			s5 = analogRead(context, m, STRING5_INCHAN) - 0.5;
			mag1 = analogRead(context, m, MAG1_INCHAN) - 0.5;
			mag2 = analogRead(context, m, MAG2_INCHAN) - 0.5;
		}
		
		mic = audioRead(context, n, MIC_INCHAN);

		// TODO: Why is this sending out a steady sine tone?
		mixL = (mic + s1 + s3 + s5) * amp;
		mixR = (mic + s2 + s4) * amp;

		audioWrite(context, n, 0, mixL);	
		audioWrite(context, n, 1, mixR);
		
		// GUI buffers
		if(n == 0) { // every block add a sample to the gui buffers
			sigString1[c] = s1;
			sigString2[c] = s2;
			sigString3[c] = s3;
			sigString4[c] = s4;
			sigString5[c] = s5;

			// hack
			sigMag[c] = mag1;
			sigMag[c + GUI_BUFFER_LENGTH] = mag2;

			//sigMag1[c] = analogRead(context, n, MAG1_INCHAN) - 0.5;
			//sigMag2[c] = analogRead(context, n, MAG2_INCHAN) - 0.5;

			sigMic[c] = mic;

			c++;
			if(c >= GUI_BUFFER_LENGTH) {
				c = 0;
			}
		};
		
		if(cg >= gTimePeriod*context->audioSampleRate) // send GUI data every gTimePeriod seconds
		{
			cg = 0;
			updateGui();
		}
		cg++;
	}
}


void cleanup(BelaContext *context, void *userData)
{

}
