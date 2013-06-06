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

DRUMS
******************************************************************/
(
~oDRUMS = ~oMODULE <
(
// VARS
\synths:(
	\kick: nil, //[(\name:"",\buffs:[]),(\name:"",\buffs:[])]
	\drm1: nil,
	\drm2: nil,
	\snar: nil,
	\clap: nil,
	\cymb: nil,
	\hat1: nil,
	\hat2: nil,
),
\available_kits:(
	\kick: [], //[(\name:"",\buffs:[]),(\name:"",\buffs:[])]
	\drm1: [],
	\drm2: [],
	\snar: [],
	\clap: [],
	\cymb: [],
	\hat1: [],
	\hat2: [],
),
\current_kit:(
	\kick: 0, // Ref to the object
	\drm1: 0,
	\drm2: 0,
	\snar: 0,
	\clap: 0,
	\cymb: 0,
	\hat1: 0,
	\hat2: 0,
),
// METHODS
\init: {|o, router, root_path = nil, ar_route_map = nil, kr_route_map = nil|
	var next_kr = 0;
	// id
	o.id = "drums";
	o.router = router;
	// path
	o.root_path = root_path ? "";
	if("/\\*".matchRegexp(o.root_path) !== true,{ o.root_path = o.root_path++"/*"});
	o.root_path = o.root_path.replace("//","/");
	// audio route
	o.ar_route_map = ar_route_map ? o.generate_ar();
	// control route
	o.kr_route_map = kr_route_map ? o.generate_kr();
	// functions
	o.func_route_map = o.generate_func();

	// assign to router
	o.router.assign(o);
	// add synths
	o.generate_synths();
},
\load: {|o|
	var kits_paths;
	"~oDRUMS: loading samples in buffers and create kits ...".postln;
	kits_paths = o.root_path.pathMatch.sort.collect{|file|
		(\kind:file.basename.asSymbol,\path:file.insert(file.size,"*"));
	};
	kits_paths.do({|el,i|
		var kind, kits_path;
		kind = el.kind; kits_path = el.path;
		kits_path.pathMatch.sort.collect{|file|
			var name, kit;
			name = file.basename;
			kit = (\name:name,\buffs:[]);
			file = file ++ "*";
			file.pathMatch.sort.collect{|sfile|
				kit.buffs = kit.buffs ++ Buffer.read(s,sfile);
			};
			o.available_kits[kind] = o.available_kits[kind].add(kit);
		};

	});
},
\select_kit: {|o,scope,val|
},
\set_density: {|o,scope,val|
},
\generate_synths:{|o|
	var node_group;
	node_group = o.router[\node_groups][\generators];
	// \kick
	o.synths[\kick] = Synth.head(node_group,"nun_drsampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\kick][\decay],
		\pitch_busses,o.kr_route_map[\kick][\pitch],
		\out, o.ar_route_map[\kick]
		]
	);
	// \drm1
	o.synths[\drm1] = Synth.head(node_group,"nun_drsampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\drm1][\decay],
		\pitch_busses,o.kr_route_map[\drm1][\pitch],
		\out, o.ar_route_map[\drm1]
		]
	);
	// \drm2
	o.synths[\drm2] = Synth.head(node_group,"nun_drsampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\drm2][\decay],
		\pitch_busses,o.kr_route_map[\drm2][\pitch],
		\out, o.ar_route_map[\drm2]
		]
	);
},
\generate_ar:{|o|
	(   // id : audio bus
		\kick:0,
		\drm1:1,
		\drm2:1,
		\snar:2,
		\clap:2,
		\cymb:3,
		\hat1:3,
		\hat2:3,
	);
},
\generate_kr:{|o|
	var kr_route_map = (\k:8), next_kr = 0;
	    kr_route_map =
		o.current_kit.collect{
			var route = (\pitch: next_kr);
			next_kr = next_kr + 1;
			route;
		};
		// inserting manual controls
		kr_route_map[\kick].add(\decay->8);
		kr_route_map[\drm1].add(\decay->9);
		kr_route_map[\drm2].add(\decay->9);
		kr_route_map[\snar].add(\decay->9);

		kr_route_map[\clap].add(\decay->9);
		kr_route_map[\cymb].add(\decay->10);
		kr_route_map[\hat1].add(\decay->11);
		kr_route_map[\hat2].add(\decay->11);

	    // global can be added here
		//o.kr_route_map[\global].add(\decay->12);
	// return
	kr_route_map;
},
\generate_func:{|o|
	var func_route_map = ();
	func_route_map[\global] = ().add(\density->o[\set_density]);
	func_route_map[\kick] = ().add(\kit->o[\select_kit]);
	func_route_map[\drm1] = ().add(\kit->o[\select_kit]);
	func_route_map[\drm2] = ().add(\kit->o[\select_kit]);
	func_route_map[\clap] = ().add(\kit->o[\select_kit]);
	func_route_map[\cymb] = ().add(\kit->o[\select_kit]);
	func_route_map[\hat1] = ().add(\kit->o[\select_kit]);
	func_route_map[\hat2] = ().add(\kit->o[\select_kit]);
	// return
	func_route_map;
},
//--
);
/* SynthDefs
******************************************************************/
	/**
	* DRUM Sampler
	*/
	SynthDef(\nun_drsampler, {
		arg out = 0, buf_bounds = #[0,0], decay_bus = 0, pitch_bus = 0,
		atk = 0.01, decay = 5, rate = 1, freq = 20000, t_trig = 0, vol = 1, on = 1;
		var sig, env, atkenv, rndsst, rate_mod, atksnd,
		master_env, a, b;

		rate_mod = [0.1, 1.9].asSpec.map(In.kr(pitch_bus).lag(0.1));
		rate = rate_mod * rate;
		decay = [0.03, 5, \exp].asSpec.map(In.kr(decay_bus).lag(0.1));
		env = EnvGen.ar(Env.perc(0.1, decay, 1, -4),t_trig);
		atkenv = EnvGen.ar(Env.perc(0.01, 0.02, 1, -4),t_trig);

		sig = 0;
		// random buffers, a is the lead
		a = buf_bounds[0];
		b = TRand.kr(buf_bounds[1],buf_bounds[1]+1,t_trig).floor;
		rndsst = TRand.kr(0,(BufFrames.kr(b) * 0.9).ceil, t_trig);
		master_env = EnvGen.ar(Env.perc(atk,decay*1.1),t_trig);
		atksnd = PlayBuf.ar(2, a, BufRateScale.kr(a), trigger: t_trig) * atkenv;
		sig = atksnd + PlayBuf.ar(2, a, BufRateScale.kr(a)*rate, trigger: t_trig) * env;
		sig = sig + PlayBuf.ar(2, b, BufRateScale.kr(b)*rate, trigger: t_trig, startPos: rndsst ) * env;

		// master env
		sig = sig * master_env;

		sig = LeakDC.ar(sig);
		// filter
		sig = DFM1.ar(sig, freq, 0.5, 3);
		Out.ar(out, sig*vol*on);

	}).add;
)
