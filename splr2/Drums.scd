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

@TODO -> available_kits are array, not good for preset as it can change while kits are upgraded
      -> change it to objects, yeah dude, though, not urgent
DRUMS
******************************************************************/
(
~oDRUMS = ~oMODULE <
(
// VARS
\ticks:0,
\quav:0,
\quant: [64,48,32,24,16,12,8,6,4,3,2,1],
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
	\kick: (), //[(\name:"",\buffs:[]),(\name:"",\buffs:[])]
	\drm1: (),
	\drm2: (),
	\snar: (),
	\clap: (),
	\cymb: (),
	\hat1: (),
	\hat2: (),
),
\current_kit:(
	\kick: \default, // Ref to the object
	\drm1: \default,
	\drm2: \default,
	\snar: \default,
	\clap: \default,
	\cymb: \default,
	\hat1: \default,
	\hat2: \default,
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
	// id
	o.id = \drums; // must not be in da routine
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
		o.ar_route_map = o.generate_ar();
		// control route
		o.kr_route_map = o.generate_kr();
		// functions
		o.func_route_map = o.generate_func();
		// assign from router
		o.router.assign(o);
		// add synths
		o.generate_synths();
		// generate control map
		o.generate_control_map();
		//
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
			//kit = (\name:name,\buffs:[]);
			kit = [];
			file = file ++ "*";
			file.pathMatch.sort.collect{|sfile|
				var buff = Buffer.read(s,sfile,action:{
					ct = ct -1;
						if(ct == 0,{
							on_load.value();
							o.ready = true;
						});
				});
				ct = ct + 1;
				kit = kit.add(buff);
				// to mono
				//on_load.value();
				//o.ready = true;
				/*
				buff.loadToFloatArray(action: { arg array;
					a = array;
					buff = Buffer.loadCollection(s, a.unlace(2).sum*0.5, action:{
						ct = ct -1;
						if(ct == 0,{
							on_load.value();
							o.ready = true;
						});
					});
				});*/
			};
			o.available_kits[kind] = o.available_kits[kind].add(name.asSymbol -> kit);
		};

	});
},
\attach_fx:{|o, fx_module|

	var node_group, fx_size;
	fx_size = o.attached_fx.size;
	o.attached_fx = o.attached_fx.add(fx_size.asSymbol->fx_module); // increment the number of attached fx

	node_group = o.router[\node_groups][\premixers];

	{
		var num_channels = o.ar_route_map.as(Set).size;
		var next_ar = o.ar_route_map.as(Set).minItem;
		num_channels.do({|el,i|
			var name = o.id++"_"++i.asString;

			SynthDef(name.asSymbol, {
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
					var name = o.id++"_"++i.asString;

					Out.ar(el.in_bus,
						0.73 * sig * In.kr(o.kr_route_map[name.asSymbol][(\fx ++ \_ ++ key).asSymbol]).lag(0.1)
					);
				});

			}).add;

			next_ar = next_ar + 1;
		});
		s.sync;

		// get the group free
		o.premixers.collect{|el,key|
			el.free;
		};

		// create the premaster synths
		num_channels.do({|el,i|
			o.premixers[(o.id++"_"++i.asString).asSymbol]
			= Synth.head(node_group,o.id++"_"++i.asString,[]);
		});

	}.fork;
},
\get_bounds_from_kit:{|o,scope,val|
	var arr = [0,0];
	if(o.available_kits[scope][val] !== nil,{
		var end = o.available_kits[scope][val].size -1;
		arr[0] = o.available_kits[scope][val][0].bufnum;
		arr[1] = o.available_kits[scope][val][end].bufnum;
	});
	arr;
},
\select_kit: {|o,scope,val|
	var total = 0, keys;
	// determine numbers ofkits
	total = o.available_kits[scope].size;
	keys = o.available_kits[scope].keys.asArray;
	// map
	o.current_kit[scope] = keys[[0,total-1].asSpec.map(val).floor];
	"DRUM ".post;
	scope.post;
	" IS ".post;
	o.current_kit[scope].postln;
},
\set_density: {|o,scope,val|
	o.density = val;
},
\trig_drum:{|o,num,val|
	var freq;
	var symb = o.note_map[num.asSymbol];
	o.synths[symb].set(\buf_bounds,o.get_bounds_from_kit(symb,o.current_kit[symb]));
	o.synths[symb].set(\t_trig,1);
	o.synths[symb].set(\vol,val/127);
	freq = \freq.asSpec.map((val/127).lincurve);
	o.synths[symb].set(\freq,freq);
},
\on_note:{|o, chan, num, val|
	if(o.ready == true,{
		if(o.note_map[num.asSymbol] == \kick,{
			o.trig_drum(num,val); // trigg kick any case
		},{
			if(o.density > 0,{
				var quant;
				quant = o.quant[[0,o.quant.size-1].asSpec.map(o.density)];
				if((o.quav % quant).floor == 0, {
					o.trig_drum(num,val);
				},{
					var thres = o.density/2;
					if(1.0.rand < thres,{
						o.trig_drum(num,val);
					});
				});
			});
		});
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
},
\set_preset:{|o, archive|
	o.current_kit = archive.kits;
},
\get_preset:{|o, callback|
	var archive = ();
	// will save the kits
	archive.kits = o.current_kit;
	// what extra to save here ?
	// nothing so return archive
	archive;
},
\generate_synths:{|o|
	var node_group;
	node_group = o.router[\node_groups][\generators];
	// \kick
	o.synths[\kick] = Synth.head(node_group,"nun_basic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\kick][\decay],
		\pitch_bus,o.kr_route_map[\kick][\pitch],
		\out, o.ar_route_map[\kick], \vol, 1

		]
	);
	// \drm1
	o.synths[\drm1] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\drm1][\decay],
		\pitch_bus,o.kr_route_map[\drm1][\pitch],
		\out, o.ar_route_map[\drm1],
		\lowcut, 60, \vol, 0.92
		]
	);
	// \drm2
	o.synths[\drm2] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\drm2][\decay],
		\pitch_bus,o.kr_route_map[\drm2][\pitch],
		\out, o.ar_route_map[\drm2],
		\lowcut, 70, \vol, 0.92
		]
	);
	// \snar
	o.synths[\snar] = Synth.head(node_group,"nun_basic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\snar][\decay],
		\pitch_bus,o.kr_route_map[\snar][\pitch],
		\out, o.ar_route_map[\snar],
		\lowcut, 70, \vol, 0.85
		]
	);
	// \clap
	o.synths[\clap] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\clap][\decay],
		\pitch_bus,o.kr_route_map[\clap][\pitch],
		\out, o.ar_route_map[\clap],
		\lowcut, 80, \vol, 0.80
		]
	);
	// \cymb
	o.synths[\cymb] = Synth.head(node_group,"nun_basic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\cymb][\decay],
		\pitch_bus,o.kr_route_map[\cymb][\pitch],
		\out, o.ar_route_map[\cymb],
		\lowcut, 120, \vol, 0.85
		]
	);
	// \hh1
	o.synths[\hat1] = Synth.head(node_group,"nun_organic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\hat1][\decay],
		\pitch_bus,o.kr_route_map[\hat1][\pitch],
		\out, o.ar_route_map[\hat1],
		\lowcut, 120, \vol, 0.75
		]
	);
	// \hh2
	o.synths[\hat2] = Synth.head(node_group,"nun_basic_sampler",[
		\buf_bounds, [0,0],
		\decay_bus, o.kr_route_map[\hat2][\decay],
		\pitch_bus,o.kr_route_map[\hat2][\pitch],
		\out, o.ar_route_map[\hat2],
		\lowcut, 120, \vol, 0.60
		]
	);
},
\generate_ar:{|o|
	var ar_route_map = ();
	ar_route_map = (   // id : audio bus
		\kick:0,
		\drm1:1,
		\drm2:1,
		\snar:2,
		\clap:2,
		\cymb:3,
		\hat1:3,
		\hat2:3,
	);
	ar_route_map;
},
\generate_kr:{|o|
	var kr_route_map, next_kr = 0;
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
	kr_route_map[\snar].add(\decay->10);

	kr_route_map[\clap].add(\decay->10);
	kr_route_map[\cymb].add(\decay->11);
	kr_route_map[\hat1].add(\decay->12);
	kr_route_map[\hat2].add(\decay->12);



	next_kr = 13;

	o.current_kit.collect{|el,key|
		kr_route_map[key].add(\volume->next_kr);
		next_kr = next_kr + 1;
	};

	//
	// premix and FX busses
	// how many premixers
	{
		var num_channels = o.ar_route_map.as(Set).size;
		num_channels.do({|el,i|
			var name = o.id++"_"++i.asString;
			kr_route_map[name.asSymbol] = (\fx_0:next_kr,\fx_1:next_kr+1,\fx_2:next_kr+2);
			next_kr = next_kr + 3;
		});
	}.value;

	// global can be added here
	// return
	kr_route_map;
},
\generate_func:{|o|
	var func_route_map = ();
	func_route_map[\global] = ().add(\density->{|val| o.set_density(\global,val)});
	func_route_map[\kick] = ().add(\kit->{|val| o.select_kit(\kick,val)});
	func_route_map[\drm1] = ().add(\kit->{|val| o.select_kit(\drm1,val)});
	func_route_map[\drm2] = ().add(\kit->{|val| o.select_kit(\drm2,val)});
	func_route_map[\snar] = ().add(\kit->{|val| o.select_kit(\snar,val)});
	func_route_map[\clap] = ().add(\kit->{|val| o.select_kit(\clap,val)});
	func_route_map[\cymb] = ().add(\kit->{|val| o.select_kit(\cymb,val)});
	func_route_map[\hat1] = ().add(\kit->{|val| o.select_kit(\hat1,val)});
	func_route_map[\hat2] = ().add(\kit->{|val| o.select_kit(\hat2,val)});
	// return
	func_route_map;
},
\generate_control_map:{|o|
	var b;
	// DEN AND DEC AND FX
	Library.put(\control_map,\motu,\3,\0,o.func_route_map[\global][\density]);
	// 123 for delays

	Library.put(\control_map,\motu,\3,\4,o.kr_route_map[\drm1][\decay]);
	Library.put(\control_map,\motu,\3,\5,o.kr_route_map[\snar][\decay]);
	Library.put(\control_map,\motu,\3,\6,o.kr_route_map[\cymb][\decay]);
	Library.put(\control_map,\motu,\3,\7,o.kr_route_map[\hat1][\decay]);

	//VERBS
	Library.put(\control_map,\motu,\3,\8,o.kr_route_map[\drums_0][\fx_0]);
	Library.put(\control_map,\motu,\3,\9,o.kr_route_map[\drums_1][\fx_0]);
	Library.put(\control_map,\motu,\3,\10,o.kr_route_map[\drums_2][\fx_0]);
	Library.put(\control_map,\motu,\3,\11,o.kr_route_map[\drums_3][\fx_0]);

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
	Library.put(\control_map,\motu,\3,\24,o.func_route_map[\kick][\kit]);
	Library.put(\control_map,\motu,\3,\25,o.func_route_map[\drm1][\kit]);
	Library.put(\control_map,\motu,\3,\26,o.func_route_map[\drm2][\kit]);
	Library.put(\control_map,\motu,\3,\27,o.func_route_map[\snar][\kit]);
	Library.put(\control_map,\motu,\3,\28,o.func_route_map[\clap][\kit]);
	Library.put(\control_map,\motu,\3,\29,o.func_route_map[\cymb][\kit]);
	Library.put(\control_map,\motu,\3,\30,o.func_route_map[\hat1][\kit]);
	Library.put(\control_map,\motu,\3,\31,o.func_route_map[\hat2][\kit]);
	// VOLUME
	Library.put(\control_map,\motu,\3,\32,o.kr_route_map[\kick][\volume]);
	Library.put(\control_map,\motu,\3,\33,o.kr_route_map[\drm1][\volume]);
	Library.put(\control_map,\motu,\3,\34,o.kr_route_map[\drm2][\volume]);
	Library.put(\control_map,\motu,\3,\35,o.kr_route_map[\snar][\volume]);
	Library.put(\control_map,\motu,\3,\36,o.kr_route_map[\clap][\volume]);
	Library.put(\control_map,\motu,\3,\37,o.kr_route_map[\cymb][\volume]);
	Library.put(\control_map,\motu,\3,\38,o.kr_route_map[\hat1][\volume]);
	Library.put(\control_map,\motu,\3,\39,o.kr_route_map[\hat2][\volume]);
	// FX

	// default bus
	b = Bus.new('control',o.kr_route_map[\kick][\decay],1,s);
	b.set(1);
	// all pitchs and volumes to 1
	o.kr_route_map.collect{|el,key|
		if(o.kr_route_map[key][\pitch] != nil,{
			b = Bus.new('control', o.kr_route_map[key][\pitch],1,s);
			b.set(0.7);
		});
		if(o.kr_route_map[key][\volume] != nil,{
			b = Bus.new('control', o.kr_route_map[key][\volume],1,s);
			b.set(1);
		});
	};

},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|
	/**
	* DRUM Sampler
	*/
	SynthDef(\nun_organic_sampler, {
		arg out = 0, buf_bounds = #[0,0], decay_bus = 0, pitch_bus = 0,
		atk = 0.01, decay = 5, rate = 1, freq = 20000, t_trig = 0, vol = 1, on = 1, lowcut = 0;
		var sig, env, atkenv, rndsst, rate_mod, atksnd,
		master_env, a, b, attenuation_ratio; // decay attenuation

		rate_mod = [0.1, 1.9].asSpec.map(In.kr(pitch_bus).lag(0.1));
		rate = rate_mod * rate;
		decay = [0.03, 5, \exp].asSpec.map(In.kr(decay_bus).lag(0.1));
		env = EnvGen.ar(Env.perc(0.1, decay, 1, -4),t_trig);
		atkenv = EnvGen.ar(Env.perc(0.01, 0.035, 1, -4),t_trig);

		attenuation_ratio = In.kr(decay_bus).lag(0.1) * 0.4;

		sig = 0;
		// random buffers, a is the lead
		a = buf_bounds[0];
		b = TRand.kr(buf_bounds[1],buf_bounds[1]+1,t_trig).floor;
		rndsst = TRand.kr((BufFrames.kr(b) * 0.1).ceil,(BufFrames.kr(b) * 0.9).ceil, t_trig);
		master_env = EnvGen.ar(Env.perc(atk,decay*1.1),t_trig);
		atksnd = PlayBuf.ar(1, a, BufRateScale.kr(a), trigger: t_trig) * atkenv * 1.3;
		sig = atksnd + PlayBuf.ar(1, a, BufRateScale.kr(a)*rate, trigger: t_trig) * env;
		sig = sig + PlayBuf.ar(1, b, BufRateScale.kr(b)*rate, trigger: t_trig, startPos: rndsst ) * env;
		vol = vol - (vol*attenuation_ratio);
		// master env
		sig = sig * master_env;

		sig = sig.round(0.5 ** 12)*1.1;

		sig = LeakDC.ar(sig);
		// filter
		sig = DFM1.ar(sig, freq, 0.5, 3);
		sig = HPF.ar(sig,lowcut);
		Out.ar(out, sig*vol*on);

	}).add;

	SynthDef(\nun_basic_sampler, {
		arg out = 0, buf_bounds = #[0,0], decay_bus = 0, pitch_bus = 0,
		atk = 0.01, decay = 5, rate = 0.5, freq = 20000, t_trig = 0, vol = 1, on = 1;
		var sig, env, rate_mod;

		decay = [0.03, 5, \exp].asSpec.map(In.kr(decay_bus).lag(0.1));
		env = EnvGen.ar(Env.perc(0.01, decay, 1, -4),t_trig);
		a = buf_bounds[0];
		rate_mod = [0.1, 1.9].asSpec.map(In.kr(pitch_bus).lag(0.1));
		rate = rate_mod * rate;
		sig = PlayBuf.ar(1, a, BufRateScale.kr(a)*rate, trigger: t_trig) * env;
		sig = DFM1.ar(sig, 20000, 0.5, 1);

		Out.ar(out, sig*vol*on);
	}).add;
}
//--
);
)
