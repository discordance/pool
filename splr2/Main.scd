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





/* JUST SWEET THE TRIGGER */


/******************************************************************/
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

	// debug ui
	"UI.scd".loadRelative;

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
	// ui
	// now inits UI
	~oUI.init();

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
		~oUI.bind_module(~oDRUMS);
	});
	// SHOTS
	~oSHOT.init(~oROUTER,"/Users/nunja/Documents/AudioLib/supercollider/os/",{|o,init|
		"~oSHOT : initialized.".postln;
		~oROUTER.register_module(~oSHOT, [~oMIDI.devices.sync, ~oMIDI.devices.dj3]);
		~oPRESET.register(~oSHOT);
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
~oDRUMS.current_kit[\kick] = ~oDRUMS.available_kits[\kick].keys.asArray.choose.postln;
~oDRUMS.current_kit[\drm1] = ~oDRUMS.available_kits[\drm1].keys.asArray.choose;
~oDRUMS.current_kit[\drm2] = ~oDRUMS.available_kits[\drm2].keys.asArray.choose;
~oDRUMS.current_kit[\snar] = ~oDRUMS.available_kits[\snar].keys.asArray.choose;
~oDRUMS.current_kit[\clap] = ~oDRUMS.available_kits[\clap].keys.asArray.choose;
~oDRUMS.current_kit[\cymb] = ~oDRUMS.available_kits[\cymb].keys.asArray.choose;
~oDRUMS.current_kit[\hat1] = ~oDRUMS.available_kits[\hat1].keys.asArray.choose;
~oDRUMS.current_kit[\hat2] = ~oDRUMS.available_kits[\hat2].keys.asArray.choose;
~oDRUMS.density = 1;
//~oDRUMS.kr_route_map.postcs;
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
bus = Bus.new('control', 46,s); // 38 41 44 47
bus.set(0.6);
)

(
var bus = Bus.new('control', 47,1,s); // 38 41 44 47
bus.set(0);
)

~oDRUMS.available_kits.postcs;
~oDRUMS.select_kit(\kick,0.8);
~oSHOT.available_kits.postcs;
~oSHOT.ar_route_map;

~oSHOT.trig_shot(0);

~oSHOT.kr_route_map;