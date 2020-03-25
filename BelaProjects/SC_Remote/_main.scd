/*******************
Remotely Control the Bela

Use this project to boot scsynth on the Bela.

This script simply starts scsynth, which then waits for messages.
Use the code in the other .scd files in this project to interact with the board
from the SuperCollider IDE running on the host.

IMPORTANT: you will need to add the class files for the Bela-specific UGens to your
computer in order to run these scripts.

(c) 2019 Jonathan Reus

*/

s = Server.default;

s.options.numAnalogInChannels = 8; // can be 2, 4 or 8
s.options.numAnalogOutChannels = 8; // can be 2, 4 or 8
s.options.numDigitalChannels = 2;
s.options.maxLogins = 8; // NOTE: does this actually do anything? - I get the following response in the client:
// belaServer: server process has maxLogins 8 - adjusting my options accordingly.


s.options.pgaGainLeft = 0;     // pregain for left / right audio inputs (+dB)
s.options.pgaGainRight = 0;    
s.options.headphoneLevel = 0; // headphone output (main stereo out) level (-dB)
s.options.speakerMuted = 1;    // 1=mute the speaker amp
s.options.dacLevel = 0;       // sets the gain of the analog outputs (+dB)
s.options.adcLevel = 0;       // sets the gain of the analog inputs (+dB)

s.options.blockSize = 128; // max blocksize possible on the Bela, good when doing analysis & MML stuff

// analog inputs 2-7 will still be available through the AnalogIn Ugen.
s.options.numInputBusChannels = 10; // Use all analog inputs as audio input channels
s.options.numOutputBusChannels = 2; // Use only the L/R audio output channels

s.options.memSize = 8192 * 32; // the default is 8192 which is quite little
s.boot;
