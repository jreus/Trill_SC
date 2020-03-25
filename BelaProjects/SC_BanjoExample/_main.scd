/**
July 19, 2019 jreus
First tests with Bela mini, pre-amps/pickups and banjo

Analog 0/1 are the integrator pre-amps

Analog 4/5 are the audio pre-amps
*/

s = Server.default;

s.options.numAnalogInChannels = 8;
s.options.numAnalogOutChannels = 8;
s.options.numDigitalChannels = 16;

s.options.blockSize = 16;
s.options.numInputBusChannels = 10; // all 10 analog inputs as audio
s.options.numOutputBusChannels = 2;

s.options.postln;

s.waitForBoot {

{
	var mix;

	var s1, s2, s3, s4, s5;
	var mag1, mag2;
	var trill;
	
	// Filter out high frequency noise from the Bela's analog inputs
	// strings 1 3 and 5 are mixed down to one input, strings 2 & 5 mixed down to another
	s1 = s3 = s5 = LPF.ar(LPF.ar(In.ar(2), 3000), 3000) * 3.0;
	s2 = s4 = LPF.ar(LPF.ar(In.ar(3), 3000), 3000) * 3.0;
	
	trill = TrillCentroids.kr();

	//[sig1, sig2, pos1, pos2].poll;


	//mix = sig1 ;
	//mix = LPF.ar(LPF.ar(mix, 3000), 3000) * 20;
	//mix = mix;// + PitchShift.ar(mix, pitchRatio: 4);
	//mix = mix * SinOsc.ar(620*(pos1+1.0), mul: 1);
	//pos1.poll(1);
	mix = LeakDC.ar([s1,s2,s3,s4,s5]);
	mix = Splay.ar(mix);
	Limiter.ar(mix); 	
}.play;


};
