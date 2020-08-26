/************************************************************
UGen class definitions for using Trill Sensors on the Bela

2019 (C) Jonathan Reus

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License https://www.gnu.org/licenses/
for more details.
*************************************************************/


/*
Default values are chosen which are viable for most usage scenarios.
By default noise threshold is low and sensitivity is high.

i2c_bus           I2C bus to use on BeagleBone
i2c_address       I2C address of Trill sensor
noiseThreshold    noise threshold, float: 0-0.0625, with 0.0625 being the highest noise thresh
prescaler         int: 1-8, lower values=higher sensitivity
t_resetBaseline   trigger: 0->1 transition recalculates capacitive baseline value
*/
TrillRaw : MultiOutUGen {
  *kr {arg i2c_bus=1, i2c_address=0x20, noiseThreshold=0, prescaler=2, t_resetBaseline=0.0;
    if(noiseThreshold.inclusivelyBetween(0,1).not) { Exception("Noise threshold '%' out of bounds. Must be a float from 0 to 1.".format(noiseThreshold)).throw };
    if(prescaler.inclusivelyBetween(1,8).not) { Exception("Prescaler % out of bounds. Must be an index from 1 to 8.".format(prescaler)).throw };

    ^this.multiNew('control', i2c_bus, i2c_address, noiseThreshold, prescaler, t_resetBaseline);
  }

  // 30 fixed outputs
  init { arg ... theInputs;
    inputs = theInputs;
    ^this.initOutputs(30, rate);
  }

  // check that trigger is control rate
  checkInputs {
    if ( ( rate !== inputs.at(4).rate ).and { \scalar !== inputs.at(4).rate } ) {
  			^("TrillRaw: t_resetBaseline must be control rate or scalar, but is " + inputs.at(4).rate);
  	};
  	^this.checkValidInputs
  }
}

/*
Default values are chosen which are viable for most usage scenarios.
By default noise threshold is low and sensitivity is high.
The outputs should be interpreted as the number of active touches, followed by location, size pairs for each touch centroid like so:

[numActive, loc1, size1, loc2, size2, loc3, size3, loc4, size4, loc5, size5]

Where:
loc - is a value from 0.-1. specifying the position on the trill bar.
size - is a value somewhere in the range of 0-6000 specifying the centroid size.

By default all 5 potential centroids are tracked (for a total of 10 kr outputs).

i2c_bus          I2C bus to use on BeagleBone
i2c_address      I2C address of Trill sensor
noiseThreshold    noise threshold, float: 0-0.0625, with 0.0625 being the highest noise thresh
prescaler         int: 1-8, lower values=higher sensitivity
t_resetBaseline   trigger: 0->1 transition recalculates capacitive baseline value
*/
TrillCentroids : MultiOutUGen {
  *kr {arg i2c_bus=1, i2c_address=0x20, noiseThreshold=0, prescaler=2, t_resetBaseline=0.0;
    if(noiseThreshold.inclusivelyBetween(0,1).not) { Exception("Noise threshold '%' out of bounds. Must be an integer from 0 to 1.".format(noiseThreshold)).throw };
    if(prescaler.inclusivelyBetween(1,8).not) { Exception("Prescaler % out of bounds. Must be an index from 1 to 8.".format(prescaler)).throw };

    ^this.multiNew('control', i2c_bus, i2c_address, noiseThreshold, prescaler, t_resetBaseline);
  }

  init { arg ... theInputs;
    inputs = theInputs;
    ^this.initOutputs(11, rate); // 11 outputs
  }

  // check that trigger is control rate
  checkInputs {
    if ( ( rate !== inputs.at(4).rate ).and { \scalar !== inputs.at(4).rate } ) {
  			^("TrillCentroids: t_resetBaseline must be control rate or scalar, but is " + inputs.at(4).rate);
  	};
  	^this.checkValidInputs
  }
}



/* USEFUL EXAMPLES OF MULTI-OUT UGENS
https://github.com/supercollider/supercollider/tree/develop/server/plugins

// MFCC has a variable number of control rate output channels
// specified at instantiation.
MFCC : MultiOutUGen {
*kr { arg chain, numcoeff=13;
^this.multiNew('control', chain, numcoeff);
}

init { arg ... theInputs;
inputs = theInputs;
^this.initOutputs(theInputs[1], rate);
}
}

// BeatTrack2 has 6 fixed control rate output channels
BeatTrack2 : MultiOutUGen {
*kr { arg busindex, numfeatures, windowsize=2.0, phaseaccuracy=0.02, lock=0, weightingscheme;
^this.multiNew('control',busindex, numfeatures,windowsize, phaseaccuracy, lock, weightingscheme ? (-2.1));
}

init { arg ... theInputs;
inputs = theInputs;
^this.initOutputs(6, rate);
}
}

// EXAMPLES OF TRIGGER-INPUT UGENS
https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Audio/UGen.sc
https://github.com/supercollider/supercollider/blob/develop/server/plugins/TriggerUGens.cpp
https://github.com/supercollider/supercollider/blob/develop/SCClassLibrary/Common/Audio/Trig.sc

SendTrig : UGen {
	*ar { arg in = 0.0, id = 0, value = 0.0;
		this.multiNew('audio', in, id, value);
		^0.0		// SendTrig has no output
	}
	*kr { arg in = 0.0, id = 0, value = 0.0;
		this.multiNew('control', in, id, value);
		^0.0		// SendTrig has no output
	}
	checkInputs {
  ^this.checkSameRateAsFirstInput
  }
	numOutputs { ^0 }
	writeOutputSpecs {}
}

SendReply : SendTrig {
	*kr { arg trig = 0.0, cmdName = '/reply', values, replyID = -1;
		if(values.containsSeqColl.not) { values = values.bubble };
		[trig, cmdName, values, replyID].flop.do { |args|
			this.new1('control', *args);
		};
		^0.0		// SendReply has no output
	}

	*ar { arg trig = 0.0, cmdName = '/reply', values, replyID = -1;
		if(values.containsSeqColl.not) { values = values.bubble };
		[trig, cmdName, values, replyID].flop.do { |args|
			this.new1('audio', *args);
		};
		^0.0		// SendReply has no output
	}

	*new1 { arg rate, trig = 0.0, cmdName = '/reply', values, replyID = -1;
		var ascii = cmdName.ascii;
		^super.new1(*[rate, trig, replyID, ascii.size].addAll(ascii).addAll(values));
	}
}


*/
