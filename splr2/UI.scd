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

DEBUG UI
******************************************************************/
(
~oUI =
(
\init:{|o|


},
\bind_module:{|o, module|
	{
		var main_window, num_ctrl = 0, set, needed, xw, yh;
		var module_label, vpan, panels, pandx = 0;


		// how many controls ?
		set = [];
		module.kr_route_map.collect{|e,k|
			e.collect{|ee,kk|
				set = set.add(ee);
			};
		};
		needed = set.size;
		// add functions
		set = [];
		module.func_route_map.collect{|e,k|
			e.collect{|ee,kk|
				set = set.add(ee);
			};
		};
		needed = needed+set.size;
		xw = (needed/4).floor;
		yh = (needed/8).floor;

		yh.postln;

		// init window
		main_window = Window.new(module.id.asString.toUpper++" DEBUG CONTROLS", Rect(300,100,xw*110,yh*85));
		main_window.front;
		main_window.alwaysOnTop = true;
		panels = [];
		module_label = StaticText(main_window, Rect(10, 10, 150, 20));
		module_label.string = module.id.asString.toUpper ++" MODULE";

		vpan = VLayoutView(main_window, Rect(10,30,xw*110,yh*75));
		vpan.background_(Color.fromHexString("#FF0000"));

		yh.do{|i|
			var module_panel;
			module_panel = HLayoutView(vpan, Rect(10,30,xw*110,75));
			module_panel.background_(Color.rand);
			panels = panels.add(module_panel);
		};

		module.kr_route_map.collect{|e,k|
			e.collect{|ee,kk|
				var ctrl_name = k ++ "_" ++ kk;

				EZKnob(panels[pandx], 105@74, ctrl_name, [0, 1].asSpec.default = 0.5,{ |widget|
					var bus = Bus.new('control', ee,1,s);
					bus.set(widget.value);
					// we save last bus value to store in presets
					Library.put(\control_store,ee.asSymbol, widget.value);
				},
				layout:\vert2, initAction:false );

				num_ctrl = num_ctrl+1;
				if(num_ctrl % xw == 0,{
					pandx = pandx+1;
				});
			};
		};
		module.func_route_map.collect{|e,k|
			e.collect{|ee,kk|
				var ctrl_name = k ++ "_" ++ kk;

				EZKnob(panels[pandx], 105@74, ctrl_name, [0, 1].asSpec.default = 0.5,{ |widget|
					ee.value(widget.value);
				},
				layout:\vert2, initAction:false );

				num_ctrl = num_ctrl+1;
				if(num_ctrl % xw == 0,{
					pandx = pandx+1;
				});
			};
		};

	}.defer;
}
)
)

