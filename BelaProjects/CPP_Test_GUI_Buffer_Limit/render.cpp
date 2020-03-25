 /**
Test GUI Buffer Limits
* 
 **/
#include <Bela.h>
#include <cmath>
#include <libraries/Gui/Gui.h>

Gui gui;
#define GUI_FRAME_RATE 30; // gui framerate (in Hz) -> should match framerate of P5 sketch
float gTimePeriod; // period (in seconds) between data sends to the GUI

void updateGui() {
			gui.sendBuffer(0, 0.1);
			gui.sendBuffer(1, 1.1);
			gui.sendBuffer(2, 2.2);
			gui.sendBuffer(3, 3.3); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(4, 4.4); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(5, 5.5); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(6, 6.6); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(7, 7.7); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(8, 8.8); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(9, 9.9); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(10, 10.1); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(11, 11.11); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(12, 12.12); // Bela.data.buffers[idx], value (scalar, array, vector)
			gui.sendBuffer(13, 13.13); // Bela.data.buffers[idx], value (scalar, array, vector)
}



bool setup(BelaContext *context, void *userData)			
{
	gTimePeriod = 1.0 / GUI_FRAME_RATE; 
	gui.setup(context->projectName);
	return true;
}

void render(BelaContext *context, void *userData)
{	
	for(unsigned int n = 0; n < context->audioFrames; n++) {
		static unsigned int count = 0;
		if(count >= gTimePeriod*context->audioSampleRate) // send data every gTimePeriod seconds
		{
			count = 0;
			updateGui();
		}
		count++;
	}
}

void cleanup(BelaContext *context, void *userData) {}