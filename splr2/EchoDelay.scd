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

ECHO DELAY (FX)
******************************************************************/
(
~oECHO = ~oFX <
(
\lengths:[1, 0.75, 0.66, 0.5, 0.33, 0.25, 0.125],
\multiplier:0.25,
\tempo:0,
\last_time:0,
\synths:(\echo:nil),
\init:{|o, router, on_ready|

	var init_routine;
	// id
	o.id = \echo; // must not be in da routine
	// callback when ready
	o.on_ready = on_ready;
	init_routine = {
		o.router = router;
		o.router.num_fx = o.router.num_fx+1; // inc router expected
		o.load_synthdefs();
		s.sync;

		// control route
		o.kr_route_map = o.generate_kr();

		// functions
		o.func_route_map = o.generate_func();
		// assign from router
		o.router.assign_fx(o);

		// add synths
		o.generate_synths();
		// generate control map NOT NOW
		o.generate_control_map();
		//
		o.on_ready(init_routine);
	}.fork;
},
\generate_kr:{|o|
	var kr_route_map = (\global: ());

	kr_route_map[\global].add(\decay->0);
	kr_route_map[\global].add(\lopass->1);
	kr_route_map[\global].add(\stereo->2);


	kr_route_map;
},
\set_length:{|o, scope,val|
	o.multiplier = o.lengths[(val*(o.lengths.size-1))];
	o.multiplier.postln;
},
\generate_func:{|o|
	var func_route_map = ();
	func_route_map[\global] = ().add(\length->{|val| o.set_length(\global,val)});
	func_route_map;
},
\generate_synths:{|o|
	var node_group;
	node_group = o.router[\node_groups][\effects];
	o.synths[\echo] = Synth.head(node_group,"nun_dub_echo",
	[
			\in, o.in_bus,
			\out, o.out_bus,
			\chain, o.chain_bus,
			\decay_kr, o.kr_route_map[\global][\decay],
			\lopass_kr, o.kr_route_map[\global][\lopass],
			\stereo_kr, o.kr_route_map[\global][\stereo]
	]);
},
\generate_control_map:{|o|
	var b;
	Library.put(\control_map,\motu,\4,\4,o.func_route_map[\global][\length]);
	Library.put(\control_map,\motu,\4,\5,o.kr_route_map[\global][\decay]);
	Library.put(\control_map,\motu,\4,\6,o.kr_route_map[\global][\lopass]);
	Library.put(\control_map,\motu,\4,\7,o.kr_route_map[\global][\stereo]);

	// default values
	b = Bus.new('control', o.kr_route_map[\global][\decay],1,s);
	b.set(0.45);
	b = Bus.new('control', o.kr_route_map[\global][\lopass],1,s);
	b.set(1);
	b = Bus.new('control', o.kr_route_map[\global][\stereo],1,s);
	b.set(0.0);
},
\on_clock:{|o, val|
	var time, ival;
	time = Main.elapsedTime;
	ival = (time - o.last_time)*24;
	o.tempo = (60/ival).round.lag;
	o.synths[\echo].set(\length, ival*o.multiplier);
	o.last_time = time;
},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|

	SynthDef(\nun_dub_echo, {
		arg in = 0, out = 0, decay_kr = 0, lopass_kr = 0, stereo_kr = 0, length = 1, chain =0;
		var sep = 0.012, decay = 1, freq = 20000, vol = 1, output, input, feedback, dly, dly2;

		decay = [0,0.8].asSpec.map(In.kr(decay_kr).lag(0.1));
		sep = [0.0, 1].asSpec.map(In.kr(stereo_kr).lag(0.1));
		freq = \freq.asSpec.map(In.kr(lopass_kr).lag(0.1));
		length = length.lag(1);

		input = In.ar(in, 1) ! 2;
		output = LeakDC.ar(LocalIn.ar(2)*(decay/2)+input);
		output = HPF.ar(output, 200);
		output = DFM1.ar(output, freq);

		dly = LeakDC.ar(CombC.ar(output*vol, 2, length, decay));
		dly2 = LeakDC.ar(CombC.ar(output*vol, 2, length, decay))*sep;
		LocalOut.ar(dly*EnvGen.kr(Env.perc(0.01,10,1),Amplitude.kr(input)));
        Out.ar(out, dly+dly2);
		// chain
		Out.ar(chain, dly+dly2);
	}).add;
}
)
)

//~oECHO.multiplier = 0.25;
