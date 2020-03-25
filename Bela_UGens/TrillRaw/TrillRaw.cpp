/******
See the Server Plugin API for more info
http://doc.sccode.org/Reference/ServerPluginAPI.html
*****/

// TODO: make sure multiple Trill UGens access the same I2C data?
//      This follows the idiom of Input UGens accessing global signal busses.
//      ?? does this mean I2C data should be global?
//  Add functionality to keep track of number of active Trill UGens and throw an error if there is more than one...


#include "Bela.h"
#include "Trill.h"
#include "SC_PlugIn.h"
#include <pthread.h>

// number of sensors per Trill device
// TODO: update this once the 30-sensor Trill Sensors go into production
#define NUM_SENSORS 26

// InterfaceTable contains pointers to global functions in the host (scserver).
static InterfaceTable *ft;

// Track the number of active Trill UGens
static int numTrillUGens = 0;

// These functions are provided by Xenomai
int rt_printf(const char *format, ...);
int rt_fprintf(FILE *stream, const char *format, ...);

// Holds UGen state variables
struct TrillRaw : public Unit {
  // object constructors will not be called automatically
  // so all objects in the UGen struct must be pointers
  // and then allocated in the UGen constructor
  Trill* sensor;
  int i2c_bus, i2c_address;
  int mode;
  int noiseThreshold;
  int prescalerOpt;

  AuxiliaryTask i2cTask;
  unsigned int readInterval; // read interval in ms
  unsigned int readIntervalSamples;
  unsigned int readCount;

  bool updateNeeded = false;
  bool updateNoiseThreshold = false;
  bool updatePrescalerOpt = false;
  bool updateBaseLine = false;

  // Readins for all the different pads on the Trill Craft
  float sensorReading[NUM_SENSORS] = { 0.0 };

  // trigger
  float prevtrig = 0.0;
  // DEBUGGING bookkeeping
  unsigned int debugCounter = 0;
  unsigned char debugPrintRate = 4; // 4 times per second
};

/*
the "noise threshold" parameter is an integer from 5-255, where 5 is the lowest noise thresh
The Raw values can vary wildly depending on the noise threshold and prescaler, as well as
the mechanical aspects of the sensor pads, and should be tested in-situ.

prescaler values can be 1-16 in powers of 2, although nobody is really sure what it does intuitively
it seems to adjust the timing system and has something to do with the amount of capacitance
that can be read by the circuit
*/
// Prescaler options for Trill sensor, can be a value from 1-16 in powers of 2
int gPrescalerOpts[5] = {1, 2, 4, 8, 16};

static void TrillRaw_Ctor(TrillRaw* unit); // constructor
static void TrillRaw_Dtor(TrillRaw* unit); // destructor
static void TrillRaw_next_k(TrillRaw* unit, int inNumSamples); // audio callback

// I2C read/write function executed in an auxiliary task
// all I2C communications are enapsulated into a single thread to avoid
// colliding read/writes
// NO I2C reads or writes should happen in the audio thread!
void updateTrill(void* data) {
  TrillRaw *unit = (TrillRaw*)data;

  // 1. First update any settings that have been flagged for updating...
  if(unit->updateNeeded) {
    if(unit->updateNoiseThreshold && (unit->sensor->setNoiseThreshold(unit->noiseThreshold) != 0)) {
  		fprintf(stderr, "ERROR: Unable to set noise threshold on Trill Sensor!\n");
  	}
  	if(unit->updatePrescalerOpt && (unit->sensor->setPrescaler(gPrescalerOpts[unit->prescalerOpt]) != 0)) {
  		fprintf(stderr, "ERROR: Unable to set prescaler on Trill Sensor!\n");
  	}
    if(unit->updateBaseLine && (unit->sensor->updateBaseLine() != 0)) {
  		fprintf(stderr, "ERROR: Unable to update baseline on Trill Sensor!\n");
  	}
    if(unit->sensor->prepareForDataRead() != 0) {
  		fprintf(stderr, "ERROR: Unable to prepare Trill Sensor for reading data\n");
  	}
    unit->updateNoiseThreshold = false;
    unit->updatePrescalerOpt = false;
    unit->updateBaseLine = false;
    unit->updateNeeded = false;
  }


  // 2. Update the sensor data
	if(unit->sensor->isReady()) {
		unit->sensor->readI2C();
    for(unsigned int i=0; i < NUM_SENSORS; i++) {
      //unit->sensorReading[i] = map(unit->sensor->rawData[i], 200, 2000, 0.0, 1.0);
      unit->sensorReading[i] = unit->sensor->rawData[i];
    }
  } else {
      fprintf(stderr, "ERROR: Trill Sensor is not ready to read!\n");
  }
}



void TrillRaw_Ctor(TrillRaw* unit) {

  // all objects must be allocated in the constructor
  unit->sensor = new Trill();

  // Get initial arguments to UGen for I2C setup
  unit->i2c_bus = (int)IN0(0);
  unit->i2c_address = (int)IN0(1);
  unit->mode = Trill::DIFF; // read all sensors, return differential from baseline
  unit->noiseThreshold = (int)IN0(2);
  unit->prescalerOpt = (int)IN0(3);

  // zero control rate outputs
  for (int j = 0; j < unit->mNumOutputs; j++)
    OUT0(j) = 0.f;

  unit->readInterval = 5; // sensor read / launch I2C aux task in ms
  unit->readIntervalSamples = 0; // launch I2C aux task every X samples
  unit->readCount = 0;
  unit->i2cTask = Bela_createAuxiliaryTask(updateTrill, 50, "I2C-read", (void*)unit);
  unit->readIntervalSamples = SAMPLERATE * (unit->readInterval / 1000.f);


  printf("TrillRaw CTOR id: %p\n", pthread_self());

  // DEFAULT OPTS are defined in TrillUGens.sc
	  if(unit->sensor->setup(unit->i2c_bus, unit->i2c_address, unit->mode, unit->noiseThreshold, gPrescalerOpts[unit->prescalerOpt]) != 0) {
      fprintf(stderr, "ERROR: Unable to initialize touch sensor\n");
      return;
  } else {
    printf("Trill sensor found: devtype %d, firmware_v %d\n", unit->sensor->deviceType(), unit->sensor->firmwareVersion());
    printf("Found %d active Trill UGens\n", numTrillUGens);
    printf("Initialized with outputs: %d  i2c_bus: %d  i2c_addr: %d  mode: %d  thresh: %d  pre: %d  devtype: %d\n", unit->mNumOutputs, unit->i2c_bus, unit->i2c_address, unit->mode, unit->noiseThreshold, gPrescalerOpts[unit->prescalerOpt], unit->sensor->deviceType());
  }

  if(unit->sensor->deviceType() != Trill::ONED) {
  	 fprintf(stderr, "WARNING! Trill Device Type is %d... ignoring... \n", unit->sensor->deviceType());
   }

   numTrillUGens++;
   if(numTrillUGens != 1) {
     fprintf(stderr, "WARNING! There are now %d active Trill UGens! This may cause unpredictable behavior as only one I2C connection is allowed at a time!", numTrillUGens);
   }

  if(unit->sensor->isReady()) {
    unit->sensor->readI2C();
  } else {
    fprintf(stderr, "Trill Sensor is not ready for I2C read.\n");
    return;
  }

  SETCALC(TrillRaw_next_k); // Use the same calc function no matter what the input rate is.
  TrillRaw_next_k(unit, 1); // calc 1 sample of output so that downstream UGens don't access garbage memory
}

void TrillRaw_Dtor(TrillRaw* unit)
{
  numTrillUGens--;
  printf("TrillRaw DTOR id: %p // %d active ugens remain\n", pthread_self(), numTrillUGens);
  if(numTrillUGens == 0)
    unit->sensor->cleanup();
  delete unit->sensor; // make sure to use delete here and remove your allocations
}


// the calculation function can have any name, but this is conventional. the first argument must be "unit."
// this function is called every control period (16 samples is typical on the Bela)
// Don't change the names of the arguments, or the helper macros like IN() and OUT() won't work.
void TrillRaw_next_k(TrillRaw* unit, int inNumSamples) {

  // NOTE: In general it's not a good idea to use static variables here
  //       they might be shared between plug-in instances!
  //static int readCount = 0;
  //       Put them in the unit struct instead!


  //*** DEBUGGING BOOKKEEPING ***/
  bool DEBUG = false;
  unit->debugCounter += inNumSamples;
  if(unit->debugCounter >= (SAMPLERATE / unit->debugPrintRate)) {
    unit->debugCounter = 0;
    DEBUG = true;
  }
  //*** END DEBUGGING ***/

  /*
  {
		static int xxx = 0;
		if(0 == xxx++)
			printf("TrillRaw Audio thread id: %p\n", pthread_self());
	};
  */


  // DO THINGS AT AUDIO RATE
  for(unsigned int n=0; n < inNumSamples; n++) { // check if the aux task should be launched again
    // This kind of sample-precision is not possible
    //   in the callback with Aux tasks, BUT this is realibly
    //   counting samples so the AUX task is called at a regular rate.
    // Running Aux tasks is more of a "request" than a demand..
    //   if an Aux task is called a second time the first call will be
    //   ignored...
    unit->readCount += 1;
    if(unit->readCount >= unit->readIntervalSamples) {
      unit->readCount = 0;
      Bela_scheduleAuxiliaryTask(unit->i2cTask); // run the i2c read every so many samples
    }
  }

  // CHECK FOR A NONPOSITIVE->POSITIVE TRIGGER TO RECALCULATE THE BASELINE AND PRESCALER/NOISE THRESH
  float curtrig = IN0(4);
  if (curtrig > 0.f && unit->prevtrig <= 0.f) {
    int noiseThreshold = (int)IN0(2);
    int prescalerOpt = (int)IN0(3);
    if(noiseThreshold != unit->noiseThreshold) {
      unit->noiseThreshold = noiseThreshold;
      unit->updateNoiseThreshold = true;
    }
    if(prescalerOpt != unit->prescalerOpt) {
      unit->prescalerOpt = prescalerOpt;
      unit->updatePrescalerOpt = true;
    }
    unit->updateBaseLine = true;
    unit->updateNeeded = true;

  }
  unit->prevtrig = curtrig;



  // TODO: maybe use unit->sensor->numSensors() instead
  //       and modify TrillRaw.sc to specify a variable number of sensors
  for (int i = 0; i < unit->mNumOutputs; i++) {
    OUT0(i) = unit->sensorReading[i];
  }
}

PluginLoad(TrillRaw) {
    ft = inTable; // store pointer to InterfaceTable
    DefineDtorCantAliasUnit(TrillRaw);
}
