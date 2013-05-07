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
~userPath = "/Users/nunja/Documents/";
~mainVol = 0.6;
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
~timer.ivals = [256,192,128,96,64,48,32,24,16,12,8,6,4,3,2];

// sampler params
~splr_params = ();
~splr_params.density = 0.25;
~splr_params.rate = 1;
~splr_params.freq = 20000;
~splr_params.bias = 0;

// os sampler file management
//~sampleMult = 1;
~sampleIndex = 0;
~sampleSetsTotal = 0;
~pathArr;
~buffers = Dictionary.new;
~osPath = ~userPath++"AudioLib/supercollider/os/*";
~osBuffers = []; // <--- to retrieve Buffers

// dr sampler file management
~kitCurrent = 0;
~kitBuffers;
~kitPathArr;
~kitPath = ~userPath++"AudioLib/supercollider/drumkit/*";
~kitPitchPath = ~userPath++"SuperCollider/presets/kitpitches/";
~kitPitches = Object.readArchive(~kitPitchPath++~kitCurrent);
if(~kitPitches == nil,{
	~kitPitches = Dictionary.new;
	~kitPitches.put(~kitCurrent.floor, [0,0,0,0,0,0,0,0] );
});
//~kitPitches.postln;

// deprecated
~kitWantedPitch = 48;
~kitCorrected = false;
~kitCorrectionsArr = Dictionary.new;
~kitCorrectionsBufs = Dictionary.new;


// kit params
~kit_params = ();
~kit_params.density = 1;
~kit_params.quant = [64,48,32,24,16,12,8,6,4,3,2,1];

// melodic stuff

~create_octave_down_ratios = {|scale|
	var arr = [];
	scale.do({|elem, i|
		arr = arr.add([0.5,1].asSpec.map(elem-1));
	});
	arr;
};

~scale =  Scale.phrygian.ratios;
~scale = ~scale ++ ~create_octave_down_ratios.value(~scale);
~change_rate = false;
)

