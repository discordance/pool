/**
 * NUNJA Sample Station v0.1
 * globals.scd
        _
        [ ]
       (   )
        |>|
     __/===\__
    //| o=o |\\
  <]  | o=o |  [>
      \=====/
     / / | \ \
    <_________>

 */

(
// ---
~mainVol = 0.5;
~mainOut = 0;

// audio busses
~compBus = 16;
~osBus = 18;
~drumBus = 20;
~fxBusses = 22;

// control busses
~dr_bus_base = 5;
~max_knob_bus = 48;
~dr_bus_pitch_base = ~dr_bus_base + 8;

~sampleMult = 0;

// count pads and keep memory on the two last hit
~pad_counter = ();
~pad_counter.pad_a = 0;
~pad_counter.pad_b = 0;
~pad_counter.ct = 0;

// timer keeps time
~timer = ();
~timer.ticks = 0;
~timer.quav = 0;
~timer.ivals = [256,192,128,96,64,48,32,25,16,12,8,4];

// sampler params
~splr_params = ();
~splr_params.density = 0.25;
~splr_params.rate = 1;
~splr_params.freq = 20000;

// os sampler file management
~sampleMult = 1;
~samplePer = 8;
~sampleIndex = 0;
~sampleSetsTotal = 0;
~pathArr;
~buffers;
~osPath = "/Users/nunja/Documents/AudioLib/supercollider/os/*";

// dr sampler file management
~kitCurrent = 0;
~kitBuffers;
~kitPathArr;
~kitPath = "/Users/nunja/Documents/AudioLib/supercollider/drumkit/*";
~kitWantedPitch = 48;
~kitCorrected = false;
~kitCorrectionsArr = Dictionary.new;
~kitCorrectionsBufs = Dictionary.new;

// kit params
~kit_params = ();
~kit_params.density = 1;
~kit_params.quant = [64,48,32,24,16,12,8,6,4,3,2,1];
)