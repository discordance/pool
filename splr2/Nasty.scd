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
	kr_route_map[\global].add(\buffer->0);
	kr_route_map[\global].add(\dist->1);
	kr_route_map;
},
\generate_func:{|o|
	var func_route_map = ();
	func_route_map[\global] = ().add(\wave->{|val|

	});
	func_route_map;
},
\generate_synths:{|o|
	var node_group, buffs, int_buff;
	node_group = o.router[\node_groups][\effects];

	buffs = [o.router.shape_buffers[0],o.router.shape_buffers[o.router.shape_buffers.size-1]];
	int_buff = o.router.mixshape_buffer;

	o.synths[\nasty] = Synth.head(node_group,"nun_waveshaper",
	[
			\in, o.in_bus,
			\out, o.out_bus,
			\chain, o.chain_bus,
			\buffers, buffs,
			\mix_buffer, int_buff,
			\buf_bus, o.kr_route_map[\global][\buffer],
			\dist_bus, o.kr_route_map[\global][\dist]

	]);
},
\generate_control_map:{|o|
	var b;
	Library.put(\control_map,\motu,\4,\8,o.kr_route_map[\global][\buffer]);
	Library.put(\control_map,\motu,\4,\9,o.kr_route_map[\global][\dist]);
},
\on_clock:{|o, val|

},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|

	SynthDef(\nun_waveshaper, {
		arg in, out, buffers = #[0,0], mix_buffer, buf_bus = 0, dist_bus = 0, chain = 0;
		var input, shp, dist, output = 0;
		var buf = [buffers[0], buffers[1]].asSpec.map(In.kr(buf_bus).lag(0.1));
		var type = [1, 11].asSpec.map(In.kr(dist_bus).lag(0.1));

		input = In.ar(in,1);
		input = HPF.ar(input,50);
		input = input+(FaustZitaRev1.ar(
		input,
		input,
		in_delay:100,
		lf_x:4000,
		low_rt60:1,
		mid_rt60:2,
		hf_damping:4000,
		eq1_freq:300,
		eq1_level:2,
		eq2_freq:2000,
		eq2_level:2,
		dry_wet_mix:0.01,
			level:2)*0.5);
		dist = LADSPA.ar(2,1771,(input!2)*2,type,52,0);

		shp = Pan2.ar((Shaper.ar(buf,dist,2)*0.15) + (Shaper.ar(buf,dist,2)*0.15),LFNoise2.kr(100).range(-0.1,0.1));

		shp = LeakDC.ar(shp)*0.5;
		shp = shp;

		shp = (Amplitude.kr(input)*16).abs.lag(0.1) * shp;
		shp = Compander.ar(shp,shp,-16.dbamp, 1, 1.4, 0.2, 0.5, 1.2);

		Out.ar(out, ((0.6*shp)+dist)*0.08);
		//chain
		Out.ar(chain, shp);
	}).add;
}
)
)
//LADSPA.listPlugins;