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
	o.synths[\classic] = Synth.head(node_group,"nun_reverb_classic",
	[
			\in, o.in_bus,
			\out, o.out_bus
	]);
},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|

	SynthDef(\nun_reverb_classic, {
		arg in = 0, out = 0;
		var sig,local;

		sig = In.ar(in,1);
		local = LocalIn.ar(2) + sig.dup;
		30.do{local = AllpassN.ar(local,0.06,LFNoise2.kr(0.01).range(0.001,0.06),4)};

		LocalOut.ar(local*0.6);

        // Now let's hear it:
        Out.ar(out, sig+local);
	}).add;
}
)
)

