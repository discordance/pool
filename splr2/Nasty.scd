/*****************************************************************

                        boing         boing         boing"/Users/nunja/Documents/SuperCollider/Nunja/splr2/Nasty.scd"
              e-e           . - .         . - .         . - .
             (\_/)\       '       `.   ,'       `.   ,'       .
              `-'\ `--.___,         . .           . .          .
                 '\( ,_.-'
                    \\               "             "            "
                    ^'
SPLR v2 - Vauban
****

NASTY (FX)
******************************************************************/
(
~oNASTY = ~oFX <
(
\cheb_buff:nil,
\synths:(\nasty:nil),
\init:{|o, router, on_ready|

	var init_routine;
	// id
	o.id = \nasty; // must not be in da routine
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
		o.generate_control_map();
		//
		o.on_ready(init_routine);
	}.fork;
},
\generate_kr:{|o|
	var kr_route_map = (\global: ());
	kr_route_map;
},
\generate_func:{|o|
	var func_route_map = ();
	func_route_map[\global] = ().add(\wave->{|val|

	});
	func_route_map;
},
\generate_synths:{|o|
	var node_group;
	node_group = o.router[\node_groups][\effects];

	"bufnum : ".post; o.cheb_buff.numChannels.postln;
	o.synths[\nasty] = Synth.head(node_group,"nun_nasty",
	[
			\in, o.in_bus,
			\out, o.out_bus
	]);
},
\generate_control_map:{|o|
	var b;
},
\on_clock:{|o, val|

},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|

	SynthDef(\nun_nasty, {
		arg in, out;
		var soundIn, output;
		soundIn = In.ar(in,1);
		output = CrossoverDistortion.ar(soundIn,0.7,0.4)*Amplitude.ar(soundIn*4);
		output = DFM1.ar(output,14000,0.2,1) *0.5;

		Out.ar(out, output!2);
	}).add;
}
)
)


//~oNASTY.cheb_buff;
