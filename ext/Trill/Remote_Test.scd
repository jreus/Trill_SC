/**
Remote control of Bela
**/

( // connect to the already-running remote belaserver
Server.default = s = Server("belaServer", NetAddr("192.168.7.2", 57110));
s.options.maxLogins = 6; // should match the settings on the Bela
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
  var thresh = 6; // noise threshold, int: 0-6 (6=highest threshold)
  var prescaler = 0; // sensitvity, int: 0-5 (0=highest sensitivity)
  var rawvals;
  var sig;

  rawvals = TrillRaw.kr(i2c_bus, i2c_address, thresh, prescaler);
  SendReply.kr(Impulse.kr(0.5), "/trill", rawvals);

  sig = Saw.ar(rawvals.linlin(200, 3000, 100, 2000), mul: Lag.kr(rawvals.linlin(200, 3000, 0.0, 1.0), 0.1)) * 0.1;
  sig = CombL.ar(sig, 0.2, 0.2, 1.0) + sig;
  Splay.ar(sig.tanh);
}).play(out: 0, numChannels: 2, group: s);
);

// Trill Centroid patch
(

Ndef(\trill, {
  var i2c_bus = 1;
  var i2c_address = 0x18;
  var thresh = 6;
  var prescaler = 0;
  var touchsigs = DC.ar(0).dup(5);
  var centroids;
  var mix, out;

  centroids = TrillCentroids.kr(i2c_bus, i2c_address, thresh, prescaler);


  /*
  // slap tappy
  touchsigs[0] = Resonz.ar(Pluck.ar(PinkNoise.ar, (centroids[2] > 0), 0.2, centroids[1].linexp(0.0, 1.0, 800, 2400).reciprocal, 20, 0.5, mul: 6.0), centroids[1].linexp(0.0, 1.0, 800, 2400), 0.1, 4.0).tanh;
  touchsigs[1] = Pluck.ar(WhiteNoise.ar, (centroids[4] > 0), 0.2, centroids[3].linexp(0.0, 1.0, 70, 300).reciprocal, 5, 0.9);
  touchsigs[2] = EnvGen.ar(Env.perc(0.001, 0.2), (centroids[6] > 0.0)) * SinOsc.ar([40, 45, 60, 61, 100], mul: 1.0).sum;
  touchsigs[3] = Pluck.ar(WhiteNoise.ar, (centroids[8] > 0), 0.2, centroids[7].linexp(0.0, 1.0, 50, 400).reciprocal, 1.0, 0.8);
  touchsigs[4] = Pluck.ar(WhiteNoise.ar, (centroids[10] > 0), 0.2, centroids[9].linexp(0.0, 1.0, 1000, 2000).reciprocal, 0.5, 0.5);
  out = Splay.ar(touchsigs);
  */



  // synthy
  touchsigs[0] = Ringz.ar(Trig1.ar(centroids[2] > 0.0, 0.01), centroids[1].linexp(0.0, 1.0, 4000, 1000), 0.1, mul: 0.3).tanh * (centroids[2] > 0.0);
  touchsigs[1] = PMOsc.ar((centroids[3]+0.001) * 2500, 500, centroids[4].linexp(0.0, 3000, 0.1, 12.0), 0.1) * 0.2 * EnvGen.ar(Env.perc, (centroids[4] > 0.0), timeScale: centroids[4].linexp(500, 3000, 0.3, 5.0));

  mix = Mix([touchsigs[0], touchsigs[1]]);
  out = GVerb.ar(mix, 20, centroids[5].linlin(0.0, 1.0, 2,5),  mul: (centroids[6] > 0) * 0.5) + mix;


  SendReply.kr(Impulse.kr(1.5), "/trill", centroids);
  Limiter.ar(out);
}).play(0, numChannels: 2, group: s);

OSCdef(\trilldata, {|msg| msg[3..].postln}, "/trill");

);


