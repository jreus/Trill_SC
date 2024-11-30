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
#include <thread>

// number of sensors per Trill device
#define NUM_SENSORS 30

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
  std::thread* thread;
  volatile int threadShouldStop;
  int i2c_bus, i2c_address;
  Trill::Mode mode;
  float noiseThreshold;
  int prescaler;

  unsigned int readInterval; // read interval in ms

  bool updateNeeded;
  bool updateNoiseThreshold;
  bool updatePrescalerOpt;
  bool updateBaseline;

  // Readins for all the different pads on the Trill Craft
  float sensorReading[NUM_SENSORS];

  // trigger
  float prevtrig;
  // DEBUGGING bookkeeping
  unsigned int debugCounter;
  unsigned char debugPrintRate;
  bool enable;
};

/*
the "noise threshold" parameter is an integer from 5-255, where 5 is the lowest noise thresh
The Raw values can vary wildly depending on the noise threshold and prescaler, as well as
the mechanical aspects of the sensor pads, and should be tested in-situ.

prescaler values can be 1-8, it sort of adjusts the gain of the capacitive
sensing channels, with smaller values corresponding to larger gain. If you raw reading are saturating,
try reducing the gain (i.e.: using a larger prescaler value), this will give you more headroom, possibly
at the expense of a worse SNR.
*/

static void TrillRaw_Ctor(TrillRaw* unit); // constructor
static void TrillRaw_Dtor(TrillRaw* unit); // destructor
static void TrillRaw_next_k(TrillRaw* unit, int inNumSamples); // audio callback

// I2C read/write function executed in a separate thread
// all I2C communications are enapsulated into a single thread to avoid
// colliding read/writes
// NO I2C reads or writes should happen in the audio thread!
void updateTrill(TrillRaw* unit) {
  while(!unit->threadShouldStop && !Bela_stopRequested())
  {
    if(!unit->enable)
      return;

    // 1. First update any settings that have been flagged for updating...
    if(unit->updateNeeded) {
      if(unit->updateNoiseThreshold && (unit->sensor->setNoiseThreshold(unit->noiseThreshold) != 0)) {
        fprintf(stderr, "ERROR: Unable to set noise threshold on Trill Sensor!\n");
      }
      if(unit->updatePrescalerOpt && (unit->sensor->setPrescaler(unit->prescaler) != 0)) {
        fprintf(stderr, "ERROR: Unable to set prescaler on Trill Sensor!\n");
      }
      if(unit->updateBaseline && (unit->sensor->updateBaseline() != 0)) {
        fprintf(stderr, "ERROR: Unable to update baseline on Trill Sensor!\n");
      }
      unit->updateNoiseThreshold = false;
      unit->updatePrescalerOpt = false;
      unit->updateBaseline = false;
      unit->updateNeeded = false;
    }


    // 2. Update the sensor data
      int ret = unit->sensor->readI2C();
      if(ret){
        fprintf(stderr, "Error reading sensor: %d\n", ret);
        unit->enable = false;
        break;
      }
      for(unsigned int i=0; i < NUM_SENSORS; i++) {
        unit->sensorReading[i] = unit->sensor->rawData[i];
      }
    usleep(unit->readInterval * 1000);
  } // while
}



void TrillRaw_Ctor(TrillRaw* unit) {

  // horrible hack to initialise everything to zero.
  memset(&(unit->sensor), 0, sizeof(TrillRaw) - sizeof(Unit));
  // all objects must be allocated in the constructor
  unit->sensor = new Trill();
  unit->debugPrintRate = 4; // 4 times per second

  // Get initial arguments to UGen for I2C setup
  unit->i2c_bus = (int)IN0(0);
  unit->i2c_address = (int)IN0(1);
  unit->mode = Trill::DIFF; // read all sensors, return differential from baseline
  unit->noiseThreshold = (float)IN0(2);
  unit->prescaler = (int)IN0(3);

  // zero control rate outputs
  for (int j = 0; j < unit->mNumOutputs; j++)
    OUT0(j) = 0.f;

  unit->readInterval = 5; // sensor read / launch I2C aux task in ms


  printf("TrillRaw CTOR id: %lu\n", pthread_self());

  // DEFAULT OPTS are defined in TrillUGens.sc
  if(unit->sensor->setup(unit->i2c_bus, Trill::UNKNOWN, unit->i2c_address) != 0) {
      fprintf(stderr, "ERROR: Unable to initialize touch sensor\n");
      return;
  } else {
    unit->sensor->setMode(unit->mode);
    unit->sensor->setNoiseThreshold(unit->noiseThreshold);
    unit->sensor->setPrescaler(unit->prescaler);
    unit->sensor->updateBaseline(); // this was not explicitly requested, but you are expected to want it at startup.
    printf("Trill sensor found: devtype %s, firmware_v %d\n", Trill::getNameFromDevice(unit->sensor->deviceType()).c_str(), unit->sensor->firmwareVersion());
    printf("Found %d active Trill UGens\n", numTrillUGens);
    printf("Initialized with outputs: %d  i2c_bus: %d  i2c_addr: %d  mode: %s  thresh: %.4f  pre: %d  devtype: %d\n", unit->mNumOutputs, unit->i2c_bus, unit->i2c_address, Trill::getNameFromMode(unit->mode).c_str(), unit->noiseThreshold, unit->prescaler, unit->sensor->deviceType());
  }

   numTrillUGens++;
   if(numTrillUGens != 1) {
     fprintf(stderr, "WARNING! There are now %d active Trill UGens! This may cause unpredictable behavior as only one I2C connection is allowed at a time!", numTrillUGens); // TODO: is it true??
   }

  unit->enable = true;
  unit->sensor->readI2C();

  SETCALC(TrillRaw_next_k); // Use the same calc function no matter what the input rate is.
  TrillRaw_next_k(unit, 1); // calc 1 sample of output so that downstream UGens don't access garbage memory
  unit->threadShouldStop = 0;
  unit->thread = new std::thread(updateTrill, unit);
}

void TrillRaw_Dtor(TrillRaw* unit)
{
  if(unit->thread && unit->thread->joinable())
  {
    unit->threadShouldStop = 1;
    unit->thread->join();
  }
  delete unit->thread;
  delete unit->sensor;
  numTrillUGens--;
  printf("TrillRaw DTOR id: %lu // %d active ugens remain\n", pthread_self(), numTrillUGens);
}


// the calculation function can have any name, but this is conventional. the first argument must be "unit."
// this function is called every control period (16 samples is typical on the Bela)
// Don't change the names of the arguments, or the helper macros like IN() and OUT() won't work.
void TrillRaw_next_k(TrillRaw* unit, int inNumSamples) {
  if(!unit->enable)
  {
    for (int j = 0; j < unit->mNumOutputs; j++)
      OUT0(j) = 0.f;
    return;
  }
  //*** DEBUGGING BOOKKEEPING ***/
  bool DEBUG = false;
  unit->debugCounter += inNumSamples;
  if(unit->debugCounter >= (SAMPLERATE / unit->debugPrintRate)) {
    unit->debugCounter = 0;
    DEBUG = true;
  }
  //*** END DEBUGGING ***/

  // CHECK FOR A NONPOSITIVE->POSITIVE TRIGGER TO RECALCULATE THE BASELINE AND PRESCALER/NOISE THRESH
  float curtrig = IN0(4);
  if (curtrig > 0.f && unit->prevtrig <= 0.f) {
    float noiseThreshold = (float)IN0(2);
    int prescaler = (int)IN0(3);
    if(noiseThreshold != unit->noiseThreshold) {
      unit->noiseThreshold = noiseThreshold;
      unit->updateNoiseThreshold = true;
    }
    if(prescaler != unit->prescaler) {
      unit->prescaler = prescaler;
      unit->updatePrescalerOpt = true;
    }
    unit->updateBaseline = true;
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
