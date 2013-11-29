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
// METHODS
\init:{|o, router, preset, randomer, drums|
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
	o.devices.dj3 = MIDIIn.findPort("Faderfox DJ3", "Faderfox DJ3") ? (\uid:0);

	Library.put(\device_map,o.devices.lpd8.uid,\lpd8);
	Library.put(\device_map,o.devices.sync.uid,\sync);
	Library.put(\device_map,o.devices.ancient.uid,\ancient);
	Library.put(\device_map,o.devices.motu.uid,\motu);
	Library.put(\device_map,o.devices.dj3.uid,\dj3);

	if(first_time == true,{
		MIDIIn.addFuncTo(\noteOn, {|src, chan, num, val|
			router.on_note(src, chan, num, val);
		});
		MIDIIn.addFuncTo(\control, {|src, chan, num, val|
			router.on_control(src, chan, num, val);
			//"contrl ".post;
			//(\src:src,\chan:chan, \num: num, \val: val).postln;
		});
		MIDIIn.addFuncTo(\sysrt, {|src, val|
			router.on_clock(src, val);
		});

		MIDIIn.addFuncTo(\sysex, {|src, sysex|
			var str, end;
			end = (sysex.size-1);
			str = "";
			sysex.do{|byte,i|
				if((i > 6).and( i < end),{
					str = str ++ byte.asAscii;
				});
			};
			if(preset.sysex_mode,{
				if(str == "rnd",{
					randomer.randomize_drums(drums);
				},{
					preset.load_preset(str);
				});

			});
		});
	});
}
)
)
