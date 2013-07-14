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

REVERB (FX)
******************************************************************/
(
~oREVERB = ~oFX <
(
\synths:(\schroeder:nil, \classic:nil),
\init:{|o, router, on_ready|

	var init_routine;
	// id
	o.id = \reverb; // must not be in da routine
	// callback when ready
	o.on_ready = on_ready;
	init_routine = {
		o.router = router;
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
		//o.generate_control_map();
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
\generate_func:{|o|
	var func_route_map = ();
	func_route_map;
},
\generate_synths:{|o|
	var node_group;
	node_group = o.router[\node_groups][\effects];
	o.synths[\classic] = Synth.head(node_group,"nun_reverb_classic",
	[
			\in, o.in_bus,
			\out, o.out_bus,
			\decay_kr, o.kr_route_map[\global][\decay],
			\lopass_kr, o.kr_route_map[\global][\lopass],
			\stereo_kr, o.kr_route_map[\global][\stereo]
	]);
},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|

	SynthDef(\nun_reverb_classic, {
		arg in = 0, out = 0, decay_kr = 0, lopass_kr = 0, stereo_kr = 0;
		var sig, local, sep, decay = 2, freq = 20000;

		decay = [0.1, 5].asSpec.map(In.kr(decay_kr).lag(0.1));
		sep = [0.0005, 0.01].asSpec.map(In.kr(stereo_kr).lag(0.1));
		freq = \freq.asSpec.map(In.kr(lopass_kr).lag(0.1));

		sig = In.ar(in,1);
		local = LocalIn.ar(2) + sig.dup;
		24.do{local = AllpassC.ar(local,0.06,LFNoise2.kr(0.01).range(0.001,0.06), decay)};

		LocalOut.ar(local*0.5);
		sig = sig+local;
		sig = sig.round(0.3 ** 12);
		sig = DFM1.ar(sig, freq);
		sig =  [DelayC.ar(sig, 1, LFNoise2.ar(5).range(0,sep)), DelayC.ar(sig, 1, LFNoise2.ar(6).range(0,sep))];
        // Now let's hear it:
        Out.ar(out, sig);
	}).add;
}
)
)



