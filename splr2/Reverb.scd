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

		// audio route IN
		o.ar_route_in_map = o.generate_ar_in();
		// audio route OUT
		o.ar_route_out_map = o.generate_ar_out();

		// control route
		//o.kr_route_map = kr_route_map ? o.generate_kr();
		// functions
		//o.func_route_map = o.generate_func();
		// assign from router
		//o.router.assign(o);
		// add synths
		//o.generate_synths();
		// generate control map
		//o.generate_control_map();
		//
		//o.on_ready(init_routine);
	}.fork;
},
\generate_ar_in:{|o|

	var ar_in_route_map = ();
	ar_in_route_map = (   // id : audio bus
		\mono_in:0,
	);
	ar_in_route_map;
},
\generate_ar_out:{|o|
	var ar_out_route_map = ();
	ar_out_route_map = (   // id : audio bus
		\stereo_out:0,
	);
	ar_out_route_map;
},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|

	SynthDef(\nun_reverb_a, {
		arg in = 0, out = 0;
		var s, z, y, vol;
		s = In.ar(in,2);
		z = DelayN.ar(s, 0.048);
		// 7 length modulated comb delays in parallel :
		y = Mix.ar(Array.fill(7,{ CombL.ar(z, 0.1, LFNoise1.kr(0.1.rand, 0.04, 0.05), 4) }));
		// two parallel chains of 4 allpass delays (8 total) :
		4.do({ y = AllpassN.ar(y, 0.050, [0.050.rand, 0.050.rand], 1) });
		s = s+y;
		Out.ar(out,s);
	}).add;


}
)
)