/******************************************
* Nunja Sampling Station - Supercollider
*/
~init_buffers.value();
~init_midi.value();



(
// ---

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
~timer.ivals = [256,128,64,32,16,8,4];

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

// kit params
~kit_params = ();
~kit_params.density = 1;
~kit_params.quant = [64,32,24,16,8,6,4,3,2,1];

// utility for the sampler
~sampleIndexParse = { |index|
	var arr = [-1,-1];
	//"sample parse".postln;
	//arr[0] = ~buffers[index][0].bufnum;
	(~buffers[index] != nil).if({arr[0] = ~buffers[index][0].bufnum;});
	//arr[1] = ~buffers[index][~buffers[index].size - 1].bufnum;
	(~buffers[index] != nil).if({arr[1] = ~buffers[index][~buffers[index].size - 1].bufnum;});
	arr;
};

~drumIndexParse = {|kit, perc|
	var arr = [-1,-1];
	(~kitBuffers[kit][perc] != nil).if({arr[0] = ~kitBuffers[kit][perc][0].bufnum;});//;
	(~kitBuffers[kit][perc] != nil).if({arr[1] = ~kitBuffers[kit][perc][~kitBuffers[kit][perc].size - 1].bufnum;});
	arr;
};

~init_midi =
{
	var lpd8, ancient, a_sync_in;

	MIDIClient.init;
	MIDIIn.connectAll;
	//MIDIIn.sysrt = { arg src, chan, val; 				[chan,val].postln; };

	lpd8 = MIDIIn.findPort("LPD8", "LPD8") ? (\uid:0);
	ancient = MIDIIn.findPort("Ancient2 NOTES OUT", "Ancient2 NOTES OUT") ? (\uid:0);
	a_sync_in = MIDIIn.findPort("Ancient2 SYNC OUT", "Ancient2 SYNC OUT") ? (\uid:0);

	MIDIIn.removeFuncFrom(\noteOn, ~splr_noteOn);
	MIDIIn.removeFuncFrom(\control, ~splr_control);
	MIDIIn.removeFuncFrom(\sysrt, ~splr_clock);

	~splr_noteOn = { arg src, chan, num, val;
		var idx, quant;
		// from ancient
		if(src == ancient.uid,{

			if(~kit_params.density > 0, {
				quant = ~kit_params.quant[[0,~kit_params.quant.size-1].asSpec.map(~kit_params.density)];
				if((~timer.quav % quant).floor == 0, {
					switch(num,
						36,{
							~dr_synths[0].set(\t_trig,1);
							~dr_synths[0].set(\vol,val/127);
						},
						41,{
							~dr_synths[1].set(\t_trig,1);
							~dr_synths[1].set(\vol,val/127);
						},
						43,{
							~dr_synths[2].set(\t_trig,1);
							~dr_synths[2].set(\vol,val/127);
						},
						38,{
							~dr_synths[3].set(\t_trig,1);
							~dr_synths[3].set(\vol,val/127);
						},
						39,{
							~dr_synths[4].set(\t_trig,1);
							~dr_synths[4].set(\vol,val/127);
						},
						42,{
							~dr_synths[5].set(\t_trig,1);
							~dr_synths[5].set(\vol,val/127);
						},
						44,{
							~dr_synths[6].set(\t_trig,1);
							~dr_synths[6].set(\vol,val/127);
						},
						46,{
							~dr_synths[7].set(\t_trig,1);
							~dr_synths[7].set(\vol,val/127);
						},
					);
				});
			});

		});
		// from lpd8
		if(src == lpd8.uid,{
			//"lpd8".postln;
			idx = (num-36);
			if(~pad_counter.ct % 2 == 0, {
				~pad_counter.pad_a = idx + (~samplePer*~sampleMult);
				},{
					~pad_counter.pad_b = idx + (~samplePer*~sampleMult);
			});
			~pad_counter.ct = ~pad_counter.ct + 1;

			// trigg sound
			~sampleIndex = idx + (~samplePer*~sampleMult);
			Synth.head(~splr_source,"nun_ossampler",
				[\buf_bounds, ~sampleIndexParse.value(~sampleIndex),
					\out, 0,
					\rate, ~splr_params.rate,
					\freq, \freq.asSpec.map(val/127)
			]);
		});
	};
	~splr_control = { arg src, chan, num, val;
		// from lpd8
		if(src == lpd8.uid,{
			//("chan " ++ chan ++ " num " ++ num ++ " val " ++ val).postln;
			switch(num,
				1,{ ~splr_params.density = val/127; },
				// special case 128 steps
				2,{ ~sampleMult = [0,floor(~sampleSetsTotal/8)+1].asSpec.map(val/128).floor;
				},
				3,{ ~splr_params.rate = [0.1,1.9].asSpec.map(val/127); },
				4,{
					// bus 0 ->delay vol
					var bus = Bus.new('control',0,1,s);
					bus.set(val/127);
				},
				5,{ ~kit_params.density = val/127;},
				6,{
					// bus 3 -> kit decay
					var bus = Bus.new('control',3,1,s);
					bus.set(val/127);
				},
				7,{
					// bus 2 -> kit rate
					var bus = Bus.new('control',2,1,s);
					bus.set(val/127);
				},
				8,{
					// bus 1 ->delay speed
					var bus = Bus.new('control',1,1,s);
					bus.set(val/127);
				}
			);
		});
	};

	// clock
	~splr_clock = { arg src, val;
		if(src == a_sync_in.uid,{
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
				if(~timer.quav % ~timer.ivals[idx] == 0,{
					var idx = [~pad_counter.pad_a,~pad_counter.pad_b].choose;
					Synth.head(~splr_source,"nun_ossampler",
						[\buf_bounds, ~sampleIndexParse.value(idx),
							\out, 0,
							\rate, ~splr_params.rate,
							\freq, ~splr_params.freq
					]);
				});
			});
		});
	};

	MIDIIn.addFuncTo(\sysrt, ~splr_clock);
	MIDIIn.addFuncTo(\noteOn, ~splr_noteOn); // add
	MIDIIn.addFuncTo(\control, ~splr_control); // add

};


/**
* INIT buffers
*/
~init_buffers =
{
	Buffer.freeAll; // free all buffers

	// OS buffers
	~pathArr = ~osPath.pathMatch.sort.collect{|file|
		~sampleSetsTotal = ~sampleSetsTotal + 1;
		file.insert(file.size,"*");
	};
	~buffers = Array.fill(~pathArr.size,0);
	~pathArr.do{ |file, i|
		~buffers[i] = file.pathMatch.sort.collect{|sfile|
			Buffer.read(s,sfile);
		};
	};

	// Drum Kits
	~kitPathArr = ~kitPath.pathMatch.sort.collect{|file|
		file.insert(file.size,"*");
	};
	"size: ".post;
	~kitPathArr.size.postln;
	~kitBuffers = [];
	~kitPathArr.do{ |file, i|
		~kitBuffers = ~kitBuffers.add([]);
		file.pathMatch.sort.collect{|kfile, j|
			kfile = kfile ++ "*";
			~kitBuffers[i] = ~kitBuffers[i].add([]);
			kfile.pathMatch.sort.collect{|sfile, k|
				~kitBuffers[i][j] = ~kitBuffers[i][j].add(Buffer.read(s,sfile));
			};

		};
	};

	// drumkits inited we can do the rest:
	// create a stack of drum synths
	~dr_synths = Array.fill(8,{|i|
		Synth.head(~splr_drums,"nun_drsampler",
						[\buf_bounds, ~drumIndexParse.value(~kitCurrent,i),
						\out, 0]);
	});

	// defaut buses
	{
		var bus = Bus.new('control',0,1,s);
		bus.set(0);
		bus = Bus.new('control',1,1,s);
		bus.set(0.5);
		bus = Bus.new('control',2,1,s);
		bus.set(1);
		bus = Bus.new('control',3,1,s);
		bus.set(1);
	}
};

{
	/**
	* Delay Dub
	*/
	SynthDef(\nun_dubecho,{|in, out, length = 1, fb = 0.8, sep = 0.012|
		var vol = 1;
		var input = In.ar(in, 2);
		var feedback = LocalIn.ar(2);
		var output = LeakDC.ar(feedback*fb + input);
		output = HPF.ar(output, 400);
		output = LPF.ar(output, 5000);
		output = output.tanh;
		vol = [0.0, 1.0].asSpec.map(In.kr(0).lag(0.1));
		length = [0.0, 1.0].asSpec.map(In.kr(1).lag(0.1));
		LocalOut.ar(DelayC.ar(output*vol, 1, LFNoise2.ar(12).range([length,length+SinOsc.kr(0.1).range(0,0.012)],[length+sep,length])).reverse);
		ReplaceOut.ar(out, output);
	}).add;

	/**
	* DRUM Sampler
	*/
	// SynthDef DRUMSAMPLER
	SynthDef(\nun_drsampler, {
		arg out = 0, buf_bounds = #[0,0], decay = 5, rate = 1, freq = 20000, t_trig = 0, vol = 1;
		var sig, enva, envb,
		master_env, a, b;

		rate = [0.1, 1.9].asSpec.map(In.kr(2).lag(0.1));
		decay = [0.05, 5, \exp].asSpec.map(In.kr(3).lag(0.1));

		enva = EnvGen.ar(Env.perc(0.01, decay, 1, -4),t_trig);
		envb = EnvGen.ar(Env.perc(LFNoise2.ar(10).range(0.01,0.2), decay, 1, -4),t_trig);
		sig = 0;
		// random buffers, a is the lead
		a = buf_bounds[0];
		b = IRand(buf_bounds[0],buf_bounds[1]);

		master_env = EnvGen.ar(Env.perc(0.01,decay*1.1),t_trig);
		sig = PlayBuf.ar(2, a, BufRateScale.kr(a), rate: rate, trigger: t_trig) * enva;
		sig = sig + Resonz.ar(
			PlayBuf.ar(2, b, BufRateScale.kr(b), rate: rate, trigger: t_trig, startPos: Rand(0,50)) * envb, envb*20000 + 80);

		// master env
		sig = sig * master_env;

		// filter
		//freq = \freq.asSpec.map(In.kr(1).lag(0.1));
		sig = DFM1.ar(sig, freq, 0.5, 3);
		Out.ar(out, sig*vol);

	}).add;
	/**
	* OS Sampler
	*/
	// SynthDef OS SAMPLER
	SynthDef(\nun_ossampler, {
		arg out = 0, buf_bounds = #[0,0], decay = 5, rate = 1, freq = 20000;
		var sig, envs,
		master_env, vol = 1,
		a, b;

		//envs
		envs = Array.fill(10, { EnvGen.ar(Env.new(Array.rand(10, 0.1, 1.0).add(0.0), Array.exprand(9, 0.001, 2),curve:\welch)) });

		sig = 0;
		// random buffers, a is the lead
		a = IRand(buf_bounds[0],buf_bounds[1]);
		b = IRand(buf_bounds[0],buf_bounds[1]);

		// random magic
		master_env = EnvGen.ar(Env.perc(0.05,decay),doneAction:2);

		sig = PlayBuf.ar(2, a, BufRateScale.kr(a),rate: rate) * Select.ar(IRand(0,9),envs);
		sig = sig + Resonz.ar(
			PlayBuf.ar(2, b, BufRateScale.kr(b), rate: rate, startPos: Rand(0,50)) * Select.ar(IRand(0,9),envs),Select.ar(IRand(0,9),envs)*20000 + 80);

		// master env
		sig = sig * master_env;

		// filter
		//freq = \freq.asSpec.map(In.kr(1).lag(0.1));
		sig = DFM1.ar(sig, freq, 0.5, 3);

		Out.ar(out, sig*vol);
	}).add;

	s.sync;

	// clear clear !!
	Server.all.do(_.freeAll);
	// ROUTE
	~splr_source = Group.head(s);
	~splr_drums = Group.head(s);
	~splr_fx = Group.tail(s);

	~fx_echo = Synth.head(~splr_fx, "nun_dubecho");
	~fx_echo.set(\in, 0, \out, 0);

}.fork



// ---
)




//--- testing syndefs;
