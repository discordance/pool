/*****************************************************************

                        boing         boing         boing
              e-e           . - .         . - .         . - .
             (\_/)\       '       `.   ,'       `.   ,'       .
              `-'\ `--.___,         . .           . .          .
                 '\( ,_.-'
                    \\               "             "            "
                    ^'
SPLR v2 - Vauban
****

MAIN
******************************************************************/
(
s.waitForBoot({
	/**
	* LOAD CLASSES
	*/
	// load bootstrap for class inheritance;
	"_bootstrap.scd".loadRelative;
	// modules
	"Router.scd".loadRelative;
	"Midi.scd".loadRelative;
	"Preset.scd".loadRelative;
	"Drums.scd".loadRelative;
	"Shot.scd".loadRelative;
	// effects
	"Reverb.scd".loadRelative;
	"EchoDelay.scd".loadRelative;


	/**
	* INIT AND LOAD
	*/
	// CLEAR LIB
	Library.clear;
	// ROUTER FIRST
	~oROUTER.init(true); // is is for debug on standard stereo
	// THEN PRESET
	~oPRESET.init("/Users/nunja/Documents/SuperCollider/presets/");
	// THEN MIDI
	~oMIDI.init(~oROUTER);

	// ---------------- FXS FIRST  !!!!
	// REVERB
	~oREVERB.init(~oROUTER, {
		"~oREVERB : fx unit loaded".postln;
		~oPRESET.register(~oREVERB);
		~oROUTER.register_fx(~oREVERB, [~oMIDI.devices.motu]);
	});
	// DELAY

	~oECHO.init(~oROUTER, {
		"~oECHO : fx unit loaded".postln;
		~oPRESET.register(~oECHO);
		~oROUTER.register_fx(~oECHO, [~oMIDI.devices.motu]);
	});
	// ---------------- MODULES
	// DRUMS
	~oDRUMS.init(~oROUTER,"/Users/nunja/Documents/AudioLib/supercollider/percussion/",{|o,init|
		"~oDRUMS : initialized.".postln;
		~oROUTER.register_module(~oDRUMS, [~oMIDI.devices.motu,~oMIDI.devices.ancient,~oMIDI.devices.sync]);
		~oPRESET.register(~oDRUMS);
		~oDRUMS.attach_fx(~oREVERB);
		~oDRUMS.attach_fx(~oECHO);
		~oDRUMS.load({|o|
			"~oDRUMS : samples loaded.".postln;
		});
	});
	// SHOTS
	~oSHOT.init(~oROUTER,"/Users/nunja/Documents/AudioLib/supercollider/os/",{|o,init|
		"~oSHOT : initialized.".postln;
		~oSHOT.load({|o|
			"~oSHOT : samples loaded.".postln;
		});
	});


});
)

/**
 * !!!!! ATTENTION CONNARD AVANT DE SAVE
 * !!!!! ATTENTION CONNARD AVANT DE SAVE
 * !!!!! ATTENTION CONNARD AVANT DE SAVE
 * !!!!! ATTENTION CONNARD AVANT DE SAVE
 */
~oPRESET.save_preset("vbn_hrdhse");
/**
 * !!!!! ATTENTION CONNARD AVANT DE SAVE
 */

~oPRESET.load_preset("vbn_hrdhse");
// MAXI LOL
(
//
var bus = Bus.new('control', 21,1,s);
bus.set(0.56);
bus = Bus.new('control', 20,1,s);
bus.set(0.3);
bus = Bus.new('control', 33,1,s);
bus.set(0.3);
bus = Bus.new('control', 25,1,s);
bus.set(0.3);
bus = Bus.new('control', 28,1,s);
bus.set(0.5);
~oDRUMS.current_kit[\kick] = 0;
~oDRUMS.current_kit[\drm1] = 4;
~oDRUMS.current_kit[\drm2] = 2;
~oDRUMS.current_kit[\snar] = 2;
~oDRUMS.current_kit[\clap] = 4;
~oDRUMS.current_kit[\cymb] = 3;
~oDRUMS.current_kit[\hat1] = 2;
~oDRUMS.current_kit[\hat2] = 5;
~oDRUMS.density = 1;
~oDRUMS.kr_route_map;
)
Library.postTree;
(
//debug stuff
{
SynthDef(\nun_debug_out, {
		var sig;
		sig = Splay.ar(In.ar(15, 4),0);
		Out.ar(0,sig);
}).add;
s.sync;
	Synth.head(~oROUTER[\node_groups][\main_out], "nun_debug_out", [\in_start, 15, \in_end, 19]);
}.fork;
)
(
~oDRUMS.kr_route_map['premix_drums_3'];
)


~oDRUMS.kr_route_map;
(
var bus;
bus = Bus.new('control', 47,1,s); // 38 41 44 47
bus.set(1);
)

(
var bus = Bus.new('control', 47,1,s); // 38 41 44 47
bus.set(0);

)

~oDRUMS.available_kits.postcs;
~oDRUMS.select_kit(\hat1,0.4);