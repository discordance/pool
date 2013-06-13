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
	/**
	* INIT AND LOAD
	*/
	// CLEAR LIB
	Library.clear;
	// ROUTER FIRST
	~oROUTER.init();
	// THEN PRESET
	~oPRESET.init("/Users/nunja/Documents/SuperCollider/presets/");
	// THEN MIDI
	~oMIDI.init(~oROUTER);
	// DRUMS
	~oDRUMS.init(~oROUTER,"/Users/nunja/Documents/AudioLib/supercollider/percussion_nt/",{|o,init|
		"~oDRUMS : initialized.".postln;
		~oDRUMS.load({|o|
			"~oDRUMS : samples loaded.".postln;
		});
	});
	~oROUTER.register_module(~oDRUMS, [~oMIDI.devices.motu,~oMIDI.devices.ancient,~oMIDI.devices.sync]);
	~oPRESET.register_module(~oDRUMS);
});
)

~oPRESET.save_preset("lol");
~oPRESET.load_preset("lol");
~oDRUMS.get_preset( {|archive| archive.postln; });

