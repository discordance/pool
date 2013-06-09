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

MIDI
******************************************************************/
(
~oMIDI =
(
// VARS
\devices:(),
\modules:[],
// METHODS
\init:{|o, router|
	var first_time = true;
	"~oMIDI : initializing ...".postln;
	o.router = router;
	if(MIDIClient.initialized == true,{
		first_time = false;
	});
	MIDIClient.init;
	MIDIIn.connectAll;
	//});
	o.devices.lpd8 = MIDIIn.findPort("LPD8", "LPD8") ? (\uid:0);
	o.devices.ancient = MIDIIn.findPort("Ancient2 NOTES OUT", "Ancient2 NOTES OUT") ? (\uid:0);
	o.devices.sync = MIDIIn.findPort("Ancient2 SYNC OUT", "Ancient2 SYNC OUT") ? (\uid:0);
	o.devices.motu = MIDIIn.findPort("UltraLite mk3", "MIDI Port") ? (\uid:0);
	if(first_time == true,{
		MIDIIn.addFuncTo(\noteOn, {|src, chan, num, val|
			o.on_note(src, chan, num, val);
		});
		MIDIIn.addFuncTo(\control, {|src, chan, num, val|
			o.on_control(src, chan, num, val);
		});
		MIDIIn.addFuncTo(\sysrt, {|src, val|
			o.on_clock(src, val);
		});
	});
},
\on_note: {|o, src, chan, num, val|

	o.modules.do({|e,i|
		e.devices.do({|ee,ii|
			if(ee.uid == src,{
				e.module.on_note(chan, num, val);
			});
		});
	});
},
\on_control: {|o, src, chan, num, val|

},
\on_clock: {|o, src, val|
	o.modules.do({|e,i|
		e.devices.do({|ee,ii|
			if(ee.uid == src,{
				e.module.on_clock(val);
			});
		});
	});
},
\register_module:{|o, module, devices|
	var mod = (\module:module, \devices:devices);
	o.modules = o.modules.add(mod);
}
)
)