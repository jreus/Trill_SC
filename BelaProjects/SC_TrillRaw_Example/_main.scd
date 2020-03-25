/**
Functional example of using TrillRaw UGen.

(C) 2019 Jonathan Reus

**/
s = Server.default;

s.options.numAnalogInChannels = 8; // can be 2, 4 or 8
s.options.numAnalogOutChannels = 8; // can be 2, 4 or 8
s.options.numDigitalChannels = 16;
s.options.maxLogins = 8;

s.options.pgaGainLeft = 5;     // sets the pregain for the left audio input (dB)
s.options.pgaGainRight = 5;    // sets the pregain for the right audio input (dB)
s.options.headphoneLevel = -1; // sets the headphone level (-dB)
s.options.speakerMuted = 1;    // set true to mute the speaker amp and draw a little less power
s.options.dacLevel = 0;       // sets the gain of the analog dac to (dB)
s.options.adcLevel = 0;       // sets the gain of the analog adc to (dB)

s.options.blockSize = 16;
s.options.numInputBusChannels = 10;
s.options.numOutputBusChannels = 2;


s.waitForBoot {
	~tr = {|t_updateTrill = 1.0|
	var numTouchPads = 26;
	var i2c_bus = 1; // I2C bus to use on BeagleBone, usually you want this to be 1
	var i2c_address = 0x18; // I2C address of Trill sensor
	var noiseThresh = 40; // noise threshold, int: 5-255 (255=highest threshold)
	var prescalerOpt = 1; // sensitivity option, int: 0-4 (0=highest sensitivity, play with this for complex Trill Craft setups)
	var rawvals;
	var sig, ping;

	rawvals = TrillRaw.kr(i2c_bus, i2c_address, noiseThresh, prescalerOpt, t_updateTrill);
	SendReply.kr(Impulse.kr(0.5), "/trill", rawvals);
	sig = SinOsc.ar((1..numTouchPads) * 50, mul: Lag.kr(rawvals.linlin(0.0, 300, 0.0, 1.0), 0.1)) * 0.6;
	sig = Splay.ar(sig);
	sig = CombL.ar(sig.sum, 0.2, 0.2, 3.0, mul: 0.4) + sig;
	ping = EnvGen.ar(Env.perc, t_updateTrill) * SinOsc.ar(440);
	sig + ping;
	}.play;

	OSCdef(\trill, {|msg| msg[3..].postln }, "/trill");
	
	{ // Illustrates updating the baseline should the configuration change while the sketch is running
		loop {
			55.wait;
			"Reset Trill baseline in 10s...".postln;
			5.wait;
			"Baseline Reset".postln;
			~tr.set(\t_updateTrill, 1);
		};
	}.fork;
};
