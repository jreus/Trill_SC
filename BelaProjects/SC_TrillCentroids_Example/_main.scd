/**
Functional example of using TrillCentroids UGen

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
s.options.dacLevel = 0;       // sets the gain of the stereo audio dac (+dB)
s.options.adcLevel = 0;       // sets the gain of the stereo audio adc (+dB)

s.options.blockSize = 16;
s.options.numInputBusChannels = 10;
s.options.numOutputBusChannels = 2;


s.waitForBoot {
	SynthDef(\sketch, {|t_recalibrate=0.0|
		var i2c_bus = 1;
		var i2c_address = 0x18;
		var noiseThreshold = 30; // int: 5-255 with 255 being the highest noise thresh
		var prescalerOpt = 1; // int: 0-4 with 0 being the highest sensitivity
		var touchsigs = DC.ar(0).dup(3); // use 3 touches
		var centroids;
		var out, ping;

		// returns an array with format: [num_active_touches, t1_pos, t1_size, t2_pos, t2_size, t3_pos, t3_size, t4_pos, t4_size, t5_pos, t5_size]
		centroids = TrillCentroids.kr(i2c_bus, i2c_address, noiseThreshold, prescalerOpt, t_recalibrate);
		

		// touch1 is a percussive pluck
		touchsigs[0] = Pluck.ar(WhiteNoise.ar, (centroids[2] > 0), 0.2, centroids[1].linexp(0.0, 1.0, 70, 300).reciprocal, 5, 0.9);
		
		// touch2 is a bendy PM synth
		touchsigs[1] = PMOsc.ar((centroids[3]+0.001) * 2500, 500, centroids[4].linexp(0.0, 2000, 0.1, 12.0), 0.1, mul: 0.5) 
			* EnvGen.ar(Env.perc, (centroids[4] > 0.0), timeScale: centroids[4].linexp(50, 500, 0.3, 5.0));

		// touch3 another percussive plucky sound with pull-off behavior
		touchsigs[2] = Resonz.ar(
			Pluck.ar(PinkNoise.ar, (centroids[6] < 10), 0.2, centroids[5].linexp(0.0, 1.0, 80, 1000).reciprocal, 3, 0.5, mul: 6.0), 
			centroids[5].linexp(0.0, 1.0, 800, 2400), 0.1, 4.0).tanh;
		
		
		out = Splay.ar(touchsigs);
		SendReply.kr(Impulse.kr(1), "/trill", centroids);
		ping = EnvGen.ar(Env.perc, t_recalibrate) * SinOsc.ar(440); // make a ping every time the baseline is reset
		Out.ar(0, out + ping);
	}).add;
	
	s.sync;
	~tr = Synth(\sketch);
	OSCdef(\trill, {|msg| msg[3..].postln }, "/trill");
	
	// Illustrates how to recalibrate the Trill sensor's baseline value if the touchpad configuration changes
	{
		loop {
			55.wait;
			"Reset baseline in 5s...".postln;
			5.wait;
			"Baseline reset!".postln;
			~tr.set(\t_recalibrate, 1);
		};
	}.fork;

};
