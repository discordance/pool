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
\synths:(\verb:nil),
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
	kr_route_map[\global].add(\bitrate->3);

	kr_route_map;
},
\generate_func:{|o|
	var func_route_map = ();
	func_route_map;
},
\swap_verb:{|o,name|
	var node_group;
	node_group = o.router[\node_groups][\effects];
	o.synths[\verb].free;
	o.synths[\verb] = Synth.head(node_group,name,
	[
			\in, o.in_bus,
			\out, o.out_bus,
			\decay_kr, o.kr_route_map[\global][\decay],
			\lopass_kr, o.kr_route_map[\global][\lopass],
			\stereo_kr, o.kr_route_map[\global][\stereo],
			\bitrate_kr, o.kr_route_map[\global][\bitrate],
			\vol, 0.75
	]);
},
\generate_synths:{|o|
	var node_group;
	node_group = o.router[\node_groups][\effects];
	o.synths[\verb] = Synth.head(node_group,"nun_reverb_gverb",
	[
			\in, o.in_bus,
			\out, o.out_bus,
			\decay_kr, o.kr_route_map[\global][\decay],
			\lopass_kr, o.kr_route_map[\global][\lopass],
			\stereo_kr, o.kr_route_map[\global][\stereo],
			\bitrate_kr, o.kr_route_map[\global][\bitrate],
			\vol, 0.75
	]);
},
\generate_control_map:{|o|
	var b;


	// default values
	b = Bus.new('control', o.kr_route_map[\global][\decay],1,s);
	b.set(0.95);
	b = Bus.new('control', o.kr_route_map[\global][\lopass],1,s);
	b.set(0.85);
	b = Bus.new('control', o.kr_route_map[\global][\stereo],1,s);
	b.set(1);
	b = Bus.new('control', o.kr_route_map[\global][\bitrate],1,s);
	b.set(1);
},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|

	SynthDef(\nun_reverb_gverb, {
		arg in = 0, out = 0, decay_kr = 0, lopass_kr = 0, stereo_kr = 0, vol =1;
		var sig, decay = 2, freq = 20000, sep;
		decay = [0.1, 5].asSpec.map(In.kr(decay_kr).lag(0.1));
		freq = \freq.asSpec.map(In.kr(lopass_kr).lag(0.1));
		sep = [0, 100].asSpec.map(In.kr(stereo_kr).lag(0.1));

		sig = In.ar(in,1);
		sig = GVerb.ar(sig, 80, decay, 0.10, 0.5, sep, 0, 0.7, 0.8);
		sig = DFM1.ar(sig, freq);
		Out.ar(out, sig*vol);
	}).add;

	SynthDef(\nun_reverb_classic, {
		arg in = 0, out = 0, decay_kr = 0, lopass_kr = 0, stereo_kr = 0, bitrate_kr = 0, vol =1;
		var sig, local, sep = 0.00005, decay = 2, freq = 20000, bitrate = 24;

		decay = [0.1, 5].asSpec.map(In.kr(decay_kr).lag(0.1));
		sep = [0.0005, 0.01].asSpec.map(In.kr(stereo_kr).lag(0.1));
		freq = \freq.asSpec.map(In.kr(lopass_kr).lag(0.1));
		bitrate = [12, 24].asSpec.map(In.kr(bitrate_kr).lag(0.1)).floor;

		sig = In.ar(in,1);
		//
		local = LocalIn.ar(2) + sig.dup;
		//12.do{local = AllpassL.ar(local,0.1,LFNoise2.kr(0.001).range(0.01,0.05), decay)};
		14.collect({ arg i;
			local = AllpassL.ar(local,0.1,i.nthPrime*0.0023, decay);
		});

		LocalOut.ar(local*0.6);
		sig = local;
		//sig = sig.round(0.3 ** bitrate);
		sig = DFM1.ar(sig, freq);
		sig =  [DelayL.ar(sig, 1, LFNoise2.kr(0.003).range(0.00001,sep)), DelayL.ar(sig, 1, LFNoise2.kr(0.002).range(0.00005,sep))];
        // Now let's hear it:
        Out.ar(out, sig*vol);
	}).add;
}
)
)

/*

// change verb

(
~oREVERB.swap_verb("nun_reverb_gverb");
)

(
~oREVERB.swap_verb("nun_reverb_classic");
)

({
	var b;

	// default values
	b = Bus.new('control', ~oREVERB.kr_route_map[\global][\decay],1,s);
	b.set(1);
	b = Bus.new('control', ~oREVERB.kr_route_map[\global][\lopass],1,s);
	b.set(1);
	b = Bus.new('control', ~oREVERB.kr_route_map[\global][\stereo],1,s);
	b.set(1);
	b = Bus.new('control', ~oREVERB.kr_route_map[\global][\bitrate],1,s);
	b.set(0);
}.value;)


*/




