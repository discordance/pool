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

ROUTER
******************************************************************/
(
~oROUTER =
(
// VARS
\debug_out: false,
\node_groups: (),
\modules: [],
\next_kr: 15,
\next_ar: 15, // routing assigned to modules out
\next_fx_ar: 64, // next free input for FX, always mono
\fx_bus_out:8, // output for the FX
\shape_buffers:nil,
\mixshape_buffer:nil,
\void_buffer:nil,
// METHODS
\init:{|o, debug_out = false|
	var cheb_sin = Signal.sineFill(1000, 1.0/[1, 2, 3, 4, 5, 6]);
	"~oROUTER : clearing node tree, freeing all buffers ...".postln;

	o.debug_out = debug_out;

	// clear clear !!
	Server.all.do(_.freeAll);

	// buffers
	// BUFFER INIT --------------------------------
	Buffer.freeAll; // free all buffers
	// create the emptybuffer zero, the void buffer
	o.void_buffer = Buffer.alloc(s, s.sampleRate, 2);

	// WAVESHAPER BUFFERS
	o.shape_buffers = "/Users/nunja/Documents/AudioLib/supercollider/waveshape/*".pathMatch.collect{|elem|
		Buffer.readChannel(s,elem,0,600,0,{|b|
			b.normalize;
		});
	};
	o.mixshape_buffer = Buffer.alloc(s, 600, 1);

	// routing node groups
	// generators -> modules that generate sounds
	o.node_groups = o.node_groups.add(\generators -> Group.head(s));
	// premixers -> to route generator into main and sends bus
	o.node_groups = o.node_groups.add(\premixers -> Group.tail(s));
	// effects -> bus of effects
	o.node_groups = o.node_groups.add(\effects -> Group.tail(s));
	// main mix -> get all the virtual bus and route to physical busses
	o.node_groups = o.node_groups.add(\main_out -> Group.tail(s));
},
\assign:{|o,target|
	o.assign_ar(target);
	o.assign_kr(target);
	//o.modules = o.modules.add(target.id->target);
},
\assign_fx:{|o,target|
	// ar is different because must manage in and outs
	o.assign_ar_fx(target);
	// kr is same for FX and modules
	o.assign_kr(target);
},
\assign_ar_fx: {|o,target|
	//
	target.in_bus = o.next_fx_ar;
	o.next_fx_ar = o.next_fx_ar + 1;

	target.out_bus = o.fx_bus_out;
}
,
\assign_ar: {|o,target|
	var needed, tmp_map;
	needed = target.ar_route_map.as(Set).size;// how much busses I have to book ? thx supercollider ..
	tmp_map = Array.fill(needed,0);
	needed.do({|i|
		tmp_map[i] = o.next_ar;
		o.next_ar = o.next_ar + 1;
	});

	target.ar_route_map = target.ar_route_map.collect{|el|
		el = tmp_map[el];
	};
},
\assign_kr:{|o,target|
	var needed, set, tmp_map;
	set = [];
	target.kr_route_map.collect{|e,k|
		e.collect{|ee,kk|
			set = set.add(ee);
		};
	};
	needed = set.as(Set).size;
	tmp_map = Array.fill(needed,0);
	needed.do({|i|
		tmp_map[i] = o.next_kr;
		o.next_kr = o.next_kr + 1;
	});
	target.kr_route_map = target.kr_route_map.collect{|e|
		e = e.collect{|ee|
			ee = tmp_map[ee];
		};
	};
	o.register_reverse_map(target);
},
\register_reverse_map:{|o, target|
	var kr_map = target.kr_route_map;
	kr_map.collect{|e,k|
		e.collect{|ee,kk|
			//target.id.post; " ".post; k.post; " ".post; ee.post; " ".post; kk.postln;
			Library.put(\reverse_map, ee.asSymbol, (\device:target.id, \cat:k, \control: kk));
		};
	};

},
\on_note: {|o, src, chan, num, val|

	//chan.asSymbol.post; " ".post; num.asSymbol.postln;

	o.modules.do({|e,i|
		e.devices.do({|ee,ii|
			if(ee.uid == src,{
				e.module.on_note(chan, num, val);
			});
		});
	});
},
\on_control: {|o, src, chan, num, val|
	var device = Library.at(\device_map,src), target;
	target = Library.at(\control_map,device,chan.asSymbol,num.asSymbol);

	//chan.asSymbol.post; " ".post; num.asSymbol.postln;

	//target.postln;
	if(target !== nil, {
		if(target.class.asString == "Function",{ // got function
			target.value(val/127);
		});
		if(target.class.asString == "Integer",{ // got bus
			var ctrl_path;
			var bus = Bus.new('control', target,1,s);
			bus.set(val/127);

			ctrl_path = Library.at(\reverse_map,target.asSymbol);
			//ctrl_path.asCompileString.postln;

			// we save last bus value to store in presets
			Library.put(\control_store, ctrl_path.asCompileString.asSymbol, val/127);
		});
	});
},
\on_clock: {|o, src, val|
	o.modules.do({|e,i|
		e.devices.do({|ee,ii|
			if(ee.uid == src,{
				e.module.on_clock(val);
			});
		});
	});
},
\register_fx:{|o, module, devices|
	var mod = (\module:module, \devices:devices);
	o.modules = o.modules.add(mod);
},
\register_module:{|o, module, devices|
	var min, num_busses;
	var mod = (\module:module, \devices:devices);
	o.modules = o.modules.add(mod);

	// first audio bus used
	min = module.ar_route_map.as(Set).minItem;
	num_busses = module.ar_route_map.as(Set).size;

	{
		// dymanically creates a SynthDef

		// DEBUG MODE
		/*
		SynthDef("debug_out_%".format(module.id).asSymbol, {
			var sig;
			sig = In.ar(min, num_busses);
			Out.ar(0, Splay.ar(sig,0)*0.83); // too loud so we cut
		}).add;

		s.sync;

		Synth.head(o.node_groups[\main_out], "debug_out_%".format(module.id).asSymbol);
		*/
		// MIXER MODE

		SynthDef("physical_out_%".format(module.id).asSymbol, {
			var sig;
			sig = In.ar(min, num_busses);
			Out.ar(min-13, sig*0.9);
		}).add;

		s.sync;

		Synth.head(o.node_groups[\main_out], "physical_out_%".format(module.id).asSymbol);


		// SOUND FLOWER
	}.fork;


},
/* SynthDefs
******************************************************************/
\load_synthdefs:{|o|

}
);
)
