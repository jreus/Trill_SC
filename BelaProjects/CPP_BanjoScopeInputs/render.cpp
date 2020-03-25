/*
Simple Analog Scope reflecting the inputs of the four pre-amp channels
of the little vertical magnet board.
*/

#include <Bela.h>
#include <cmath>
#include <libraries/Scope/Scope.h>

Scope scope;

// For this example you need to set the Analog Sample Rate to 
// 44.1 KHz which you can do in the settings tab.

bool setup(BelaContext *context, void *userData)
{
	// setup the scope with 4 channels at the analog sample rate
	scope.setup(10, context->analogSampleRate);
	
	if(context->analogInChannels < 8)
	{
		fprintf(stderr, "Error: for this project you need at least eight analog inputs\n");
		return false;
	}

	return true;
}

void render(BelaContext *context, void *userData)
{
	for(unsigned int n = 0; n < context->analogFrames; n++) {
		// log the sine wave and sensor values on the scope
		// Analog 0/1 are the integrator pre-amps
		// Analog 4/5 are the audio pre-amps
		

		// roughly zero-center all the signals by subtracting 0.5
		scope.log(
			audioRead(context, n, 0),
			audioRead(context, n, 1),
			analogRead(context, n, 0) - 0.5,
			analogRead(context, n, 1) - 0.5,
			analogRead(context, n, 4) - 0.5,
			analogRead(context, n, 5) - 0.5,
			analogRead(context, n, 2) - 0.5,
			analogRead(context, n, 3) - 0.5,
			analogRead(context, n, 6) - 0.5,
			analogRead(context, n, 7) - 0.5
		);
	}
}

void cleanup(BelaContext *context, void *userData)
{

}
