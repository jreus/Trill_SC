
#include "Bela.h"


// See the Server Plugin API for more info
// http://doc.sccode.org/Reference/ServerPluginAPI.html
#include "SC_PlugIn.h"

// These functions are provided by Xenomai
int rt_printf(const char *format, ...);
int rt_fprintf(FILE *stream, const char *format, ...);

// InterfaceTable contains pointers to functions in the host (scserver).
static InterfaceTable *ft;

// Holds UGen state variables
struct SimplePoll : public Unit {
  unsigned int blocksSinceLastPoll;

};

static void SimplePoll_Ctor(SimplePoll* unit); // constructor
static void SimplePoll_next(SimplePoll* unit, int inNumSamples); // audio callback

// the constructor function is called when a Synth containing this ugen is instantiated or played. It MUST be named "PluginName_Ctor"
// and the argument must be "unit" for macros to work
void SimplePoll_Ctor(SimplePoll* unit) {
  // init state variables & set up external dependencies
  unit->blocksSinceLastPoll = 0;

  // Use the same polling function no matter what the input rate is.
  SETCALC(SimplePoll_next);

  // calc 1 sample of output so that downstream Ugens don't access garbage
  SimplePoll_next(unit, 1);
}

// the calculation function can have any name, but this is conventional. the first argument must be "unit."
// this function is called every control period (64 samples is typical)
// Don't change the names of the arguments, or the helper macros won't work.
void SimplePoll_next(SimplePoll* unit, int inNumSamples) {

    float *insig = IN(0); // first input
    float *out = OUT(0); // first output
    float *pollRate = IN(1); // in seconds

    // print the last input sample & pass through everything else..
    insig[inNumSamples - 1];

    for (int i = 0; i < inNumSamples; i++) {
        out[i] = insig[i];
    }

    unit->blocksSinceLastPoll += 1;

    if(unit->blocksSinceLastPoll >= (BUFRATE * pollRate[0])) {
      rt_printf("BRate: %f  Blocks: %d  Poll: %f\n", BUFRATE, unit->blocksSinceLastPoll, insig[inNumSamples-1]);
      unit->blocksSinceLastPoll = 0;
    }
}

PluginLoad(SimplePoll) {
    ft = inTable; // store pointer to InterfaceTable
    DefineSimpleUnit(SimplePoll);
}
