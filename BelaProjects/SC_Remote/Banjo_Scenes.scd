/*****
Live coding the banjo

*****/

( // connect to the already-running remote belaserver
Server.default = s = Server("belaServer", NetAddr("192.168.7.2", 57110));
s.options.maxLogins = 8; // should match the settings on the Bela
s.initTree;
s.startAliveThread;

// fill ~sf with a graph of available sample files
~readSounds = {
  ~spath = "/root/banjer/samples/";
  ~sf = Dictionary.new;
  PathName("../../samples".resolveRelative).filesDo {|path|
    var category, label = path.folderName;
    category = ~sf[label];
    if(category.isNil) {
      category = Dictionary.new;
      ~sf.put(label, category);
    };
    category.put(path.fileNameWithoutExtension, path);
  };
};

// trill touchpad ranges
~ranges = Dictionary.with(*[\bottom->[0.4, 0.44], \top->[0.48, 0.56], \necktop->[0.0, 0.36], \neckbottom->[0.88, 1.0], \slide->[0.6, 0.84]]);
);

s.plotTree;
s.freeAll;

Platform.systemExtensionDir;
Platform.userExtensionDir;


/*-------------------------------------------
█▄▄▄▄ ▄███▄   ▄█▄    ████▄ █▄▄▄▄ ██▄
█  ▄▀ █▀   ▀  █▀ ▀▄  █   █ █  ▄▀ █  █
█▀▀▌  ██▄▄    █   ▀  █   █ █▀▀▌  █   █
█  █  █▄   ▄▀ █▄  ▄▀ ▀████ █  █  █  █
  █   ▀███▀   ▀███▀          █   ███▀
 ▀                          ▀
*/
b = Buffer.alloc(s, s.sampleRate * 30.0, 2); // 30 seconds of audio, 2 channels
// write to file (warning, may disconnect from the Bela due to the file write taking up all the system resources!)
b.write("/root/banjer/data/" +/+ Date.getDate.stamp ++ "_snip.wav", "WAV", "float");


/*
 ▄            ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄        ▄▄       ▄▄  ▄▄▄▄▄▄▄▄▄▄▄
▐░▌          ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░▌      ▐░░▌     ▐░░▌▐░░░░░░░░░░░▌
▐░▌          ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌     ▐░▌░▌   ▐░▐░▌▐░█▀▀▀▀▀▀▀▀▀
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌▐░▌ ▐░▌▐░▌▐░▌
▐░▌          ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌     ▐░▌ ▐░▐░▌ ▐░▌▐░█▄▄▄▄▄▄▄▄▄
▐░▌          ▐░▌       ▐░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌     ▐░▌  ▐░▌  ▐░▌▐░░░░░░░░░░░▌
▐░▌          ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀█░▌▐░▌       ▐░▌     ▐░▌   ▀   ▐░▌▐░█▀▀▀▀▀▀▀▀▀
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌       ▐░▌     ▐░▌       ▐░▌▐░▌
▐░█▄▄▄▄▄▄▄▄▄ ▐░█▄▄▄▄▄▄▄█░▌▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄█░▌     ▐░▌       ▐░▌▐░█▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░▌      ▐░▌       ▐░▌▐░░░░░░░░░░░▌
 ▀▀▀▀▀▀▀▀▀▀▀  ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀▀▀▀▀▀▀▀▀▀        ▀         ▀  ▀▀▀▀▀▀▀▀▀▀▀

*/
(
Ndef.clear;
~jo.free;
~readSounds.();
if(~bufs.notNil) { ~bufs.keysValuesDo {|key,val| val.free } };
~bufs = Dictionary.new;
[
  ~sf["voice"]["Ahhhs"], ~sf["voice"]["Moonshiner"], ~sf["percussive"]["Chinga_002"], ~sf["percussive"]["JapaDrum1_13"],
  ~sf["voice"]["Hallelujah_Amazing_Grace_001"], ~sf["voice"]["Ahhhs_mono"], ~sf["percussive"]["Chinga_0122"],
].do {|it,idx| ~bufs[it.fileNameWithoutExtension] = ~spath +/+ it.folderName +/+ it.fileName };

~offsets = Dictionary.with(*[å
  "Moonshiner_verses" -> [1.503, 13.726, 25.414, 37.428, 48.943, 60.96, 71.9, 83.89, 96.23, 108.4],
]);

// slowly now.. take it easy now...
{
  ~bufs.keysValuesDo {|key, val, idx|
    var buf = Buffer.read(s, val);
    "Loading %".format(val).postln;
    ~bufs.put(key, buf);
  };
  "Done...".postln;
}.fork;

);
~bufs;
~bufs.keys;

/*
.----------------------------.
|\  /\  /\  /\  /\  /\  /\  /|
| )(  )(  )(  )(  )(  )(  )( |
|(  )(  )(  )(  )(  )(  )(  )|
███╗   ███╗ █████╗  ██████╗  ██████╗ ██╗███████╗     ██████╗ ███╗   ██╗    ████████╗██╗  ██╗███████╗
████╗ ████║██╔══██╗██╔════╝ ██╔════╝ ██║██╔════╝    ██╔═══██╗████╗  ██║    ╚══██╔══╝██║  ██║██╔════╝
██╔████╔██║███████║██║  ███╗██║  ███╗██║█████╗      ██║   ██║██╔██╗ ██║       ██║   ███████║█████╗
██║╚██╔╝██║██╔══██║██║   ██║██║   ██║██║██╔══╝      ██║   ██║██║╚██╗██║       ██║   ██╔══██║██╔══╝
██║ ╚═╝ ██║██║  ██║╚██████╔╝╚██████╔╝██║███████╗    ╚██████╔╝██║ ╚████║       ██║   ██║  ██║███████╗
╚═╝     ╚═╝╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝╚══════╝     ╚═════╝ ╚═╝  ╚═══╝       ╚═╝   ╚═╝  ╚═╝╚══════╝
██████╗ ██╗   ██╗███████╗
██╔══██╗██║   ██║██╔════╝
██████╔╝██║   ██║███████╗
██╔══██╗██║   ██║╚════██║
██████╔╝╚██████╔╝███████║
╚═════╝  ╚═════╝ ╚══════╝
╚═════╝  ╚═════╝ ╚══════╝    ╚══════╝╚═╝╚═╝  ╚═══╝╚══════╝
    ___    ___     ___     ___     _       ___   __  __    ___
   | _ \  | _ \   / _ \   | _ )   | |     | __| |  \/  |  / __|
   |  _/  |   /  | (_) |  | _ \   | |__   | _|  | |\/| |  \__ \
  _|_|_   |_|_\   \___/   |___/   |____|  |___| |_|__|_|  |___/
_| """ |_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|
"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'

    ___    ___     ___     ___     _       ___   __  __    ___
   | _ \  | _ \   / _ \   | _ )   | |     | __| |  \/  |  / __|
   |  _/  |   /  | (_) |  | _ \   | |__   | _|  | |\/| |  \__ \
  _|_|_   |_|_\   \___/   |___/   |____|  |___| |_|__|_|  |___/
_| """ |_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|
"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'

    ___    ___     ___     ___     _       ___   __  __    ___
   | _ \  | _ \   / _ \   | _ )   | |     | __| |  \/  |  / __|
   |  _/  |   /  | (_) |  | _ \   | |__   | _|  | |\/| |  \__ \
  _|_|_   |_|_\   \___/   |___/   |____|  |___| |_|__|_|  |___/
_| """ |_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|
"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'

F modal >> g C Bb C Eb*/
[~bufs["Chinga_002"], ~bufs["JapaDrum1_13"]];

(
~jo.free;
~jo = {
  var mix, verbmix, insig, s5, strings, stringsmix, thumbsig, slidesig, mag1, mag2, mic;
  var buf1, buf2, buf3, b1frames, b2frames, b3frames, smpl1, smpl2, spos1, spos2, spos3, b3dur, pos3var, graintrig;
  var t_mag1, t_mag2, magmap1, magmap2, mt1, mt2, seq1, seq2;
  var centroids, t_bottom, t_top, t_necktop, t_slide, mode = 0, t1, t2, t3;

  var nastynoise_hz = 230, noise_co_hz = 7000; // magic numbers
  mic = In.ar(2, 1) * 2.0;
  mag1 = In.ar(6,1);
  mag2 = In.ar(7,1);

  // STRINGS INPUT
	s5 = In.ar(4,1);
	strings = In.ar(5,1);
	s5 = SVF.ar(s5, nastynoise_hz*1, 0.01 ,0,0,0,1,0);
	strings = SVF.ar(strings, nastynoise_hz*1, 0.01 ,0,0,0,1,0);

	// pull out the good signal, get rid of digital noise
	s5 = Compander.ar(s5, s5, 0.02, 4.0, 1.0, 0.05, 0.01, mul: 15.0);
	strings = Compander.ar(strings, strings, 0.02, 2.5, 1.0, 0.01, 0.01, mul: 80.0);


  // TRILL INPUT
  centroids = TrillCentroids.kr(1, 0x18, 60, 1);

  // MODE TOGGLE: 0.4-0.44 bottom segment bounds
  t_bottom = (centroids[1] >= ~ranges[\bottom][0]) * (centroids[1] <= ~ranges[\bottom][1]);
  mode = Stepper.kr(t_bottom,0,0,1);
  //t_bottom.poll(1);

  // THUMB TAPS ON NECK TOPSIDE
  // for the 0.0 segment you need an extra test that there is indeed a touch recognized, because all touches default to 0!
  t_necktop = (centroids[2] > 10) * (centroids[1] >= ~ranges[\necktop][0]) * (centroids[1] <= ~ranges[\necktop][1]);
  t2 = [Gate.kr(centroids[1], t_necktop), centroids[2]];// pos, size
  thumbsig = Resonz.ar(Pluck.ar(PinkNoise.ar, Changed.kr(t_necktop), 0.2, t2[0].linexp(0.0, 0.36, 50, 1000).reciprocal, 15.8, 0.8, mul: 6.0), [60, 300,2200], 0.1, 10.0).sum.clip; // mode0

  // SAMPLE DRAG ON AND PULL ON THE SLIDE SENSOR
  buf3 = ~bufs["Chinga_0122"];
  b3frames = BufFrames.kr(buf3);
  t_slide = (centroids[2] > 10) * (centroids[1] >= ~ranges[\slide][0]) * (centroids[1] <= ~ranges[\slide][1]);
  t3 = Gate.kr([centroids[1], centroids[2]], t_slide); // pos, size
  spos3 = t3[0].linlin(~ranges[\slide][0], ~ranges[\slide][1], 0, BufFrames.kr(buf3));
  spos3 = Lag.ar(K2A.ar(spos3), 4.0);
  slidesig = BufRd.ar(1, buf3, spos3, 0.0);
  //slidesig = AllpassC.ar(slidesig, 0.5, 0.3, 2.0) + slidesig;


  // mag signals
  // Start your code here
  mag1 = Lag2.ar(mag1, 0.1);
  mag1 = mag1.linlin(-0.002, 0.002, -1.0, 1.0);

  mag2 = Lag2.ar(mag2, 0.1);
  mag2 = mag2.linlin(-0.002, 0.002, -1.0, 1.0);

  buf1 = ~bufs["Chinga_002"];
  buf2 = ~bufs["JapaDrum1_13"];
  b1frames = BufFrames.kr(buf1);
  b2frames = BufFrames.kr(buf2);


  // magsense trigger thresholds
  mt1 = 0.4;
  mt2 = 0.4;
  t_mag1 = Trig1.kr(mag1.abs > mt1, 0.1);
  t_mag2 = Trig1.kr(mag2.abs > mt2, 0.1);
  magmap1 = mag1.abs.explin(mt1, 1, 0.2, 0.05); // map to sample playback speed on approach
  magmap2 = mag2.abs.explin(mt2, 1, 0.2, 0.05);

  seq1 = (1..10) / 10.0; // drum pitches
  seq1 = Select.kr(Stepper.kr(t_mag1, 0, 0, 10), seq1);
  // chinga
  spos1 = EnvGen.ar(Env.new([0, 0, 1], [magmap1, seq1], \lin), t_mag1, b1frames, 0, BufDur.kr(buf1));

  // japanese drum
  spos2 = EnvGen.ar(Env.new([0, 0, 1], [magmap2, 1.0], \lin), t_mag2, b2frames, 0, BufDur.kr(buf2));
  //mag1.poll(4);

  smpl1 = BufRd.ar(1, buf1, spos1, 0.0, 2);
  smpl2 = BufRd.ar(1, buf2, spos2, 0.0, 2);

	// *STRING SIGNAL POST PRODUCTION* output processing
	strings = Compander.ar(strings, strings, 0.2, 1.3, 0.3, 0.1, 0.1, mul: 5.0);
	//s5 = s5 + AllpassC.ar(s5, 0.2, 0.01, 3.0);
	//stringsmix = AllpassC.ar(s5+strings, 0.2, 0.01, 1.0) + strings + s5;
	//stringsmix = BPeakEQ.ar(stringsmix, 1200, 0.3, 6);
	stringsmix = (s5 * 1.0) + (strings * 1.0);
	stringsmix = FreeVerb.ar(stringsmix, 0.2, 0.5, 0.5);
	verbmix = thumbsig + slidesig + smpl1 + smpl2;
	verbmix = GVerb.ar(verbmix, 65, 3, 0.2, 0.2, 5, 1.0, 1.0, 0.4) * 2.0;

	mix = (stringsmix * 1.0) + (verbmix * 0.5);
	mix = Limiter.ar(LeakDC.ar(mix * 1.0), 1.0, 0.001);
	mix;
}.play(s, outbus: 0);

);

~jo.free;

 \  /  \  /  /  \  /  /  \  \  /  /  \  /  \  /
\ \/ /\ \/ // /\ \/ // /\ \\ \/ // /\ \/ /\ \/ /
 \  /  \  /  /  \  /  /  \  \  /  /  \  /  \  /
 \  /  \  /  /  /  \  /  /  \  /  \  /  \  /  /
\ \/ /\ \/ // // /\ \/ // /\ \/ /\ \/ /\ \/ // /
 \  /  \  /  /  /  \  /  /  \  /  \  /  \  /  /
 /  \  /  \  /  \  /  \  /  /  \  /  /  \  /  \
/ /\ \/ /\ \/ /\ \/ /\ \/ // /\ \/ // /\ \/ /\ \
 /  \  /  \  /  \  /  \  /  /  \  /  /  \  /  \
 \  /  /  /  /  \  /  /  /  \  /  /  \  /  \  \
\ \/ // // // /\ \/ // // /\ \/ // /\ \/ /\ \\ \
   ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄▄  ▄         ▄  ▄▄▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░░░░░░░░░░░▌
▐░█▀▀▀▀▀▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀ ▐░▌       ▐░▌▐░█▀▀▀▀▀▀▀█░▌
▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌▐░▌          ▐░▌       ▐░▌▐░▌       ▐░▌
▐░▌          ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌▐░▌          ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄█░▌
▐░▌          ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌▐░▌          ▐░░░░░░░░░░░▌▐░░░░░░░░░░░▌
▐░▌          ▐░█▀▀▀▀█░█▀▀ ▐░█▀▀▀▀▀▀▀▀▀ ▐░▌          ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀
▐░▌          ▐░▌     ▐░▌  ▐░▌          ▐░▌          ▐░▌       ▐░▌▐░▌
▐░█▄▄▄▄▄▄▄▄▄ ▐░▌      ▐░▌ ▐░▌          ▐░█▄▄▄▄▄▄▄▄▄ ▐░▌       ▐░▌▐░▌
▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░▌          ▐░░░░░░░░░░░▌▐░▌       ▐░▌▐░▌
 ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀            ▀▀▀▀▀▀▀▀▀▀▀  ▀         ▀  ▀

 \  /  /  /  /  \  /  /  /  \  /  /  \  /  \  \
 /  \  /  \  /  /  \  /  /  \  /  \  \  \  /  \
/ /\ \/ /\ \/ // /\ \/ // /\ \/ /\ \\ \\ \/ /\ \
 /  \  /  \  /  /  \  /  /  \  /  \  \  \  /
/* Amaj >> G E A Cs E */

( //******* WEAVE 2 > CRIPPLE CHIP Amaj ***************//
~jo.free;
~jo = {
  var magMax = 0.001, magMin = -0.001, magSmooth = 0.2; // magic numbers
  var stringmix, synthmix, mix, insig, s5, strings, mag1, mag2, mic;
  var s_amp, s_pitch1, s_pitch2, s_haspitch, beat1 = 8, beat2 = 8;
  var mapped1, mapped2;
  var nastynoise_hz = 230, noise_co_hz = 7000; // magic numbers
  var mode = 0, sequence = 0;
  var centroids, t_neckbottom, t_top, t_necktop;
  var chain1, chain2, onsets1, onsets2, pitches1, pitches2, seq1, seq2, dur1, dur2;

  //mic = In.ar(2, 1);
  mag1 = In.ar(7,1);
  mag2 = In.ar(8,1);

	  // STRINGS INPUT
	s5 = In.ar(4,1);
	strings = In.ar(5,1);
	s5 = SVF.ar(s5, nastynoise_hz*1, 0.01 ,0,0,0,1,0);
	strings = SVF.ar(strings, nastynoise_hz*1, 0.01 ,0,0,0,1,0);

	// pull out the good signal, get rid of digital noise
	s5 = Compander.ar(s5, s5, 0.02, 4.0, 1.0, 0.05, 0.01, mul: 15.0);
	strings = Compander.ar(strings, strings, 0.02, 2.5, 1.0, 0.01, 0.01, mul: 80.0);



  // trill sensor
  centroids = TrillCentroids.kr(1, 0x18, 40, 1);

  // MODE TOGGLE: neckbottom toggles echo/delay
  t_neckbottom = (centroids[1] >= ~ranges[\neckbottom][0]) * (centroids[1] <= ~ranges[\neckbottom][1]);
  mode = Stepper.kr(t_neckbottom,0,0,1);
  //t_bottom.poll(2);
  //mode.poll(1);

  // SEQUENCE TOGGLE: necktop toggles pitch range
  t_necktop = (centroids[2] > 10) * (centroids[1] >= ~ranges[\necktop][0]) * (centroids[1] <= ~ranges[\necktop][1]);
  sequence = Stepper.kr(t_necktop,0,0,3);
  //t_necktop.poll(2);
  //sequence.poll(1);

  // string onset detection
  chain1 = FFT(LocalBuf(512), s5, 0.5, 1); // drone
  chain2 = FFT(LocalBuf(512), strings, 0.5, 1); // other strings
  onsets1 = Onsets.kr(chain1, 0.5, \power); // try different algorithms for CPU
  onsets2 = Onsets.kr(chain2, 0.5, \power); // try different algorithms for CPU


  // Drone string sequence
  pitches1 = Select.kr(sequence, [
    [[\a4.f, \e5.f], [\gs4.f, \d4.f], [\fs3.f, \a4.f]],
    [[\cs4.f, \fs4.f], [\e3.f, \b4.f], [\d3.f, \a3.f]],
    [[\cs4.f, \fs4.f], [\e3.f, \b4.f], [\d3.f, \a3.f]] / 2.0,
  ]);
  seq1 = Select.kr(Stepper.kr(onsets1, 0, 0, 2), pitches1);
  dur1 = Select.kr(mode, [0.6, 0.2, 0.2]);
  seq1 = Pulse.ar(seq1, mul: 1.0).sum * 0.6 * EnvGen.ar(Env.perc(0.01, dur1), onsets1);
  seq1 = Select.ar(mode, [
    AllpassC.ar(seq1, 0.2, 0.2, 2.0),  // 0
    seq1,                               // 1
  ]);

  // 4-strings sequence
  pitches2 = Select.kr(sequence, [
    [[\e5.f, \cs4.f], [\a3.f, \cs4.f], [\e4.f, \gs5.f], [\gs3.f, \b4.f]] * 4,       //0
    [[\e5.f, \cs4.f], [\a3.f, \cs4.f], [\e4.f, \gs5.f], [\gs3.f, \b4.f]] * 2,   //1
    [[\e5.f, \cs4.f], [\a3.f, \cs4.f], [\e4.f, \gs5.f], [\gs3.f, \b4.f]] * 5.5,   //2
    [[\e5.f, \cs4.f, \d3.f], [\a3.f, \cs4.f], [\a4.f, \cs2.f], [\e4.f, \gs5.f], [\gs3.f, \b4.f]],   //2
  ]);
  seq2 = Select.kr(Stepper.kr(onsets2, 0, 0, 3), pitches2);
  seq2 = Pulse.ar(seq2, mul: 1.0).sum * 0.5 * EnvGen.ar(Env.perc(0.01, dur1), onsets2);
  seq2 = Select.ar(mode, [
    AllpassC.ar(seq2, 0.1, 0.1, 1.0) + seq2,
    seq2,
  ]);

	stringmix = (s5 * 1.0) + (strings * 1.0);
	synthmix = (seq1 * 1.0) + (seq2 * 1.0);
  mix = synthmix + GVerb.ar(stringmix, 15, 1, 0.2, 0.2, 5, 1.0, 0.5, 0.1);
  mix = Limiter.ar(LeakDC.ar(mix * 1.0), 1.0, 0.001);
  //RecordBuf.ar(mix, b, loop: 0); // record first 10 seconds of audio
  mix;
}.play(s, outbus: 0);
);
~jo.free;






/*

                                               .__    .__
███╗   ███╗ ██████╗  ██████╗ ███╗   ██╗███████╗██╗  ██╗██╗███╗   ██╗███████╗██████╗
████╗ ████║██╔═████╗██╔═████╗████╗  ██║██╔════╝██║  ██║██║████╗  ██║██╔════╝██╔══██╗
██╔████╔██║██║██╔██║██║██╔██║██╔██╗ ██║███████╗███████║██║██╔██╗ ██║█████╗  ██████╔╝
██║╚██╔╝██║████╔╝██║████╔╝██║██║╚██╗██║╚════██║██╔══██║██║██║╚██╗██║██╔══╝  ██╔══██╗
██║ ╚═╝ ██║╚██████╔╝╚██████╔╝██║ ╚████║███████║██║  ██║██║██║ ╚████║███████╗██║  ██║
╚═╝     ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝
  __                        __                                __
.-----.--.--.-----.----.    .-----.|__|.-----.----.-----.    |__|    .--.--.--.---.-.-----.    |  |--.-----.----.-----.
|  -__|  |  |  -__|   _|    |__ --||  ||     |  __|  -__|    |  |    |  |  |  |  _  |__ --|    |  _  |  _  |   _|     |
|_____|\___/|_____|__|      |_____||__||__|__|____|_____|    |__|    |________|___._|_____|    |_____|_____|__| |__|__|
  __                        __                                __
.-----.--.--.-----.----.    .-----.|__|.-----.----.-----.    |__|    .--.--.--.---.-.-----.    |  |--.-----.----.-----.
|  -__|  |  |  -__|   _|    |__ --||  ||     |  __|  -__|    |  |    |  |  |  |  _  |__ --|    |  _  |  _  |   _|     |
|_____|\___/|_____|__|      |_____||__||__|__|____|_____|    |__|    |________|___._|_____|    |_____|_____|__| |__|__|
  __                        __                                __
.-----.--.--.-----.----.    .-----.|__|.-----.----.-----.    |__|    .--.--.--.---.-.-----.    |  |--.-----.----.-----.
|  -__|  |  |  -__|   _|    |__ --||  ||     |  __|  -__|    |  |    |  |  |  |  _  |__ --|    |  _  |  _  |   _|     |
|_____|\___/|_____|__|      |_____||__||__|__|____|_____|    |__|    |________|___._|_____|    |_____|_____|__| |__|__|
  __                        __                                __
.-----.--.--.-----.----.    .-----.|__|.-----.----.-----.    |__|    .--.--.--.---.-.-----.    |  |--.-----.----.-----.
|  -__|  |  |  -__|   _|    |__ --||  ||     |  __|  -__|    |  |    |  |  |  |  _  |__ --|    |  _  |  _  |   _|     |
|_____|\___/|_____|__|      |_____||__||__|__|____|_____|    |__|    |________|___._|_____|    |_____|_____|__| |__|__|
  __                        __                                __
.-----.--.--.-----.----.    .-----.|__|.-----.----.-----.    |__|    .--.--.--.---.-.-----.    |  |--.-----.----.-----.
|  -__|  |  |  -__|   _|    |__ --||  ||     |  __|  -__|    |  |    |  |  |  |  _  |__ --|    |  _  |  _  |   _|     |
|_____|\___/|_____|__|      |_____||__||__|__|____|_____|    |__|    |________|___._|_____|    |_____|_____|__| |__|__|
  __                        __                                __
.-----.--.--.-----.----.    .-----.|__|.-----.----.-----.    |__|    .--.--.--.---.-.-----.    |  |--.-----.----.-----.
|  -__|  |  |  -__|   _|    |__ --||  ||     |  __|  -__|    |  |    |  |  |  |  _  |__ --|    |  _  |  _  |   _|     |
|_____|\___/|_____|__|      |_____||__||__|__|____|_____|    |__|    |________|___._|_____|    |_____|_____|__| |__|__|
  __                        __                                __
.-----.--.--.-----.----.    .-----.|__|.-----.----.-----.    |__|    .--.--.--.---.-.-----.    |  |--.-----.----.-----.
|  -__|  |  |  -__|   _|    |__ --||  ||     |  __|  -__|    |  |    |  |  |  |  _  |__ --|    |  _  |  _  |   _|     |
|_____|\___/|_____|__|      |_____||__||__|__|____|_____|    |__|    |________|___._|_____|    |_____|_____|__| |__|__|
  __                        __                                __
.-----.--.--.-----.----.    .-----.|__|.-----.----.-----.    |__|    .--.--.--.---.-.-----.    |  |--.-----.----.-----.
|  -__|  |  |  -__|   _|    |__ --||  ||     |  __|  -__|    |  |    |  |  |  |  _  |__ --|    |  _  |  _  |   _|     |
|_____|\___/|_____|__|      |_____||__||__|__|____|_____|    |__|    |________|___._|_____|    |_____|_____|__| |__|__|

C modal >> G F Bb C Eb */
~bufs["Moonshiner"];

( // MOONSHINER
~jo.free;
~jo = {
  var magMax = 0.001, magMin = -0.001, magSmooth = 0.2; // magic numbers
  var mix, stringmix, synthmix, insig, slidesig, strings, s5, stringsmix, mag1, mag2, mic;
  var s_amp, s_pitch1, s_pitch2, s_haspitch, beat1 = 8, beat2 = 8;
  var mapped1, mapped2;
  var nastynoise_hz = 230, noise_co_hz = 7000; // magic numbers
  var centroids, mode=0, buf_select=0, t_bufchange, t_neckbottom, t_top, t_necktop, t_slide, t1, t2, t3;

  var chain1, chain2, onsets1, onsets2;
  var b1offsets, b2offsets, noffsets1, noffsets2;
  var seq1, seq2;
  var buf1, buf2, buf3, bpos1, bpos2, boffset1, boffset2, b1frames, b2frames, b3frames, b1dur, b2dur, b3dur;
  var t_grain, gpos_var, gpos, gdur, gdur_var;

  buf1 = ~bufs["Ahhhs"];
  buf2 = ~bufs["Moonshiner"];

  // Mag sensor inputs
  mag1 = In.ar(7,1);
  mag2 = In.ar(8,1);

  // Audio inputs
	  // STRINGS INPUT
	s5 = In.ar(4,1);
	strings = In.ar(5,1);
	s5 = SVF.ar(s5, nastynoise_hz*1, 0.01 ,0,0,0,1,0);
	strings = SVF.ar(strings, nastynoise_hz*1, 0.01 ,0,0,0,1,0);

	// pull out the good signal, get rid of digital noise
	s5 = Compander.ar(s5, s5, 0.02, 4.0, 1.0, 0.05, 0.01, mul: 15.0);
	strings = Compander.ar(strings, strings, 0.02, 2.5, 1.0, 0.01, 0.01, mul: 80.0);

  // *AUDIO ANALYSIS*
  // strings: onset detection before processing string signal further
  chain1 = FFT(LocalBuf(512), s5, 0.5, 1); // drone
  chain2 = FFT(LocalBuf(512), strings, 0.5, 1); // other strings
  onsets1 = Onsets.kr(chain1, 2.5, \power); // try different algorithms for CPU
  onsets2 = Onsets.kr(chain2, 4.0, \power); // try different algorithms for CPU



  // trill sensor
  centroids = TrillCentroids.kr(1, 0x18, 60, 1);

  // MODE TOGGLE: neckbottom toggles sampler mode
  t_neckbottom = (centroids[1] >= ~ranges[\neckbottom][0]) * (centroids[1] <= ~ranges[\neckbottom][1]);
  mode = Stepper.kr(t_neckbottom,0,0,2-1); // 2 modes
  //t_bottom.poll(1);

  // MODE TOGGLE: necktop toggles buffer
  // for the 0.0 segment you need an extra test that there is indeed a touch recognized
  t_necktop = (centroids[2] > 10) * (centroids[1] >= ~ranges[\necktop][0]) * (centroids[1] <= ~ranges[\necktop][1]);


  buf_select = Stepper.kr(t_necktop,0,0,3-1,1); // 2 buffers
  t_bufchange = Changed.kr(buf_select);
  buf_select.poll(0.5);
  //t_necktop.poll(2);

  // TRILL DOES WHAT?
  // slide control on the left hand for a rhythmic fragmenting / granulator of Roscoe! :-)

  // SAMPLE DRAG ON SAMPLE GRAIN SLIDER
  buf3 = Select.kr(buf_select, [
    ~bufs["Ahhhs_mono"], ~bufs["Moonshiner"], ~bufs["Hallelujah_Amazing_Grace_001"]
  ]);
  b3frames = BufFrames.kr(buf3);
  t_slide = (centroids[2] > 10) * (centroids[1] >= ~ranges[\slide][0]) * (centroids[1] <= ~ranges[\slide][1]);
  t3 = Gate.kr([centroids[1], centroids[2]], t_slide + t_bufchange); // pos, size
  b3dur = BufDur.kr(buf3);
  gpos_var = b3dur * t3[1].linlin(10, 1000, 0.05, 0.4);
  b3dur = b3dur - gpos_var + LFNoise1.ar(50).range(-1 * gpos_var, gpos_var);
  gpos = t3[0].linlin(~ranges[\slide][0], ~ranges[\slide][1], 0, b3dur);
  gpos = Lag.ar(K2A.ar(gpos), 0.1);
  gpos_var = LFNoise1.ar(20).range(-0.5, 0.5);
  gdur = t3[1].linlin(10, 1000, 0.1, 1.5);
  t_grain = Impulse.ar(10);
  slidesig =
  slidesig = Select.ar(mode, [
    DC.ar(0), // mode 0, no sampling
    TGrains.ar(2, t_grain, buf3, t3[1].linexp(10, 2000, -0.5, -2.0), gpos + gpos_var, gdur, TRand.ar(-1.0, 1.0, t_grain), t3[1].linlin(10, 2000, 0.2, 2.0)).tanh, // mode 1, TGrains party with Ahhhs!
  ]);



  // SEQUENCER 1 > Ahhhs, drone string (evenly spaced sample offsets - could also be algorithmic)
  b1frames = BufFrames.kr(buf1);
  noffsets1 = 10;
  b1offsets = Array.series(noffsets1, 0.0, 1.0 / (noffsets1-1)) * b1frames;
  boffset1 = Stepper.kr(onsets1, 0, 0, noffsets1-1);
  boffset1 = Select.kr(boffset1, b1offsets);
  bpos1 = Phasor.ar(onsets1, BufRateScale.kr(buf1), 0, b1frames, boffset1);
  seq1 = BufRd.ar(2, buf1, bpos1, 0.0, 2) * EnvGen.ar(Env.perc, onsets1, timeScale: 2.0) * 1.0;

  // SEQUENCER 2 > Moonshiner, other strings (use pre-calculated offsets)
  b2frames = BufFrames.kr(buf2);
  b2offsets = ~offsets["Moonshiner_verses"]; // OFFSETS IN SECONDS!
  noffsets2 = b2offsets.size;
  boffset2 = Stepper.kr(onsets2, 0, 0, noffsets2-1);
  boffset2 = Select.kr(boffset2, b2offsets);
  //boffset2.poll(1);
  boffset2 = boffset2 * BufSampleRate.kr(buf2); // CONVERT OFFSET IN SECONDS TO OFFSET IN FRAMES!
  //boffset2.poll(1);
  bpos2 = Phasor.ar(onsets2, BufRateScale.kr(buf2), 0, b2frames, boffset2);
  seq2 = BufRd.ar(1, buf2, bpos2, 0.0, 2) * EnvGen.ar(Env.perc, onsets2, timeScale: 10.0) * 1.0;




  // *STRING SIGNAL POST PRODUCTION* output processing
  s5 = s5 + AllpassC.ar(s5, 0.2, 0.01, 5.0);
  stringmix = GVerb.ar(s5+strings, 65, 3, 0.1, 0.2, 5, 1.0, 0.4, 0.6) + strings;

  mix = FreeVerb.ar(seq1+seq2+slidesig, 0.5, 0.8, 0.3, mul: 1.0) + stringmix;

  mix = Limiter.ar(LeakDC.ar(mix * 1.0), 1.0, 0.001);
  //mix = seq2;
  //RecordBuf.ar(mix, b, loop: 0); // record first 10 seconds of audio
  mix;
}.play(s, outbus: 0);

);





/* UNFINISHED ...
 ▄▄▄▄▄▄▄▄▄▄▄  ▄▄▄▄▄▄▄▄▄▄   ▄▄▄▄▄▄▄▄▄▄▄
▐░░░░░░░░░░░▌▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌
 ▀▀▀▀█░█▀▀▀▀ ▐░█▀▀▀▀▀▀▀█░▌▐░█▀▀▀▀▀▀▀▀▀
     ▐░▌     ▐░▌       ▐░▌▐░▌
     ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌▐░▌
     ▐░▌     ▐░░░░░░░░░░▌ ▐░▌
     ▐░▌     ▐░█▀▀▀▀▀▀▀█░▌▐░▌
     ▐░▌     ▐░▌       ▐░▌▐░▌
     ▐░▌     ▐░█▄▄▄▄▄▄▄█░▌▐░█▄▄▄▄▄▄▄▄▄
     ▐░▌     ▐░░░░░░░░░░▌ ▐░░░░░░░░░░░▌
      ▀       ▀▀▀▀▀▀▀▀▀▀   ▀▀▀▀▀▀▀▀▀▀▀

******** HALLELUJAH, SACRED HARP */
(
Ndef(\jo, {
  var mix, insig, s5, strings, stringsmix, thumbsig, slidesig, mag1, mag2, mic;
  var buf1, buf2, buf3, b1frames, b2frames, b3frames, smpl1, smpl2, spos1, spos2, spos3, b3dur, pos3var, graintrig;
  var t_mag1, t_mag2, magmap1, magmap2, mt1, mt2, seq1, seq2;
  var centroids, range_bottom=[0.4, 0.44], range_top=[0.48, 0.56], range_necktop=[0.0, 0.36], range_neckbottom=[0.88, 1.0], range_slide = [0.6, 0.84];
  var t_bottom, t_top, t_necktop, t_slide, mode = 0, t1, t2, t3;

  var nastynoise_hz = 230, noise_co_hz = 7000; // magic numbers
  mic = In.ar(2, 1) * 2.0;
  mag1 = In.ar(6,1);
  mag2 = In.ar(7,1);

  // STRINGS INPUT
  insig = [In.ar(4,1), In.ar(5,1)];
  insig = SVF.ar(insig, nastynoise_hz*2, 0.01 ,0,0,0,1,0);
  insig = Compander.ar(insig, insig, 0.1, 3.0, 1.0, 0.005, 0.01); // get rid of low noise
  s5 = insig[0] * 1; // drone
  strings = insig[1] * 3.0; // other four strings

  // TRILL INPUT
  centroids = TrillCentroids.kr(1, 0x18, 60, 1);

  // MODE TOGGLE: 0.4-0.44 bottom segment bounds
  t_bottom = (centroids[1] >= range_bottom[0]) * (centroids[1] <= range_bottom[1]);
  mode = Stepper.kr(t_bottom,0,0,1);
  //t_bottom.poll(1);

  // THUMB TAPS ON NECK TOPSIDE
  // for the 0.0 segment you need an extra test that there is indeed a touch recognized, because all touches default to 0!
  t_necktop = (centroids[2] > 10) * (centroids[1] >= range_necktop[0]) * (centroids[1] <= range_necktop[1]);
  t2 = [Gate.kr(centroids[1], t_necktop), centroids[2]];// pos, size
  thumbsig = Pulse.ar(t2[0].linexp(0.0, 0.36, 50, 1000)) * Lag.kr(centroids[2].linlin(10, 2000, 0.0, 0.7), 3.0) * t_necktop; // mode0
  thumbsig = AllpassC.ar(thumbsig, 0.2, 0.1, 3);

  // SAMPLE DRAG ON SLIDER
  buf3 = ~bufs["Hallelujah_Amazing_Grace_001"];
  b3frames = BufFrames.kr(buf3);
  t_slide = (centroids[2] > 10) * (centroids[1] >= range_slide[0]) * (centroids[1] <= range_slide[1]);
  t3 = Gate.kr([centroids[1], centroids[2]], t_slide); // pos, size
  b3dur = BufDur.kr(buf3);
  pos3var = b3dur * t3[1].linlin(10, 1000, 0.05, 0.4);
  b3dur = b3dur - pos3var + LFNoise1.ar(50).range(-1 * pos3var, pos3var);
  spos3 = t3[0].linlin(range_slide[0], range_slide[1], 0, b3dur);
  spos3 = Lag.ar(K2A.ar(spos3), 0.2);
  b3dur = t3[1].linlin(10, 1000, 0.05, 1.0);
  graintrig = Impulse.ar(10);
  slidesig = TGrains.ar(2, graintrig, buf3, 1.0, spos3, b3dur, TRand.ar(-1.0, 1.0, graintrig), 1.0);
  slidesig = FreeVerb.ar(slidesig, 0.3, 0.5, 0.3);


  // *STRING SIGNAL POST PRODUCTION* output processing
  s5=s5*4.0; strings=strings*6.0; // boost
  strings = Compander.ar(strings, strings, 0.7, 1.0, 0.1, 0.001, 0.1, mul: 10.0);
  stringsmix = GVerb.ar(s5+strings, 1, 1, 0.2, 0.2, 5, 1.0, 1.0, 0.4) * 2.0;


  mix = stringsmix+slidesig+thumbsig;

  //mix = SinOsc.ar() * 0.3 * EnvGen.ar(Env.perc, t_mag1, timeScale: 0.2);

  Limiter.ar(LeakDC.ar(mix * 0.5), 1.0, 0.001);
}).play(0, numChannels: 2, group: s);

);






