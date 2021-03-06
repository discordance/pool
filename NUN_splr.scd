/******************************************
* Nunja Sampling Station - Supercollider
*/
~init_buffers.value();
~init_midi.value();
~updateCorrections.value();

/**
 * 1 - housy
 * 2 - indous
 * 3 - pire house
 * 4 - chicago
 * 5 - indous
 * 6 - naz indis
 */
~set_dr_kit.value(6);

(
// ---
~mainVol = 0.5;
~mainOut = 0;
~fxBus = 16;
~compBus = 18;

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
~timer.ivals = [256,192,128,96,64,48,32,25,16,12,8,4];

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
~kitWantedPitch = 48;
~kitCorrected = false;
~kitCorrectionsArr = Dictionary.new;
~kitCorrectionsBufs = Dictionary.new;

// kit params
~kit_params = ();
~kit_params.density = 1;
~kit_params.quant = [64,48,32,24,16,12,8,6,4,3,2,1];

// utility for the sampler
~sampleIndexParse = { |index|
	var arr = [0,0];
	//"sample parse".postln;
	(~buffers[index] != nil).if({arr[0] = ~buffers[index][0].bufnum;});
	(~buffers[index] != nil).if({arr[1] = ~buffers[index][~buffers[index].size - 1].bufnum;});
	arr;
};

// updates kit corrections
~updateCorrections = {
	var num = ~kitCorrectionsBufs.size;
	~kitCorrectionsBufs.keysValuesDo{| key, value |
		value.get(0, {|msg|
			if(msg != 440,{
				~kitCorrectionsArr[key] = ~getCorrection.value(~kitWantedPitch,msg);
			},{
				~kitCorrectionsArr[key] = 1;
			});
			num = num - 1;
			if(num == 0,{
				~kitCorrected = true;
				~set_dr_kit.value(0);
			});
		});
	};
};

// algo to get the good playback rate for correction
~getCorrection = { |midpitch, targetf|
	var tones, base, adist, tone, diff;
	adist = inf;
	tone = 0;
	base = midpitch - 36;
	tones = [];
	7.do({
		tones = tones ++ base.midicps;
		base = base + 12;
	});
	// get the close octave
	tones.do({|el,i|
		if((targetf - el).abs < adist, { adist = (targetf - el).abs; tone =  el; });
	});
	diff = (tone.cpsmidi - targetf.cpsmidi);
	diff = 1/pow(2.0,(diff/12));
};

~drumIndexParse = {|kit, perc|
	var arr = [0,0];
	//~kitBuffers[kit][perc].size.postln;
	(~kitBuffers[kit][perc] != nil).if({
		if(~kitBuffers[kit][perc].size > 0,
		{
			arr[0] = ~kitBuffers[kit][perc][0].bufnum;
		});
	});
	(~kitBuffers[kit][perc] != nil).if({
		if(~kitBuffers[kit][perc].size > 0,{
			arr[1] = ~kitBuffers[kit][perc][~kitBuffers[kit][perc].size - 1].bufnum;
		});
	});
	arr;
};

~set_dr_kit = {|kit|
	~kitCurrent = kit;
	~dr_synths.do({|synth, i|
		var rate = 1, bounds = ~drumIndexParse.value(~kitCurrent,i);
		if(~kitCorrected == true, {
			rate = ~kitCorrectionsArr[bounds[0]];
		});
		synth.set(\buf_bounds, bounds);
		synth.set(\rate, rate);
	});

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

	// trigger of drum
	~trig_drum = { arg val, num;

		//num.postln;
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
				~pad_counter.pad_a = idx + (~samplePer*~sampleMult);
				},{
					~pad_counter.pad_b = idx + (~samplePer*~sampleMult);
			});
			~pad_counter.ct = ~pad_counter.ct + 1;

			// trigg sound and random delay and shape form
			~chebBuffer.sendCollection(Signal.sineFill(1000, [1, 1.0.rand, 1.0.rand, 1.0.rand]), 0);
			~fx_echo.set(\length, 1.0.rand);
			~sampleIndex = idx + (~samplePer*~sampleMult);
			Synth.head(~splr_source,"nun_ossampler",
				[\buf_bounds, ~sampleIndexParse.value(~sampleIndex),
					\out, ~fxBus,
					\rate, ~splr_params.rate,
					\decay, [8,0.5].asSpec.map(~splr_params.density),
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
					~fx_echo.set(\length, 1.0.rand);
					Synth.head(~splr_source,"nun_ossampler",
						[\buf_bounds, ~sampleIndexParse.value(idx),
							\out, ~fxBus,
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
	// BUFFER INIT --------------------------------
	Buffer.freeAll; // free all buffers
	// create the emptybuffer zero, the void buffer
	~voidBuffer = Buffer.alloc(s, 0.5 * s.sampleRate, 2);

	// buffers for waveshaping
	~chebBuffer = Buffer.alloc(s,1000,1,0);
	~chebBuffer.sendCollection(Signal.sineFill(1000, [1, 0.2, 0.7]), 0);

	// OS buffers
	~pathArr = ~osPath.pathMatch.sort({ arg a, b; a.asInt > b.asInt }).collect{|file|
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

	~kitBuffers = [];
	~kitPathArr.do{ |file, i|
		~kitBuffers = ~kitBuffers.add([]);
		~kitBuffers[i] = Array.fill(8,[]);
		file.pathMatch.sort.collect{|kfile, j|
			kfile = kfile ++ "*";
			kfile.pathMatch.sort.collect{|sfile, k|
				var buf, idx = sfile.dirname.basename;
				// analysis
				buf = Buffer.read(s,sfile,action:{|inbuf|
					if(k<1,{
						var ana_buf;
						ana_buf = Buffer.alloc(s, inbuf.numFrames / s.options.blockSize, 1, {|inanabuf|
							//inbuf.post; " ".post; inanabuf.bufnum.postln;
							~kitCorrectionsBufs.put(inbuf.bufnum, inanabuf);
							~kitCorrectionsArr.put(inbuf.bufnum, 0); // init
							{
								var snd;
								snd = PlayBuf.ar(1, inbuf, doneAction:2, loop:0);
								RecordBuf.kr(Tartini.kr(snd,k:1512).at(0), inanabuf);
							}.play;
						});
						//buf.postln;
					});
				});
				~kitBuffers[i][idx.asInt] = ~kitBuffers[i][idx.asInt] ++ buf;
			};
		};
	};

	// drumkits inited we can do the rest:
	// create a stack of drum synths
	~dr_synths = Array.fill(8,{|i|
		var bounds = ~drumIndexParse.value(~kitCurrent,i);
		Synth.head(~splr_drums,"nun_drsampler",
						[\buf_bounds, bounds,
						\out, ~compBus]);
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
	 * Leveller
	 */
	SynthDef(\nun_leveler,{|in, out, thresh = -10, preamp = 0.5, amp = 0.5|
		var output, input = In.ar(in,2)*preamp;
		output = Compander.ar( input, input, thresh.dbamp, 1, 0.3, 0.01,0.1);
		Out.ar(out,output*amp);
	}).add;

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
		LocalOut.ar(DelayC.ar(output*vol, 1, LFNoise2.ar(0.2).range([length,length+SinOsc.kr(0.1).range(0,0.012)],[length+sep,length])).reverse);
		Out.ar(out, output);
	}).add;

	/**
	 * DRUM Sampler
	 */
	SynthDef(\nun_drsampler, {
		arg out = 0, buf_bounds = #[0,0], decay = 5, rate = 1, freq = 20000, t_trig = 0, vol = 1;
		var sig, enva, rndsst, rate_mod,
		master_env, a, b;

		rate_mod = [0.1, 1.9].asSpec.map(In.kr(2).lag(0.1));
		rate = rate_mod * rate;
		decay = [0.05, 5, \exp].asSpec.map(In.kr(3).lag(0.1));
		enva = EnvGen.ar(Env.perc(0.01, decay, 1, -4),t_trig);

		sig = 0;
		// random buffers, a is the lead
		a = buf_bounds[0];
		b = TRand.kr(buf_bounds[1],buf_bounds[1]+1,t_trig).floor;
		rndsst = TRand.kr(0,(BufFrames.kr(b) * 0.9).ceil, t_trig);
		master_env = EnvGen.ar(Env.perc(0.01,decay*1.1),t_trig);
		sig = PlayBuf.ar(2, a, BufRateScale.kr(a)*rate, trigger: t_trig) * enva;
		//Pitch.kr(sig).poll;
		sig = sig + PlayBuf.ar(2, b, BufRateScale.kr(b)*rate, trigger: t_trig, startPos: rndsst ) * enva;

		// master env
		sig = sig * master_env;

		sig = LeakDC.ar(sig);
		// filter
		sig = DFM1.ar(sig, freq, 0.5, 3);
		Out.ar(out, sig*vol);

	}).add;

	/**
	 * OS Sampler
	 */
	SynthDef(\nun_ossampler, {
		arg out = 0, buf_bounds = #[0,0], buf_shape = 1, decay = 5, rate = 1, freq = 20000;
		var sig, envs,
		master_env, vol = 1,
		a, b,
		// wave shape test
		ws_index
		;

		//envs
		envs = Array.fill(10, { EnvGen.ar(Env.new(Array.rand(10, 0.1, 1.0).add(0.0), Array.exprand(9, 0.001, 2),curve:\welch)) });

		sig = 0;
		// random buffers, a is the lead
		a = IRand(buf_bounds[0],buf_bounds[1]);
		b = IRand(buf_bounds[0],buf_bounds[1]);

		// random magic
		master_env = EnvGen.ar(Env.perc(0.05,decay),doneAction:2);

		sig = PlayBuf.ar(2, a, BufRateScale.kr(a)*rate) * Select.ar(IRand(0,9),envs);
		sig = sig + Resonz.ar(
			PlayBuf.ar(2, b, BufRateScale.kr(b)*rate, startPos: Rand(0,50)) * Select.ar(IRand(0,9),envs),Select.ar(IRand(0,9),envs)*20000 + 80);

		// master env
		sig = sig * master_env;

		// waveshape
		ws_index = LinLin.ar(sig, -1.0, 1.0, 0.0, BufFrames.kr(buf_shape));
		sig = BufRd.ar(1, buf_shape, ws_index, 0, 4);

		// filter and DC
		sig = LeakDC.ar(sig);
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
	~fx_echo.set(\in, ~fxBus, \out, ~compBus);
	~fx_comp = Synth.tail(~splr_fx, "nun_leveler");
	~fx_comp.set(\in, ~compBus, \out, ~mainOut, \amp, ~mainVol);

}.fork



// ---
)

~mainVol = 0.27;
~fx_comp.set(\amp,~mainVol);