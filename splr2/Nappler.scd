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
\synth_instance: nil,
\premixers:(),
\attached_fx:(),
//
\available_loops:(),
\selected_loop:"default.wav".asSymbol,
//
\rate:1,
\triggable:false,
\note_map:(
),
\selection_offset:0,
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

		// generate control map
		o.generate_control_map();

		o.on_ready(init_routine);
	}.fork;
},
\generate_ar:{|o|

	var ar_route_map = ();
	ar_route_map = (   // id : audio bus
		\global_L:0, // TRICK
		\global_R:1,
	);
	ar_route_map;
},
\generate_kr:{|o|
	var kr_route_map, next_kr = 0, name;
	kr_route_map = (\global:());
	// inserting manual controls
	kr_route_map[\global].add(\volume->0);
	kr_route_map[\global].add(\lowpass->1);
	kr_route_map[\global].add(\hipass->2);
	next_kr = 3;
	name = o.id++"_0";
	kr_route_map[name.asSymbol] = (\fx_0:next_kr,\fx_1:next_kr+1,\fx_2:next_kr+2);
	kr_route_map;
},
\generate_control_map:{|o|
	var b;

	Library.put(\control_map,\dj3,\3,\42,o.func_route_map[\global][\rate]);

	//kr

	Library.put(\control_map,\dj3,\3,\113,o.kr_route_map[\global][\volume]);
	Library.put(\control_map,\dj3,\3,\4,o.kr_route_map[\global][\lowpass]);
	Library.put(\control_map,\dj3,\3,\5,o.kr_route_map[\global][\hipass]);
	Library.put(\control_map,\dj3,\3,\6,o.kr_route_map[\nappler_0][\fx_0]);
	Library.put(\control_map,\dj3,\3,\7,o.kr_route_map[\nappler_0][\fx_2]);


	// default bus
	b = Bus.new('control',o.kr_route_map[\global][\lowpass],1,s);
	b.set(1);
	b = Bus.new('control',o.kr_route_map[\global][\hipass],1,s);
	b.set(0);


},
\generate_note:{|o|
	var note_map = ();

	note_map = note_map.add(\92->{
		o.set_loop(0);
	}); // select first pad
	note_map = note_map.add(\93->{
		o.set_loop(1);
	}); // select second pad
	note_map = note_map.add(\94->{
		o.set_loop(2);
	}); // select third pad
	note_map = note_map.add(\95->{
		o.set_loop(3);
	}); // select fouth pad

	// next and prev
	note_map = note_map.add(\74->{ o.select_prev(); });
	note_map = note_map.add(\75->{ o.select_next(); });
	// reset pitch
	//note_map = note_map.add(\0->{ o.pitch = 1; });
	//note_map = note_map.add(\1->{ o.decay = 1; });
	note_map;
},
\generate_func:{|o|
	var func_route_map = ();

	func_route_map[\global] = ().add(\rate->{|val|
		val = (val*127)/128; // I hate relative CC, bad hack here
		if(val < 0.5,{
			o.rate = (o.rate + val).clip(0,2);
		},{
			o.rate = (o.rate - (1-val)).clip(0,2);
		});
		"Nappler rate: ".post; o.rate.postln;
		o.synth_instance.set(\rate,o.rate);
	});
	// return
	func_route_map;
},
\set_preset:{|o, archive|
	var b;
	b = Bus.new('control',o.kr_route_map[\global][\volume],1,s);
	b.set(0);
	o.selected_loop = archive.selected_loop;
	o.rate = archive.rate;
	o.synth_instance.set(\rate,o.rate);
	o.synth_instance.set(\buffer,o.available_loops[o.selected_loop]);
},
\get_preset:{|o, callback|
	var archive = ();
	archive.rate = o.rate;
	archive.selected_loop = o.selected_loop;
	// will save the kits
	archive;
},
\load:{|o, on_load|
	var ct = 0, cmd;
	"~oNAPPLER: loading samples, oneshots mainly (hope) ...".postln;
	cmd = "find "++o.root_path++" -name \"*.wav\" | wc -l";
	ct = cmd.unixCmdGetStdOut.asInteger;

	o.root_path.pathMatch.sort.collect{|file|
		o.available_loops = o.available_loops.add(

			file.basename.asSymbol -> Buffer.read(s, file, action:{|b|
				ct = ct -1;
				if(ct == 0,{
					//o.available_loops[o.selected_loop].postln;
							// add synths
					o.generate_synths();
					//o.synth_instance.set(\buffer,o.available_loops[o.selected_loop]);
					on_load.value();
				});
			});

		);
		0.01.wait;
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
\select_next:{|o|
	o.selection_offset = (o.selection_offset+4).clip(0,o.available_loops.size);
	"NAPPLER, selection = ".post;
	o.selection_offset.post; " to ".post; (o.selection_offset+4).postln;
},
\select_prev:{|o|
	o.selection_offset = (o.selection_offset-4).clip(0,o.available_loops.size);
		"NAPPLER: selection = ".post;
	o.selection_offset.post; " to ".post; (o.selection_offset+4).postln;
},
\set_loop:{|o,num|
	var buf;
	buf = o.available_loops.asArray.at(o.selection_offset+num.clip(0,3));
	if(buf != nil,{
		"NAPPLER: loop ".post;
		buf.path.basename.postln;
		o.selected_loop = buf.path.basename.asSymbol;
		o.synth_instance.set(\t_fade,1);
		{
			0.5.wait;
			o.synth_instance.set(\buffer,buf);
		}.fork;
	});
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

	o.synth_instance = Synth.head(node_group,"nun_looper",[
		\vol_bus,o.kr_route_map[\global][\volume],
		\lowpass_bus, o.kr_route_map[\global][\lowpass],
		\hipass_bus, o.kr_route_map[\global][\hipass],
		\out, o.ar_route_map[\global_L],
		\buffer, o.available_loops[o.selected_loop]
	]);
},
\load_synthdefs:{|o|

	SynthDef(\nun_looper, {
		|
		rate = 1, out = 0, buffer = 0, t_fade = 0, vol_bus = 0, lowpass_bus = 0, hipass_bus = 0, rate_bus = 0
		|

		var percent, ftime = 0.13;
		var a_snd, a_aph, a_tr, a_env;
		var b_snd, b_aph, b_tr, b_env;
		var sig, fade_env;
		var vol = 1;
		var lp = 20000, hp = 200;

		lp = \freq.asSpec.map(In.kr(lowpass_bus).lag(0.1));
		hp = \freq.asSpec.map(In.kr(hipass_bus).lag(0.1));
		vol = [0,1].asSpec.map(In.kr(vol_bus).lag(0.4));

		buffer.numChannels.poll;
		// delay buffer change to trigger env beforehand

		ftime = ftime/rate;
		percent = ftime/(BufFrames.kr(buffer)/s.sampleRate)*rate;
		a_aph = Phasor.ar(0, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer));
		b_aph = Phasor.ar(0, BufRateScale.kr(buffer)*rate, 0, BufFrames.kr(buffer));
		b_aph = (b_aph+(BufFrames.kr(buffer)/2)).wrap(0,BufFrames.kr(buffer));

		a_tr = ((a_aph/BufFrames.kr(buffer))+percent).wrap(-0.00001,1);
		b_tr = ((b_aph/BufFrames.kr(buffer))+percent).wrap(-0.00001,1);
		a_env = 1-EnvGen.ar(Env.linen(ftime,0,ftime,1,1),a_tr);
		b_env = 1-EnvGen.ar(Env.linen(ftime,0,ftime,1,1),b_tr);
		fade_env = 1-EnvGen.kr(Env.pairs([[0, 0], [0.5, 1],  [1, 0]], \cub),t_fade);

		a_snd = BufRd.ar(2, buffer, a_aph) * a_env * 0.7;
		b_snd = BufRd.ar(2, buffer, b_aph) * b_env * 0.7;
		sig = (a_snd+b_snd) * fade_env;
		sig = DFM1.ar(vol*RHPF.ar(Compander.ar(sig,sig,-16.dbamp,1,1.15,0.01,0.2),hp),lp,0.5,1.02);
		Out.ar(out,sig);
	}).add;
}

);


)

