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
	"Drums.scd".loadRelative;
	/**
	* INIT AND LOAD
	*/
	// ROUTER FIRST
	~oROUTER.init();
	// THEN MIDI
	~oMIDI.init(~oROUTER);
	// DRUMS
	~oDRUMS.init(~oROUTER,"/Users/nunja/Documents/AudioLib/supercollider/percussion/",{|o,init|
		"~oDRUMS : initialized.".postln;
		~oDRUMS.load({|o|
			"~oDRUMS : samples loaded.".postln;
		});
	});
	~oMIDI.register_module(~oDRUMS, [~oMIDI.devices.motu,~oMIDI.devices.ancient,~oMIDI.devices.sync]);
});
)

//~oDRUMS.get_bounds_from_kit(\kick, 5);
//~oMIDI.devices;
//~oDRUMS.available_kits.postln;
//~oROUTER.modules.postln;
//~oMIDI.modules;
//