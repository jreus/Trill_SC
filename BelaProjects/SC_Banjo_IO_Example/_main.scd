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
s.options.numInputBusChannels = 10;
s.options.numOutputBusChannels = 2;

s.options.postln;

s.waitForBoot {

{
	var pos1, pos2, sig1, sig2;
	var mix, t_trig, alert;
	sig1 = AnalogIn.ar(0);
	sig2 = AnalogIn.ar(1);
	pos1 = AnalogIn.ar(4);
	pos2 = AnalogIn.ar(5);

	//pos1.poll;

/*
	mix = SinOsc.ar(SinOsc.ar(LFSaw.ar([3,12]).range(100, 300), add: 1).linexp(1.0, 2.0, 40, 12000)) * LFSaw.ar(10).range(0,1) * 0.2;
	mix = BLowPass4.ar(mix, LFSaw.ar(LFTri.ar(1).range(1, 9)).range(10000, 80), 0.3);
	mix = mix + Splay.ar(Impulse.ar(12).lag(0.3) * Resonz.ar(WhiteNoise.ar, [3000, 4000, 8000, 12000, 13000], 0.2), mul: 10);
	Limiter.ar(mix.tanh);
	*/
	//[sig1, sig2, pos1, pos2].poll;
	t_trig = sig1 > 0.01;
	mix = EnvGen.ar(Env.perc, gate: t_trig) * Saw.ar(WhiteNoise.ar.range(100,1000), mul: 0.2);
	sig1 = LeakDC.ar(sig1);
	pos1 = HPF.ar(pos1, 1000) * 100;
	//pos1 = pos1.lag(0.1);
	
	alert = EnvGen.ar(Env.perc, gate: (pos1 > 1.2)) * Saw.ar(WhiteNoise.ar.range(100,1000), mul: 0.2);
	
	mix = sig1 ;
	mix = LPF.ar(LPF.ar(mix, 3000), 3000) * 20;
	mix = mix;// + PitchShift.ar(mix, pitchRatio: 4);
	mix = mix * SinOsc.ar(620*(pos1+1.0), mul: 1);
	pos1.poll(1);
	Limiter.ar(mix!2); 	
}.play;


};
