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

SHOT
******************************************************************/

(
~oSHOT = ~oMODULE <
(
// VARS
\premixers:(),
\attached_fx:(),
//
\available_kits:(),
\memory_pads:[],
\selected_kit:\default,
//
\pitch:1,
\decay:1,
\atk:0.05,
\density: 0.5,
\quant:[256,192,128,96,64,48,32,25,16,12,8,4],
\memory:false,
\ticks:0,
\quav:0,
\note_map:(
),
// METHOD
\init:{|o, router, root_path, on_ready, ar_route_map = nil, kr_route_map = nil|
	var init_routine;
	// id
	o.id = \shots; // must not be in da routine
	// path
	o.root_path = root_path ? "";
	if("/\\*".matchRegexp(o.root_path) !== true,{ o.root_path = o.root_path++"/*"});
	o.root_path = o.root_path.replace("//","/");

	// callback when ready
	o.on_ready = on_ready;
	init_routine = {
		o.router = router;
		o.load_synthdefs();
		s.sync;
		// audio route
		o.ar_route_map = ar_route_map ? o.generate_ar();
		// control route
		o.kr_route_map = kr_route_map ? o.generate_kr();
		// functions
		o.func_route_map = o.generate_func();
		// note map
		o.note_map = o.generate_note();

		// assign from router
		o.router.assign(o);
		// add synths
		o.generate_synths();
		// generate control map
		o.generate_control_map();

		o.on_ready(init_routine);
	}.fork;
},
\generate_ar:{|o|

	var ar_route_map = ();
	ar_route_map = (   // id : audio bus
		\global_L:0,
		\global_R:1,
	);
	ar_route_map;
},
\generate_kr:{|o|
	var kr_route_map, next_kr = 0, name;
	kr_route_map = (\global:());
	// inserting manual controls
	kr_route_map[\global].add(\filter->0);
	next_kr = 1;
	name = o.id++"_0";
	kr_route_map[name.asSymbol] = (\fx_0:next_kr,\fx_1:next_kr+1,\fx_2:next_kr+2);
	kr_route_map;
},
\generate_control_map:{|o|
	var b;

	Library.put(\control_map,\dj3,\3,\104,o.func_route_map[\global][\memory]);
	Library.put(\control_map,\dj3,\3,\112,o.func_route_map[\global][\density]);
	Library.put(\control_map,\dj3,\3,\32,o.func_route_map[\global][\pitch]);
	Library.put(\control_map,\dj3,\3,\33,o.func_route_map[\global][\decay]);
	Library.put(\control_map,\dj3,\3,\48,o.func_route_map[\global][\atk]);

	//kr
	Library.put(\control_map,\dj3,\3,\0,o.kr_route_map[\global][\filter]);
	Library.put(\control_map,\dj3,\3,\1,o.kr_route_map[\shots_0][\fx_0]);
	Library.put(\control_map,\dj3,\3,\2,o.kr_route_map[\shots_0][\fx_1]);


	// default bus
	b = Bus.new('control',o.kr_route_map[\global][\filter],1,s);
	b.set(1);
},
\generate_note:{|o|
	var note_map = ();

	note_map = note_map.add(\88->{
		o.trig_shot(o.selected_kit, 0, 0.3, o.pitch, o.decay, o.atk, o.memory);
	}); // select first pad
	note_map = note_map.add(\89->{
		o.trig_shot(o.selected_kit, 1, 0.3, o.pitch, o.decay, o.atk, o.memory);
	}); // select second pad
	note_map = note_map.add(\90->{
		o.trig_shot(o.selected_kit, 2, 0.3, o.pitch, o.decay, o.atk, o.memory);
	}); // select third pad
	note_map = note_map.add(\91->{
		o.trig_shot(o.selected_kit, 3, 0.3, o.pitch, o.decay, o.atk, o.memory);
	}); // select fouth pad

	// next and prev
	note_map = note_map.add(\72->{ o.select_prev_kit(); });
	note_map = note_map.add(\73->{ o.select_next_kit(); });
	// reset pitch
	note_map = note_map.add(\0->{ o.pitch = 1; });
	note_map = note_map.add(\1->{ o.decay = 1; });
	note_map;
},
\generate_func:{|o|
	var func_route_map = ();

	func_route_map[\global] = ().add(\density->{|val|
		var new_idx, old_idx;
		new_idx = o.quant[[0,o.quant.size-1].asSpec.map(val).floor];
		old_idx = o.quant[[0,o.quant.size-1].asSpec.map(o.density).floor];
		if(new_idx != old_idx, {
			"Shot density: ".post; new_idx.postln;
		});
		o.density = val;
	});

	func_route_map[\global] = func_route_map[\global].add(\memory->{|val|
		o.memory = val.asBoolean;
	});

	// relative CC
	func_route_map[\global] = func_route_map[\global].add(\pitch->{|val|
		val = (val*127)/128; // I hate relative CC, bad hack here
		if(val < 0.5,{
			o.pitch = (o.pitch + val).clip(0.1,1.9);
		},{
			o.pitch = (o.pitch - (1-val)).clip(0.1,1.9);
		});
		"Shot pitch: ".post; o.pitch.postln;
	});
	// relative CC
	func_route_map[\global] = func_route_map[\global].add(\decay->{|val|
		val = (val*127)/128;
		if(val < 0.5,{
			o.decay = (o.decay + val).clip(0.05,1);
		},{
			o.decay = (o.decay - (1-val)).clip(0.05,1);
		});
		"Shot decay: ".post; o.decay.postln;
	});
	// relative CC
	func_route_map[\global] = func_route_map[\global].add(\atk->{|val|
		val = (val*127)/128;
		if(val < 0.5,{
			o.atk = (o.atk + val).clip(0.05,1);
		},{
			o.atk = (o.atk - (1-val)).clip(0.05,1);
		});
		"Shot atk: ".post; o.atk.postln;
	});
	// return
	func_route_map;
},
\set_preset:{|o, archive|
	//o.current_kit = archive.kits;
},
\get_preset:{|o, callback|
	var archive = ();
	// will save the kits
},
\load:{|o, on_load|
	var kits_paths, ct = 0;
	"~oSHOT: loading samples, oneshots mainly (hope) ...".postln;
	//o.root_path.postln;
	// dos by dos

	kits_paths = o.root_path.pathMatch.sort.collect{|file|
		(\kind:file.basename.asSymbol,\path:file.insert(file.size,"*"));
	};
	// path inside
	kits_paths.do{|el,i|
		var kind, kits_path, kit;
		kind = el.kind; kits_path = el.path;
		kit = ();
		kits_path.pathMatch.sort.collect{|file|
			var pad_nm, pad;

			pad_nm = file.basename;
			file = file ++ "*";//.postln;

			pad = [];
			file.pathMatch.sort.collect{|sfile|
				var buff = Buffer.read(s,sfile,action:{
					ct = ct -1;
					if(ct == 0,{
						on_load.value();
						o.ready = true;
				    });
				});
				ct = ct + 1;
				pad = pad.add(buff);
			};
			kit[pad_nm.asSymbol] = pad;
		};
		o.available_kits[kind.asSymbol] = kit;
	};
},
\attach_fx:{|o, fx_module|
	var node_group, fx_size;
	fx_size = o.attached_fx.size;
	o.attached_fx = o.attached_fx.add(fx_size.asSymbol->fx_module); // increment the number of attached fx
	node_group = o.router[\node_groups][\premixers];

	{

		var next_ar = o.ar_route_map.as(Set).minItem;
		SynthDef((o.id++"_0").asSymbol, {
				var sig;
				sig = In.ar(next_ar, 1);
				// compress;
				sig =  Compander.ar(sig, sig,
					thresh: -14.dbamp,
					slopeBelow: 1,
					slopeAbove: 0.3,
					clampTime: 0.001,
					relaxTime: 0.1
				);

				// bypass signal
				Out.ar(next_ar, sig*0.73);

				o.attached_fx.collect({|el,key|
					var name = o.id++"_0";
					Out.ar(el.in_bus,
						0.73 * sig * In.kr(o.kr_route_map[name.asSymbol][(\fx ++ \_ ++ key).asSymbol]).lag(0.1)
					);
				});

		}).add;
		s.sync;

		// get the group free
		o.premixers.collect{|el,key|
			el.free;
		};

		// create the premaster synths
		o.premixers[(o.id++"_0").asSymbol] = Synth.head(node_group,o.id++"_0",[]);

	}.fork;

},
\select_next_kit:{|o|
	var index = 0;
	var ordered_keys = o.available_kits.order;
	index = ordered_keys.indexOf(o.selected_kit);
	index = (index + 1).clip(0,o.available_kits.size-1);
	o.selected_kit = ordered_keys[index];
	"selected Shot kit: ".post; o.selected_kit.postln;
},
\select_prev_kit:{|o|
	var index = 0;
	var ordered_keys = o.available_kits.order;
	index = ordered_keys.indexOf(o.selected_kit);
	index = (index - 1).clip(0,o.available_kits.size-1);
	o.selected_kit = ordered_keys[index];
	"selected Shot kit: ".post; o.selected_kit.postln;
},
\trig_shot:{|o,target_kit,idx,vol,pitch,decay,atk, memorize = false|
	var kit = o.available_kits[target_kit].asArray, buffs = [], low = 0, hi = 0;
	var node_group;

	node_group = o.router[\node_groups][\generators];
	buffs = kit.at(idx.clip(0,3));
	if(buffs != nil,{
		low = buffs[0].bufnum;
		hi = buffs[buffs.size-1].bufnum;

		Synth.head(node_group,"nun_ossampler",[
			\buf_bounds, [low,hi],
			\filter_bus, o.kr_route_map[\global][\filter],
			\out, o.ar_route_map[\global_L],
			\vol, vol,
			\rate, pitch,
			\decay, decay.curvelin,
			\atk, atk
			]
		);

		if(memorize == true,{
			var pad = (\kit:target_kit, \idx:idx, \pitch:pitch, \decay:decay, \atk: atk);
			if(o.memory_pads.size < 4,{
				o.memory_pads = o.memory_pads.add(pad);
				},{
					o.memory_pads = o.memory_pads.addFirst(pad);
					o.memory_pads.pop;
			});
			"SHOT - Memorized : ".post;
			target_kit.post; " idx: ".post;
			idx.postln;
		});
	},{
			"NO SAMPLES ON THIS SLOT".postln;
	});

},
\on_clock:{|o, val|

	if(val == 10,{
		o.ticks = 0;
	});
	if(val == 8,{
		o.ticks = o.ticks + 1;
		o.quav = o.ticks/6;
	});
	if(val == 12,{
		o.ticks = 0;
	});

	if(o.density > 0, {
		var idx = [0,o.quant.size-1].asSpec.map(o.density).floor;
		if(o.memory_pads.size > 0,{
			if((o.quav % o.quant[idx]).floor == 0,{
				var pad = o.memory_pads.choose;
				o.trig_shot(pad.kit, pad.idx, 0.2-(0.2*(o.density*0.4)), pad.pitch, pad.decay, pad.atk, false);
			},{
				var thres = o.density/200;
				var rnd = 1.0.rand;
				if(rnd < thres,{
					var pad = o.memory_pads.choose;
					o.trig_shot(pad.kit, pad.idx, 0.2-(0.2*(o.density*0.6)), pad.pitch, pad.decay, pad.atk, false);
				});
			});
		});
	});

},
\on_note:{|o, chan, num, val|
	var idx;
	idx = o.note_map[num.asSymbol];
	if(idx != nil,{
		if(idx.class.asString == "Function",{
			idx.value();
		});
	});
},
\load_synthdefs:{
	/**
	 * OS Sampler
	 */
	SynthDef(\nun_ossampler, {
		arg out = 0, buf_bounds = #[0,0], filter_bus=0,
		buf_shape = 1, vol = 0.82,
		atk = 0.05, decay = 1, drate = 1, rate = 1, freq = 20000;
		var sig, envs,
		master_env,
		a, b
		;

		//envs
		envs = Array.fill(4, {
			EnvGen.ar(Env.new(Array.rand(4, 0.1, 1.0).add(0.0), Array.exprand(3, 1, 2),curve:\welch))
		});

		sig = 0;
		// random buffers, a is the lead
		a = IRand(buf_bounds[0],buf_bounds[1]);
		b = IRand(buf_bounds[0],buf_bounds[1]);

		freq = \freq.asSpec.map(In.kr(filter_bus).lag(0.1));

		decay = BufDur.kr(a) * 0.8 * decay;
		// master env
		//master_env = EnvGen.ar(Env.adsr(atk,decay,1,decay,1,3), 1, doneAction:2);
		master_env = EnvGen.ar(Env.perc(atk,decay), doneAction:2);

		sig = PlayBuf.ar(2, a, BufRateScale.kr(a)*rate) * Select.ar(IRand(0,9),envs);
		sig = sig + PlayBuf.ar(2, b, BufRateScale.kr(b)*rate, startPos: Rand(0,50));
		/*sig = sig + Resonz.ar(
			PlayBuf.ar(2, b, BufRateScale.kr(b)*rate, startPos: Rand(0,50))
			* Select.ar(IRand(0,9),envs),Select.ar(IRand(0,9),envs)*20000 + 80);*/
		// master env
		sig = sig * master_env;

		// filter and DC
		sig = LeakDC.ar(sig);
		sig = DFM1.ar(sig, freq, 0.5, 1.1);

		Out.ar(out, sig*vol);
	}).add;
}
);

)