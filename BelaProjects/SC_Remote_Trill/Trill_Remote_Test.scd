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

// Trill Raw patch
(
Ndef(\trill, {
  var i2c_bus = 1; // I2C bus to use on BeagleBone, usually you want this to be 1
  var i2c_address = 0x18; // I2C address of Trill sensor
  var thresh = 80; // noise threshold, int: 5-255
  var prescaler = 1; // sensitvity, int: 0-5 (0=highest sensitivity)
  var rawvals;
  var sig;

  rawvals = TrillRaw.kr(i2c_bus, i2c_address, thresh, prescaler);
  SendReply.kr(Impulse.kr(0.5), "/trilldata", rawvals);

  sig = SinOsc.ar((1..26) * 60, mul: Lag.kr(rawvals.linlin(200, 3000, 0.0, 1.0), 0.1)) * 1.0;
  sig = Splay.ar(sig);
  sig = CombL.ar(sig, 0.2, 0.2, 5.0) + sig;
  sig;
}).play(out: 0, numChannels: 2, group: s);

OSCdef(\trilldata, {|msg| msg[3..].postln}, "/trilldata");
);

// Trill Centroid patch
(
Ndef(\trill, {
  var i2c_bus = 1;
  var i2c_address = 0x18;
  var thresh = 60;
  var prescaler = 1;
  var touchsigs = DC.ar(0).dup(3);
  var centroids;
  var mix, out;

  centroids = TrillCentroids.kr(i2c_bus, i2c_address, thresh, prescaler);

  touchsigs[0] = Ringz.ar(Trig1.ar(centroids[2] > 0.0, 0.01), centroids[1].linexp(0.0, 1.0, 4000, 1000), 0.1, mul: 0.3).tanh * (centroids[2] > 0.0);
	touchsigs[1] = PMOsc.ar((centroids[3]+0.001) * 2500, 500, centroids[4].linexp(0.0, 3000, 0.1, 12.0), 0.1) * 0.2 * EnvGen.ar(Env.perc, (centroids[4] > 0.0), timeScale: 3.0);

  touchsigs[2] = Resonz.ar(
			Pluck.ar(PinkNoise.ar, (centroids[6] < 10), 0.2, centroids[5].linexp(0.0, 1.0, 80, 1000).reciprocal, 3, 0.5, mul: 6.0),
			centroids[5].linexp(0.0, 1.0, 800, 2400), 0.1, 4.0).tanh;


  out = Splay.ar(touchsigs);
  SendReply.kr(Impulse.kr(1.5), "/trilldata", centroids);
  Limiter.ar(out);
}).play(0, numChannels: 2, group: s);

OSCdef(\trilldata, {|msg| msg.postln}, "/trilldata");

);

