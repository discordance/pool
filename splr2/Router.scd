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
\modules: [],
\next_kr: 15,
\next_ar: 15,
\void_buffer:nil,
// METHODS
\init:{|o|
	"~oROUTER : clearing node tree, freeing all buffers ...".postln;
	// clear clear !!
	Server.all.do(_.freeAll);

	// buffers
	// BUFFER INIT --------------------------------
	Buffer.freeAll; // free all buffers
	// create the emptybuffer zero, the void buffer
	o.void_buffer = Buffer.alloc(s, s.sampleRate, 2);
},
\assign:{|o,target|
	o.assign_ar(target);
	o.assign_kr(target);
	o.modules = o.modules.add(target);
},
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
	tmp_map.postln;
}
//--
);
)