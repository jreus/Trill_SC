/**
Simple Trill UGEN Tests when doing Remote control of Bela
**/

( // connect to the already-running remote belaserver
Server.default = s = Server("belaServer", NetAddr("192.168.7.2", 57110));
s.options.maxLogins = 8; // should match the settings on the Bela
s.initTree;
s.startAliveThread;
);

s.plotTree;
s.freeAll;


// Trill Raw Test
(
Ndef(\trill, {
  var i2c_bus = 1; // I2C bus to use on BeagleBone, usually you want this to be 1
  var i2c_address = 0x38; // I2C address of Trill Sensor
  var thresh = 40; // noise threshold, int: 5-255
  var prescaler = 0; // sensitvity, int: 0-5 (0=highest sensitivity)
  var rawvals, sig;
  rawvals = TrillRaw.kr(i2c_bus, i2c_address, thresh, prescaler);
  SendReply.kr(Impulse.kr(0.5), "/trillrawdata", rawvals);
  sig = SinOsc.ar((1..26) * 60, mul: Lag.kr(rawvals.linlin(200, 3000, 0.0, 1.0), 0.1)) * 1.0;
  sig = Splay.ar(sig);
  sig = CombL.ar(sig, 0.2, 0.2, 5.0) + sig;
  Out.ar(0, sig);
}).play(group: s);
);

OSCdef(\trillrawdata, {|msg| msg[3..].postln}, "/trillrawdata");

Ndef(\trill).clear;
OSCdef(\trillrawdata).clear;

// Trill Centroid patch
(
Ndef(\trill, {
  var i2c_bus = 1;
  var i2c_address = 0x38;
  var thresh = 60;
  var prescaler = 0;
  var touchsigs = DC.ar(0).dup(3);
  var centroids;
  var mix;

  centroids = TrillCentroids.kr(i2c_bus, i2c_address, thresh, prescaler);

  touchsigs[0] = Ringz.ar(Trig1.ar(centroids[2] > 0.0, 0.01), centroids[1].linexp(0.0, 1.0, 4000, 1000), 0.1, mul: 0.3).tanh * (centroids[2] > 0.0);
	touchsigs[1] = PMOsc.ar((centroids[3]+0.001) * 2500, 500, centroids[4].linexp(0.0, 3000, 0.1, 12.0), 0.1) * 0.2 * EnvGen.ar(Env.perc, (centroids[4] > 0.0), timeScale: 3.0);

  touchsigs[2] = Resonz.ar(
			Pluck.ar(PinkNoise.ar, (centroids[6] < 10), 0.2, centroids[5].linexp(0.0, 1.0, 80, 1000).reciprocal, 3, 0.5, mul: 6.0),
			centroids[5].linexp(0.0, 1.0, 800, 2400), 0.1, 4.0).tanh;

  SendReply.kr(Impulse.kr(0.5), "/trillcentroiddata", centroids);

  mix = Splay.ar(touchsigs);
	Out.ar(0, Limiter.ar(mix));
}).play(group: s);
);


OSCdef(\trillcentroiddata, {|msg| msg.postln}, "/trillcentroiddata");

OSCdef(\trillcentroiddata).clear;
Ndef(\trill).clear;
