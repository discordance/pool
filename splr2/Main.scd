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


// TODO


/******************************************************************/
(
s.options.numInputBusChannels = 0;
s.options.numOutputBusChannels = 16;
s.options.numBuffers = 2048;
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
	"Nappler.scd".loadRelative;

	// effects
	"Reverb.scd".loadRelative;
	"EchoDelay.scd".loadRelative;
	"Nasty.scd".loadRelative;

	// debug ui
	"UI.scd".loadRelative;

	// randomer
	"Randomer.scd".loadRelative;

	/**
	* INIT AND LOAD
	*/
	// CLEAR LIB
	Library.clear;
	// ROUTER FIRST
	~oROUTER.init(true); // is is for debug on standard stereo
	// THEN PRESET
	~oPRESET.init("/Users/nunja/Documents/SuperCollider/presets/", true); //
	// THEN MIDI
	~oMIDI.init(~oROUTER, ~oPRESET, ~oRANDOMER, ~oDRUMS);
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
		~oROUTER.register_fx(~oECHO, [~oMIDI.devices.motu,~oMIDI.devices.sync]);
	});
	//NASTY
	~oNASTY.init(~oROUTER, {
		"~oNASTY : fx unit loaded".postln;
		~oPRESET.register(~oNASTY);
		~oROUTER.register_fx(~oNASTY, [~oMIDI.devices.motu]);
	});

	// ---------------- MODULES
	// DRUMS
	~oDRUMS.init(~oROUTER,"/Users/nunja/Documents/AudioLib/supercollider/percussion/",{|o,init|
		"~oDRUMS : initialized.".postln;
		~oROUTER.register_module(~oDRUMS, [~oMIDI.devices.motu,~oMIDI.devices.ancient,~oMIDI.devices.sync]);
		~oPRESET.register(~oDRUMS);
		~oDRUMS.attach_fx(~oREVERB);
		~oDRUMS.attach_fx(~oECHO);
		~oDRUMS.attach_fx(~oNASTY);
		~oDRUMS.load({|o|
			"~oDRUMS : samples loaded.".postln;
			// SHOTS
			~oSHOT.init(~oROUTER,"/Users/nunja/Documents/AudioLib/supercollider/os/",{|o,init|
				"~oSHOT : initialized.".postln;

				~oROUTER.register_module(~oSHOT, [~oMIDI.devices.sync, ~oMIDI.devices.dj3]);
				~oPRESET.register(~oSHOT);
				~oSHOT.attach_fx(~oREVERB);
				~oSHOT.attach_fx(~oECHO);
				~oSHOT.attach_fx(~oNASTY);
				~oSHOT.load({|o|
					"~oSHOT : samples loaded.".postln;
					// LOOPS

					~oNAPPLER.init(~oROUTER,"/Users/nunja/Documents/AudioLib/supercollider/loop/",{|o,init|
						~oROUTER.register_module(~oNAPPLER, [~oMIDI.devices.dj3],2);
						~oPRESET.register(~oNAPPLER);
						~oNAPPLER.attach_fx(~oREVERB);
						~oNAPPLER.attach_fx(~oECHO);
						~oNAPPLER.attach_fx(~oNASTY);
						~oNAPPLER.load({|o|
							"~oNAPPLER : samples loaded.".postln;
						});
					});

				});
			});
		});
	});
});
)

/**
* REGLAGES COOL OTO BISCUIT :
* [b][r][b][.][b][b][b][b]
*/

/**
 * !!!!! ATTENTION CONNARD AVANT DE SAVE
 * !!!!! ATTENTION CONNARD AVANT DE SAVE
 * !!!!! ATTENTION CONNARD AVANT DE SAVE
 * !!!!! ATTENTION CONNARD AVANT DE SAVE
 */
                                         ~oPRESET.save_preset("dly_senior");
/**
 * !!!!! ATTENTION CONNARD AVANT DE SAVE
 */


/**
 * Presets
 * vbn_deep1 - 115s
 */
~oPRESET.load_preset("6b_tribal");
//ly_grithse avec a4 -> f10
//6b_indiehop
//6b_spanish
//6b_rnd1
//111_dubtech
//111_electr
//6b_joe
//6b_tribal
//6b_dirthouse
//6b_crade

//111_tribal

 //VIDER LES PADS
~oSHOT.memory_pads = []; //VIDER LES PADS

// UN MAX DE LOL
(
~oRANDOMER.randomize_drums(~oDRUMS);
)

~oSHOT.density = 0.4;

~oSHOT.pitch = 1.3;
~oSHOT.decay = 0.01;
~oSHOT.atk = 0;

// SHOT STORY
~oSHOT.select_next_kit();
~oSHOT.select_prev_kit();
~oSHOT.trig_shot(~oSHOT.selected_kit, 0, 0.2, ~oSHOT.pitch, ~oSHOT.decay, ~oSHOT.atk, false);
~oSHOT.trig_shot(~oSHOT.selected_kit, 1, 0.2, ~oSHOT.pitch, ~oSHOT.decay, ~oSHOT.atk, false);
~oSHOT.trig_shot(~oSHOT.selected_kit, 2, 0.2, ~oSHOT.pitch, ~oSHOT.decay, ~oSHOT.atk, false);
~oSHOT.trig_shot(~oSHOT.selected_kit, 3, 0.2, ~oSHOT.pitch, ~oSHOT.decay, ~oSHOT.atk, false);

~oSHOT.trig_shot(~oSHOT.selected_kit, 0, 0.2, ~oSHOT.pitch, ~oSHOT.decay, ~oSHOT.atk, true);
~oSHOT.trig_shot(~oSHOT.selected_kit, 1, 0.2, ~oSHOT.pitch, ~oSHOT.decay, ~oSHOT.atk, true);
~oSHOT.trig_shot(~oSHOT.selected_kit, 2, 0.2, ~oSHOT.pitch, ~oSHOT.decay, ~oSHOT.atk, true);
~oSHOT.trig_shot(~oSHOT.selected_kit, 3, 0.2, ~oSHOT.pitch, ~oSHOT.decay, ~oSHOT.atk, true);
