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
\available_kits:(),
\memory_pads:[],
\selected_kit:\default,
\pitch:1,
\density: 0.5,
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
	var kr_route_map, next_kr = 0;
	kr_route_map = (\global:());
	// inserting manual controls
	kr_route_map[\global].add(\decay->0);
	kr_route_map[\global].add(\attack->1);
	kr_route_map[\global].add(\pitch->2);
	kr_route_map;
},
\generate_control_map:{|o|
	var b;
	// default bus
	b = Bus.new('control',o.kr_route_map[\global][\decay],1,s);
	b.set(1);
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
\select_next_kit:{|o|
},
\select_prev_kit:{|o|
},
\trig_shot:{|o,idx|
	var kit = o.available_kits[o.selected_kit].asArray, buffs = [], low = 0, hi = 0;
	var node_group;
	node_group = o.router[\node_groups][\generators];
	buffs = kit.at(idx.clip(0,3));
	low = buffs[0].bufnum;
	hi = buffs[buffs.size-1].bufnum;

	Synth.head(node_group,"nun_ossampler",[
		\buf_bounds, [low,hi],
		\decay_bus, o.kr_route_map[\global][\decay],
		\atk_bus,o.kr_route_map[\global][\attack],
		\out, o.ar_route_map[\global_L],
		\vol, 0.82,
		\rate, o.pitch,
		\freq, 20000
		]
	);

},
\load_synthdefs:{
	/**
	 * OS Sampler
	 */
	SynthDef(\nun_ossampler, {
		arg out = 0, buf_bounds = #[0,0], decay_bus=0, atk_bus=0,
		buf_shape = 1, vol = 0.82,
		atk = 0.05, decay = 5, drate = 1, rate = 1, freq = 20000;
		var sig, envs,
		master_env,
		a, b
		;

		//envs
		envs = Array.fill(10, {
			EnvGen.ar(Env.new(Array.rand(4, 0.1, 1.0).add(0.0), Array.exprand(3, 1, 2),curve:\welch))
		});

		sig = 0;
		// random buffers, a is the lead
		a = IRand(buf_bounds[0],buf_bounds[1]);
		b = IRand(buf_bounds[0],buf_bounds[1]);

		drate = [0.0, 1.0].asSpec.map(In.kr(decay_bus).lag(0.1));
		atk = [0.05, 1.0].asSpec.map(In.kr(atk_bus).lag(0.1));

		decay = BufDur.kr(a) * 0.8 * drate;
		// master env
		master_env = EnvGen.ar(Env.adsr(atk,decay,1,0.3,1,3), Line.kr(1,-1,decay*1.2), doneAction:2);

		sig = PlayBuf.ar(2, a, BufRateScale.kr(a)*rate) * Select.ar(IRand(0,9),envs);
		sig = sig + Resonz.ar(
			PlayBuf.ar(2, b, BufRateScale.kr(b)*rate, startPos: Rand(0,50))
			* Select.ar(IRand(0,9),envs),Select.ar(IRand(0,9),envs)*20000 + 80);
		// master env
		sig = sig * master_env;

		// filter and DC
		sig = LeakDC.ar(sig);
		sig = DFM1.ar(sig, freq, 0.5, 3);

		Out.ar(out, sig*vol);
	}).add;
}
);

)