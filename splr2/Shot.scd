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

SHOT
******************************************************************/

(
~oSHOT = ~oMODULE <
(
// VARS
\available_kits:(),
// METHOD
\init:{|o, router, root_path, on_ready, ar_route_map = nil, kr_route_map = nil|
	var init_routine;
	// id
	o.id = \drums; // must not be in da routine
	// path
	o.root_path = root_path ? "";
	if("/\\*".matchRegexp(o.root_path) !== true,{ o.root_path = o.root_path++"/*"});
	o.root_path = o.root_path.replace("//","/");

	// callback when ready
	o.on_ready = on_ready;
	init_routine = {
		o.router = router;
		o.load_synthdefs();
		s.sync;
	};


};
);

)