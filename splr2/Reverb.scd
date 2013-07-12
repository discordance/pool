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
	kr_route_map[\global].add(\stereo->1);

	kr_route_map;
},
\generate_func:{|o|
	var func_route_map = ();
	func_route_map;
},
\generate_synths:{|o|
	var node_group;
	node_group = o.router[\node_groups][\effects];
	o.synths[\schroeder] = Synth.head(node_group,"nun_reverb_schroeder",
	[
			\in, o.in_bus,
			\out, o.out_bus
	]);
},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|

	SynthDef(\nun_reverb_schroeder, {
		arg in = 0, out = 0;
		var s, z, y, vol, sep;
		sep = 0.001;
		s = In.ar(in,1);
		z = DelayN.ar(s, 0.048);
		// 7 length modulated comb delays in parallel :
		y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 4) }));
		// two parallel chains of 4 allpass delays (8 total) :
		4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
		s = (s+y);
		// little stereo effect
		s = [DelayC.ar(s, 1, LFNoise2.ar(2).range(0,sep)), DelayC.ar(s, 1, LFNoise2.ar(2).range(0,sep))];

		Out.ar(out,s);
	}).add;
}
)
)