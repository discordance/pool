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
			\decay_kr, o.kr_route_map[\global][\decay],
			\lopass_kr, o.kr_route_map[\global][\lopass],
			\stereo_kr, o.kr_route_map[\global][\stereo]
	]);
},
\generate_control_map:{|o|
	var b;


	// default values
	b = Bus.new('control', o.kr_route_map[\global][\decay],1,s);
	b.set(0.45);
	b = Bus.new('control', o.kr_route_map[\global][\lopass],1,s);
	b.set(0.85);
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
		arg in = 0, out = 0, decay_kr = 0, lopass_kr = 0, stereo_kr = 0, length = 1;
		var sep = 0.012, decay = 1, freq = 20000, vol = 1, output, input, feedback;

		decay = [0.1, 1].asSpec.map(In.kr(decay_kr).lag(0.1));
		sep = [0.0005, 0.01].asSpec.map(In.kr(stereo_kr).lag(0.1));
		freq = \freq.asSpec.map(In.kr(lopass_kr).lag(0.1));

		input = In.ar(in, 1);
		feedback = LocalIn.ar(2);
		output = LeakDC.ar(feedback*decay + input);

		output = HPF.ar(output, 280);
		output = LPF.ar(output, 12000);
		output = output.tanh*1.5;


		LocalOut.ar(
			DelayC.ar(output*vol, 5,
				length
				//LFNoise2.kr(0.2).range([length,length+SinOsc.kr(0.1).range(0,0.012)],[length+sep,length])
			).reverse
		);
        Out.ar(out, output);
	}).add;
}
)
)

//~oECHO.multiplier = 0.25;
