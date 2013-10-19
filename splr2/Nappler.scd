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

NAPPLER
******************************************************************/
(


~oNAPPLER = ~oMODULE <
(
// VARS
\premixers:(),
\attached_fx:(),
//
\available_loops:(),
\selected_loop:\default,
//
\pitch:1,
\triggable:false,
\note_map:(
),
// METHOD
\init:{|o, router, root_path, on_ready, ar_route_map = nil, kr_route_map = nil|
	var init_routine;
	// id
	o.id = \nappler; // must not be in da routine

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
		\global_L:-2, // TRICK
		\global_R:-1,
	);
	ar_route_map;
},
\generate_kr:{|o|
	var kr_route_map, next_kr = 0, name;
	kr_route_map = (\global:());
	// inserting manual controls
	kr_route_map[\global].add(\volume->0);
	kr_route_map[\global].add(\pitch->1);
	kr_route_map[\global].add(\lowpass->2);
	kr_route_map[\global].add(\highpass->3);
	next_kr = 4;
	name = o.id++"_0";
	kr_route_map[name.asSymbol] = (\fx_0:next_kr,\fx_1:next_kr+1);
	kr_route_map;
},
\generate_control_map:{|o|
	var b;
	/*
	Library.put(\control_map,\dj3,\3,\104,o.func_route_map[\global][\memory]);
	Library.put(\control_map,\dj3,\3,\112,o.func_route_map[\global][\density]);
	Library.put(\control_map,\dj3,\3,\32,o.func_route_map[\global][\pitch]);
	Library.put(\control_map,\dj3,\3,\33,o.func_route_map[\global][\decay]);
	Library.put(\control_map,\dj3,\3,\48,o.func_route_map[\global][\atk]);

	//kr
	Library.put(\control_map,\dj3,\3,\0,o.kr_route_map[\global][\filter]);
	Library.put(\control_map,\dj3,\3,\1,o.kr_route_map[\shots_0][\fx_0]);
	Library.put(\control_map,\dj3,\3,\2,o.kr_route_map[\shots_0][\fx_1]);
	Library.put(\control_map,\dj3,\3,\3,o.kr_route_map[\shots_0][\fx_2]);


	// default bus
	b = Bus.new('control',o.kr_route_map[\global][\filter],1,s);
	b.set(1);
	*/
},
\generate_note:{|o|
	var note_map = ();

	note_map = note_map.add(\88->{
		//o.trig_shot(o.selected_kit, 0, 0.25, o.pitch, o.decay, o.atk, o.memory);
	}); // select first pad
	note_map = note_map.add(\89->{
		//o.trig_shot(o.selected_kit, 1, 0.25, o.pitch, o.decay, o.atk, o.memory);
	}); // select second pad
	note_map = note_map.add(\90->{
		//o.trig_shot(o.selected_kit, 2, 0.25, o.pitch, o.decay, o.atk, o.memory);
	}); // select third pad
	note_map = note_map.add(\91->{
		//o.trig_shot(o.selected_kit, 3, 0.25, o.pitch, o.decay, o.atk, o.memory);
	}); // select fouth pad

	// next and prev
	//note_map = note_map.add(\72->{ o.select_prev_kit(); });
	//note_map = note_map.add(\73->{ o.select_next_kit(); });
	// reset pitch
	//note_map = note_map.add(\0->{ o.pitch = 1; });
	//note_map = note_map.add(\1->{ o.decay = 1; });
	note_map;
},
\generate_func:{|o|
	var func_route_map = ();
	// return
	func_route_map;
},
\set_preset:{|o, archive|

},
\get_preset:{|o, callback|
	var archive = ();
	// will save the kits
	archive;
},
\load:{|o, on_load|
	var ct = 0;
	"~oNAPPLER: loading samples, oneshots mainly (hope) ...".postln;
	o.root_path.pathMatch.sort.collect{|file|
		o.available_loops = o.available_loops.add(
			file.basename.asSymbol -> Buffer.read(s, file, action:{|b|

				ct = ct -1;
				"nappler loading: ".post;
				ct.postln;
				if(ct == 0,{
					on_load.value();
				});
			});
		);
		ct = ct + 1;
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
\select_next_block:{|o|
	/*
	var index = 0;
	var ordered_keys = o.available_kits.order;
	index = ordered_keys.indexOf(o.selected_kit);
	index = (index + 1).clip(0,o.available_kits.size-1);
	o.selected_kit = ordered_keys[index];
	"selected Shot kit: ".post; o.selected_kit.postln;
	*/
},
\select_prev_block:{|o|
	/*
	var index = 0;
	var ordered_keys = o.available_kits.order;
	index = ordered_keys.indexOf(o.selected_kit);
	index = (index - 1).clip(0,o.available_kits.size-1);
	o.selected_kit = ordered_keys[index];
	"selected Shot kit: ".post; o.selected_kit.postln;
	*/
},
\set_loop:{|o,name|
	/*
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
			if(o.memory_pads.size < 8,{
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
	*/
},
\on_clock:{|o, val|

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
\generate_synths:{|o|
	var node_group;
	node_group = o.router[\node_groups][\generators];
},
\load_synthdefs:{|o|

	SynthDef(\nun_looper, {|out = 0, buffer = 0, t_fade = 0|
		var percent, ftime = 0.13;
		var a_snd, a_aph, a_tr, a_env;
		var b_snd, b_aph, b_tr, b_env;
		var sig, fade_env;
		var rate = 1;

		rate = MouseX.kr(0,2);
		buffer = buffer.lag(0.01); // delay buffer change to trigger env beforehand
		ftime = ftime/rate;
		percent = ftime/(BufFrames.kr(buffer)/s.sampleRate)*rate;
		a_aph = Phasor.ar(0, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer));
		b_aph = Phasor.ar(0, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer));
		b_aph = (b_aph+(BufFrames.kr(buffer)/2)).wrap(0,BufFrames.kr(buffer));

		a_tr = ((a_aph/BufFrames.kr(buffer))+percent).wrap(-0.00001,1);
		b_tr = ((b_aph/BufFrames.kr(buffer))+percent).wrap(-0.00001,1);
		a_env = 1-EnvGen.ar(Env.linen(ftime,0,ftime,1,1),a_tr);
		b_env = 1-EnvGen.ar(Env.linen(ftime,0,ftime,1,1),b_tr);
		fade_env = 1-EnvGen.kr(Env.linen(0,0,0.5,1,1),t_fade);

		a_snd = BufRd.ar(2, buffer, a_aph) * a_env * 0.7;
		b_snd = BufRd.ar(2, buffer, b_aph) * b_env * 0.7;
		sig = (a_snd+b_snd) * fade_env;
		Out.ar(0,HPF.ar(Compander.ar(sig,sig,-16.dbamp,1,1.15,0.01,0.2),200));
	}).add;
}

);


)