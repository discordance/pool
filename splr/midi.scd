/**
 * NUNJA Sample Station v0.1
 * midi.scd
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
//~test = 0;
~init_midi =
{
	var lpd8, ancient, a_sync_in, motu;
	~last = 0;
	~last_t = 0;
	MIDIClient.init;
	MIDIIn.connectAll;
	//MIDIIn.sysrt = { arg src, chan, val; 				[chan,val].postln; };

	lpd8 = MIDIIn.findPort("LPD8", "LPD8") ? (\uid:0);
	ancient = MIDIIn.findPort("Ancient2 NOTES OUT", "Ancient2 NOTES OUT") ? (\uid:0);
	a_sync_in = MIDIIn.findPort("Ancient2 SYNC OUT", "Ancient2 SYNC OUT") ? (\uid:0);
	motu = MIDIIn.findPort("UltraLite mk3", "MIDI Port") ? (\uid:0);

	MIDIIn.removeFuncFrom(\noteOn, ~splr_noteOn);
	MIDIIn.removeFuncFrom(\control, ~splr_control);
	MIDIIn.removeFuncFrom(\sysrt, ~splr_clock);

	// trigger of drum
	~trig_drum = { arg val, num;

		//(Main.elapsedTime - ~test).postln;
		//~test = Main.elapsedTime;
		//("HIT " ++ num).postln;
		switch(num,
			36,{
				~dr_synths[0].set(\t_trig,1);
				~dr_synths[0].set(\vol,val/127);
				~dr_synths[0].set(\freq,\freq.asSpec.map(val/127));
			},
			41,{
				~dr_synths[1].set(\t_trig,1);
				~dr_synths[1].set(\vol,val/127);
				~dr_synths[1].set(\freq,\freq.asSpec.map(val/127));
			},
			43,{
				~dr_synths[2].set(\t_trig,1);
				~dr_synths[2].set(\vol,val/127);
				~dr_synths[2].set(\freq,\freq.asSpec.map(val/127));
			},
			38,{
				~dr_synths[3].set(\t_trig,1);
				~dr_synths[3].set(\vol,val/127);
				~dr_synths[3].set(\freq,\freq.asSpec.map(val/127));
			},
			39,{
				~dr_synths[4].set(\t_trig,1);
				~dr_synths[4].set(\vol,val/127);
				~dr_synths[4].set(\freq,\freq.asSpec.map(val/127));
			},
			42,{
				~dr_synths[5].set(\t_trig,1);
				~dr_synths[5].set(\vol,val/127);
				~dr_synths[5].set(\freq,\freq.asSpec.map(val/127));
			},
			44,{
				~dr_synths[6].set(\t_trig,1);
				~dr_synths[6].set(\vol,val/127);
				~dr_synths[6].set(\freq,\freq.asSpec.map(val/127));
			},
			46,{
				~dr_synths[7].set(\t_trig,1);
				~dr_synths[7].set(\vol,val/127);
				~dr_synths[7].set(\freq,\freq.asSpec.map(val/127));
			},
		);
	};

	~splr_noteOn = { arg src, chan, num, val;
		var idx, quant;
		// from ancient
		if(src == ancient.uid,{

			if(~kit_params.density > 0, {
				quant = ~kit_params.quant[[0,~kit_params.quant.size-1].asSpec.map(~kit_params.density)];
				if((~timer.quav % quant).floor == 0, {
					~trig_drum.value(val, num);
				},{
						var thres = ~kit_params.density/2;
						if(1.0.rand < thres,{
							~trig_drum.value(val, num);
						});
				});
			});

		});
		// from lpd8
		if(src == lpd8.uid,{
			//"lpd8".postln;
			idx = (num-36);
			if(~pad_counter.ct % 2 == 0, {
				~pad_counter.pad_a = idx;
				},{
					~pad_counter.pad_b = idx;
			});
			~pad_counter.ct = ~pad_counter.ct + 1;

			// trigg sound and random delay and shape form
			~chebBuffer.sendCollection(Signal.sineFill(1000, [1, 1.0.rand, 1.0.rand, 1.0.rand]), 0);
			~fx_echo.set(\length, 1.0.rand);

			Synth.head(~splr_source,"nun_ossampler",
				[\buf_bounds, ~sampleIndexParse.value(idx),
					\out, ~osBus,
					\rate, ~splr_params.rate,
					\decay, [8,0.5].asSpec.map(~splr_params.density),
					\freq, \freq.asSpec.map(val/127)
			]);
			~new_pad.value(idx);
		});
	};
	~splr_control = { arg src, chan, num, val;

		// from MOTU IN
		if(src == motu.uid,{
			switch(chan,
				3,{
					var busnum = ~dr_bus_base+num;
					var bus = Bus.new('control', busnum,1,s);
					if(num < ~max_knob_bus,{

						bus.set(val/127);
						//busnum.postln;
						// special cases
						// store pitchs
						if( (busnum > 12).and(busnum < 21),{
							var idx = busnum - 13;
							~kitPitches[~kitCurrent.floor][idx] = val/127;
							~kitPitches.writeArchive(~kitPitchPath++~kitCurrent.floor);
						});
						// kit density
						if((busnum) == 5,{
							~kit_params.density = val/127;
						});
						// kit selecta
						if((busnum) == 8,{
							var kit_id = [0,~kitBuffers.size-1].asSpec.map(val/127);

							if(kit_id.floor != ~kitCurrent.floor, {
								~set_dr_kit.value(kit_id);
								("DR KIT : " ++ kit_id.floor).postln;
							});
						});

					},{
							if( (num >= 56).and(num <= 63),{
								var index = (num - 56), on = val/127;
								~dr_synths[index].set(\on,on);
							});

					});
				},
				4,
				{

				}
			);
		});

		// from lpd8
		if(src == lpd8.uid,{
			//("chan " ++ chan ++ " num " ++ num ++ " val " ++ val).postln;
			switch(num,
				// OS DENSITY
				1,{ ~splr_params.density = val/127; }, // special case 128 steps

				// OS KIT
				2,{
					~get_os_buffers.value(val);
				},
				// OS RATE
				3,{ ~splr_params.rate = [0.1,1.9].asSpec.map(val/127); },
				// OS DECAY
				4,{
					// bus 0 -> OS decay
					var bus = Bus.new('control',0,1,s);
					bus.set(val/127);
				},
				// OS ATTACK
				5,{
					var bus = Bus.new('control',1,1,s);
					bus.set(val/127);
				},
				6,{
					// bus 2 -> OS delay
					var bus = Bus.new('control',2,1,s);
					bus.set(val/127);
				},
				7,{
					// bus 3 -> os reverb
					var bus = Bus.new('control',3,1,s);
					bus.set(val/127);
				},
				8,{
					// bus 4 -> os shape
					var bus = Bus.new('control',4,1,s);
					bus.set(val/127);
				}
			);
		});
	};

	// clock
	~splr_clock = { arg src, val;
		if(src == a_sync_in.uid,{
			/*
			if(val == 2,{
				(Main.elapsedTime - ~last).post; " _ ".post; (~timer.ticks - ~last_t).postln;
				~last = Main.elapsedTime;
				~last_t = ~timer.ticks;
			});
			*/

			if(val == 10,{
				~timer.ticks = 0;
			});
			if(val == 8,{
				~timer.ticks = ~timer.ticks + 1;
				~timer.quav = ~timer.ticks/6;
			});
			if(val == 12,{
				~timer.ticks = 0;
			});
			// density
			if(~splr_params.density > 0, {
				var idx = [0,~timer.ivals.size-1].asSpec.map(~splr_params.density);
				var bias = ~splr_params.bias * ~timer.ivals[idx].rand;
				if(~timer.quav % (~timer.ivals[idx]+bias) == 0,{
					var idx = [~pad_counter.pad_a,~pad_counter.pad_b].choose;
					~fx_echo.set(\length, 1.0.rand);
					Synth.head(~splr_source,"nun_ossampler",
						[\buf_bounds, ~sampleIndexParse.value(idx),
							\out, ~osBus,
							\rate, ~splr_params.rate,
							\freq, ~splr_params.freq
					]);
					~new_pad.value(idx);
				});
			});
			~new_tick.value(~timer.ticks);
		});
	};

	MIDIIn.addFuncTo(\sysrt, ~splr_clock);
	MIDIIn.addFuncTo(\noteOn, ~splr_noteOn); // add
	MIDIIn.addFuncTo(\control, ~splr_control); // add
};