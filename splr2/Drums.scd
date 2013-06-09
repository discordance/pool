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
\density:1.0,
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
\note_map:(
	\36: \kick, // Ref to the object
	\41: \drm1,
	\43: \drm2,
	\38: \snar,
	\39: \clap,
	\42: \cymb,
	\44: \hat1,
	\46: \hat2,
),
// METHODS
\init: {|o, router, root_path, on_ready, ar_route_map = nil, kr_route_map = nil|
	var init_routine;
	// callback when ready
	o.on_ready = on_ready;
	init_routine = {
		// id
		o.id = "drums";
		o.router = router;
		o.load_synthdefs();
		s.sync;
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

		// assign from router
		o.router.assign(o);
		// add synths
		o.generate_synths();

		// generate control map
		o.generate_control_map();

		o.on_ready(init_routine);
	}.fork;
},
\load: {|o, on_load|

	var kits_paths, ct = 0;
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
				var buff = Buffer.read(s,sfile);
				ct = ct + 1;
				kit.buffs = kit.buffs ++ buff;
				// to mono
				//on_load.value();
				//o.ready = true;

				buff.loadToFloatArray(action: { arg array;
					a = array;
					buff = Buffer.loadCollection(s, a.unlace(2).sum*0.5, action:{
						ct = ct -1;
						if(ct == 0,{
							on_load.value();
							o.ready = true;
						});
					});
				});
			};
			o.available_kits[kind] = o.available_kits[kind].add(kit);
		};

	});
},
\get_bounds_from_kit:{|o,scope,val|
	var arr = [0,0];
	if(o.available_kits[scope][val] !== nil,{
		var end = o.available_kits[scope][val].buffs.size -1;
		arr[0] = o.available_kits[scope][val].buffs[0].bufnum;
		arr[1] = o.available_kits[scope][val].buffs[end].bufnum;
	});
	arr;
},
\select_kit: {|o,scope,val|
	var total = 0;
	// determine numbers ofkits
	total = o.available_kits[scope].size;
	// map
	o.current_kit[scope] = [0,total].asSpec.map(val).floor;
},
\set_density: {|o,scope,val|
},
\trig_drum:{|o,num,val|
	var symb = o.note_map[num.asSymbol];
	o.synths[symb].set(\buf_bounds,o.get_bounds_from_kit(symb,o.current_kit[symb]));
	o.synths[symb].set(\t_trig,1);
	o.synths[symb].set(\vol,val/127);
	o.synths[symb].set(\freq,\freq.asSpec.map(val/127));
},
\on_note:{|o, chan, num, val|
	if(o.ready == true,{
		o.trig_drum(num,val);
	});
},
\on_clock:{|o, val|
	if(o.ready == true,{

	});
},
\generate_synths:{|o|
	var node_group;
	node_group = o.router[\node_groups][\generators];
	// \kick
	o.synths[\kick] = Synth.head(node_group,"nun_basic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\kick][\decay],
		\pitch_busses,o.kr_route_map[\kick][\pitch],
		\out, o.ar_route_map[\kick]
		]
	);
	// \drm1
	o.synths[\drm1] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\drm1][\decay],
		\pitch_busses,o.kr_route_map[\drm1][\pitch],
		\out, o.ar_route_map[\drm1]
		]
	);
	// \drm2
	o.synths[\drm2] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\drm2][\decay],
		\pitch_busses,o.kr_route_map[\drm2][\pitch],
		\out, o.ar_route_map[\drm2]
		]
	);
	// \snar
	o.synths[\snar] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\snar][\decay],
		\pitch_busses,o.kr_route_map[\snar][\pitch],
		\out, o.ar_route_map[\snar]
		]
	);
	// \clap
	o.synths[\clap] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\clap][\decay],
		\pitch_busses,o.kr_route_map[\clap][\pitch],
		\out, o.ar_route_map[\clap]
		]
	);
	// \cymb
	o.synths[\cymb] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\cymb][\decay],
		\pitch_busses,o.kr_route_map[\cymb][\pitch],
		\out, o.ar_route_map[\cymb]
		]
	);
	// \hh1
	o.synths[\hat1] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\hat1][\decay],
		\pitch_busses,o.kr_route_map[\hat1][\pitch],
		\out, o.ar_route_map[\hat1]
		]
	);
	// \hh2
	o.synths[\hat2] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\hat2][\decay],
		\pitch_busses,o.kr_route_map[\hat2][\pitch],
		\out, o.ar_route_map[\hat2]
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
	func_route_map[\snar] = ().add(\kit->o[\select_kit]);
	func_route_map[\clap] = ().add(\kit->o[\select_kit]);
	func_route_map[\cymb] = ().add(\kit->o[\select_kit]);
	func_route_map[\hat1] = ().add(\kit->o[\select_kit]);
	func_route_map[\hat2] = ().add(\kit->o[\select_kit]);
	// return
	func_route_map;
},
\generate_control_map:{|o|
	var b;
	// DEN AND DEC AND FX
	Library.put(\control_map,\motu,\3,\0,(\func:o.func_route_map[\global][\density],\scope:\global));
	Library.put(\control_map,\motu,\3,\1,o.kr_route_map[\drm1][\decay]);
	Library.put(\control_map,\motu,\3,\2,o.kr_route_map[\cymb][\decay]);
	Library.put(\control_map,\motu,\3,\3,o.kr_route_map[\hat1][\decay]);
	// PITCHES
	Library.put(\control_map,\motu,\3,\16,o.kr_route_map[\kick][\pitch]);
	Library.put(\control_map,\motu,\3,\17,o.kr_route_map[\drm1][\pitch]);
	Library.put(\control_map,\motu,\3,\18,o.kr_route_map[\drm2][\pitch]);
	Library.put(\control_map,\motu,\3,\19,o.kr_route_map[\snar][\pitch]);
	Library.put(\control_map,\motu,\3,\20,o.kr_route_map[\clap][\pitch]);
	Library.put(\control_map,\motu,\3,\21,o.kr_route_map[\cymb][\pitch]);
	Library.put(\control_map,\motu,\3,\22,o.kr_route_map[\hat1][\pitch]);
	Library.put(\control_map,\motu,\3,\23,o.kr_route_map[\hat2][\pitch]);
	// KIT SELECTION
	Library.put(\control_map,\motu,\3,\24,(\func:o.func_route_map[\kick][\kit],\scope:\kick));
	Library.put(\control_map,\motu,\3,\25,(\func:o.func_route_map[\drm1][\kit],\scope:\drm1));
	Library.put(\control_map,\motu,\3,\26,(\func:o.func_route_map[\drm2][\kit],\scope:\drm2));
	Library.put(\control_map,\motu,\3,\27,(\func:o.func_route_map[\snar][\kit],\scope:\snar));
	Library.put(\control_map,\motu,\3,\28,(\func:o.func_route_map[\clap][\kit],\scope:\clap));
	Library.put(\control_map,\motu,\3,\29,(\func:o.func_route_map[\cymb][\kit],\scope:\cymb));
	Library.put(\control_map,\motu,\3,\30,(\func:o.func_route_map[\hat1][\kit],\scope:\hat1));
	Library.put(\control_map,\motu,\3,\31,(\func:o.func_route_map[\hat2][\kit],\scope:\hat2));

	// default bus
	b = Bus.new('control',o.kr_route_map[\kick][\decay],1,s);
	b.set(1);

},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|
	/**
	* DRUM Sampler
	*/
	SynthDef(\nun_organic_sampler, {
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
		atksnd = PlayBuf.ar(1, a, BufRateScale.kr(a), trigger: t_trig) * atkenv;
		sig = atksnd + PlayBuf.ar(1, a, BufRateScale.kr(a)*rate, trigger: t_trig) * env;
		sig = sig + PlayBuf.ar(1, b, BufRateScale.kr(b)*rate, trigger: t_trig, startPos: rndsst ) * env;

		// master env
		sig = sig * master_env;

		sig = LeakDC.ar(sig);
		// filter
		sig = DFM1.ar(sig, freq, 0.5, 3);
		Out.ar(out, sig*vol*on);

	}).add;

	SynthDef(\nun_basic_sampler, {
		arg out = 0, buf_bounds = #[0,0], decay_bus = 0, pitch_bus = 0,
		atk = 0.01, decay = 5, rate = 1, freq = 20000, t_trig = 0, vol = 1, on = 1;
		var sig, env;
		decay = [0.03, 5, \exp].asSpec.map(In.kr(decay_bus).lag(0.1));
		env = EnvGen.ar(Env.perc(0.01, decay, 1, -4),t_trig);
		a = buf_bounds[0];
		sig = PlayBuf.ar(1, a, BufRateScale.kr(a)*rate, trigger: t_trig) * env;
		sig = DFM1.ar(sig, freq, 0.5, 1);
		Out.ar(out, sig*vol*on);
	}).add;
}
//--
);
)
