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

RANDOMER
******************************************************************/
(
~oRANDOMER = (
\randomize_drums:{|o,drum_module|
		drum_module.current_kit[\kick] = drum_module.available_kits[\kick].keys.asArray.choose;
		drum_module.current_kit[\drm1] = drum_module.available_kits[\drm1].keys.asArray.choose;
		drum_module.current_kit[\drm2] = drum_module.available_kits[\drm2].keys.asArray.choose;
		drum_module.current_kit[\snar] = drum_module.available_kits[\snar].keys.asArray.choose;
		drum_module.current_kit[\clap] = drum_module.available_kits[\clap].keys.asArray.choose;
		drum_module.current_kit[\cymb] = drum_module.available_kits[\cymb].keys.asArray.choose;
		drum_module.current_kit[\hat1] = drum_module.available_kits[\hat1].keys.asArray.choose;
		drum_module.current_kit[\hat2] = drum_module.available_kits[\hat2].keys.asArray.choose;
		drum_module.density = 1;

		// pitches
		drum_module.current_kit.collect{|el,key|
			var b;
			// pitch
			b = Bus.new('control',drum_module.kr_route_map[key]['pitch'],1,s);
			b.set(1.0.rand * 0.6 + 0.3);
			// decay
			b = Bus.new('control',drum_module.kr_route_map[key]['decay'],1,s);
			b.set(0.5.rand);//\lpf

			b = Bus.new('control',drum_module.kr_route_map[key]['lpf'],1,s);
			b.set(1-0.5.rand);
		}
}
);
)