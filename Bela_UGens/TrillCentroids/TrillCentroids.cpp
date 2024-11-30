/******
See the Server Plugin API for more info
http://doc.sccode.org/Reference/ServerPluginAPI.html
*****/

#include <Bela.h>
#include <Trill.h>
#include "SC_PlugIn.h"
#include <thread>

#define NUM_TOUCH 5 // maximum number of touch centroids

// InterfaceTable contains pointers to global functions in the host (scserver).
static InterfaceTable *ft;

// Holds UGen state variables
struct TrillCentroids : public Unit {
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

  // trigger
  float prevtrig;

  // DEBUGGING bookkeeping
  unsigned int debugCounter;
  unsigned char debugPrintRate; // 4 times per second
  bool enable;
};

static void TrillCentroids_Ctor(TrillCentroids* unit); // constructor
static void TrillCentroids_Dtor(TrillCentroids* unit); // destructor
static void TrillCentroids_next_k(TrillCentroids* unit, int inNumSamples); // audio callback

// I2C read/write function executed in a separate thread
// all I2C communications are enapsulated into a single thread to avoid
// colliding read/writes
// NO I2C reads or writes should happen in the audio thread!
static void updateTrill(TrillCentroids* unit)
{
  while(!unit->threadShouldStop && !Bela_stopRequested())
  {
    if(!unit->enable)
      return;

    // 1. First update any settings that have been flagged for updating...
    if(unit->updateNeeded) {
      if(unit->updateNoiseThreshold && (unit->sensor->setNoiseThreshold(unit->noiseThreshold) != 0))
        fprintf(stderr, "ERROR: Unable to set noise threshold on Trill Sensor!\n");
      if(unit->updatePrescalerOpt && (unit->sensor->setPrescaler(unit->prescaler) != 0))
        fprintf(stderr, "ERROR: Unable to set prescaler on Trill Sensor!\n");
      if(unit->updateBaseline && (unit->sensor->updateBaseline() != 0))
        fprintf(stderr, "ERROR: Unable to update baseline on Trill Sensor!\n");
      unit->updateNoiseThreshold = false;
      unit->updatePrescalerOpt = false;
      unit->updateBaseline = false;
      unit->updateNeeded = false;
    }


    // 2. Update the sensor data
    int ret = unit->sensor->readI2C(); // read latest i2c data & calculate centroids
    if(ret) {
      fprintf(stderr, "Error reading sensor: %d\n", ret);
      unit->enable = false;
      break;
    }
    usleep(unit->readInterval * 1000);
  } // while
}

static void zeroOuts(TrillCentroids* unit)
{
  // zero control rate outputs
  for(unsigned int n = 0; n < unit->mNumOutputs; ++n)
    OUT0(n) = 0;
}

void TrillCentroids_Ctor(TrillCentroids* unit) {
  SETCALC(TrillCentroids_next_k); // Use the same calc function no matter what the input rate is.
  // horrible hack to initialise everything to zero.
  memset(&(unit->sensor), 0, sizeof(TrillCentroids) - sizeof(Unit));
  unit->sensor = new Trill();   // all objects must be allocated in the constructor

  // Get initial arguments to UGen for I2C setup
  unit->i2c_bus = (int)IN0(0);
  unit->i2c_address = (int)IN0(1);
  unit->mode = Trill::CENTROID; // tell sensor to calculate touch centroids
  unit->noiseThreshold = (float)IN0(2);
  unit->prescaler = (int)IN0(3);

  zeroOuts(unit);

  unit->readInterval = 5; // (MAGIC NUMBER) sensor update/launch I2C aux task every 5ms
  unit->debugPrintRate = 4; // 4 times per second

  // initialize / setup the Trill sensor
  if(unit->sensor->setup(unit->i2c_bus, Trill::UNKNOWN, unit->i2c_address) != 0) {
    fprintf(stderr, "ERROR: Unable to initialize touch sensor\n");
    return;
  } else {
    unit->sensor->setMode(unit->mode);
    unit->sensor->setNoiseThreshold(unit->noiseThreshold);
    unit->sensor->setPrescaler(unit->prescaler);
    unit->sensor->updateBaseline(); // this was not explicitly requested, but you are expected to want it at startup.
    printf("Trill sensor found: devtype %d, firmware_v %d\n", unit->sensor->deviceType(), unit->sensor->firmwareVersion());
    printf("Initialized with #outputs: %d  i2c_bus: %d  i2c_addr: %d device: %s mode: %s  thresh: %.4f  pre: %d\n", unit->mNumOutputs, unit->i2c_bus, unit->i2c_address, Trill::getNameFromDevice(unit->sensor->deviceType()).c_str(), Trill::getNameFromMode(unit->mode).c_str(), unit->noiseThreshold, unit->prescaler);
  }

  if(!unit->sensor->is1D() && !unit->sensor->is2D()) {
    fprintf(stderr, "WARNING! You are using a Trill device of type %s that is not a linear (1D) or planar (2D) Trill sensor. The UGen may not function properly.\n", Trill::getNameFromDevice(unit->sensor->deviceType()).c_str());
  }

  unit->enable = true;
  unit->sensor->readI2C();

  TrillCentroids_next_k(unit, 1); // calc 1 sample of output so that downstream UGens don't access garbage memory
  unit->threadShouldStop = 0;
  unit->thread = new std::thread(updateTrill, unit);
}

void TrillCentroids_Dtor(TrillCentroids* unit)
{
  if(unit->thread && unit->thread->joinable())
  {
    unit->threadShouldStop = 1;
    unit->thread->join();
  }
  delete unit->thread;
  delete unit->sensor;
}

static inline void safeWrite(TrillCentroids* unit, unsigned int idx, float value)
{
  if(idx < unit->mNumOutputs)
    OUT0(idx) = value;
}
/*
Called every control period (16 samples is typical on the Bela)
The calculation function can have any name, but this is conventional.
the first argument must be named "unit" for the IN and OUT macros to work.
*/
void TrillCentroids_next_k(TrillCentroids* unit, int inNumSamples) {
  if(!unit->enable)
  {
    zeroOuts(unit);
    safeWrite(unit, 0, -1);
    safeWrite(unit, NUM_TOUCH * 2 + 1, -1);
    return;
  }
  //*** DEBUGGING BOOKKEEPING, for printing throttled output from the audio loop ***/
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

  // update control rate outputs
  // write vertical touches
  unsigned int touches = min(NUM_TOUCH, unit->sensor->getNumTouches());
  unsigned int offset = 0;
  safeWrite(unit, offset++, touches);
  for(unsigned int i = 0; i < NUM_TOUCH; i++) {
    float location = 0;
    float size = 0;
    if(i < touches) {
      location = unit->sensor->touchLocation(i);
      size = unit->sensor->touchSize(i);
    }
    safeWrite(unit, offset++, location);
    safeWrite(unit, offset++, size);
  }
  // write horizontal touches
  touches = min(NUM_TOUCH, unit->sensor->getNumHorizontalTouches());
  safeWrite(unit, offset++, touches);
  for(int i = 0; i < touches; i++) {
    float location = 0;
    float size = 0;
    if(i < touches) {
      location = unit->sensor->touchHorizontalLocation(i);
      size = unit->sensor->touchHorizontalSize(i);
    }
    safeWrite(unit, offset++, location);
    safeWrite(unit, offset++, size);
  }
}

PluginLoad(TrillCentroids) {
  ft = inTable; // store pointer to InterfaceTable
  DefineDtorCantAliasUnit(TrillCentroids);
}
