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

PRESET
******************************************************************/
(
~oPRESET =
(
// VARS
\root_path:"",
\modules: (),
// METHODS
\init:{|o,root_path|
	o.root_path = root_path ? "";
	if("/$".matchRegexp(o.root_path) !== true,{ o.root_path = o.root_path++"/"});
	o.root_path = o.root_path.replace("//","/");
	o.root_path = o.root_path ++ "splr2";
	if(File.exists(o.root_path) !== true,{
		File.mkdir(o.root_path);
	});
},
\register_module:{|o, module|
	o.modules[module.id] = module;
},
\save_preset:{|o,name|
	// how many to save cause it's async shit
	var num = o.modules.size, full_archive = (\modules:()), busses;
	o.modules.collect({|e,key|
		var id = e.id;
		full_archive[\modules][id] = e.get_preset();
	});
	// save all control busses
	full_archive[\kr_busses] = Library.at(\control_store);
	// write archive to disk
	full_archive.writeArchive(o.root_path ++ "/" ++ name);
	true;
},
\load_preset:{|o,name|
	var full_archive, path = o.root_path ++ "/" ++ name;
	if(File.exists(path) == true,{
		full_archive = Object.readArchive(path);
		// modules presets
		full_archive[\modules].collect({|e,key|
			o.modules[key].set_preset(e);
		});
		// control busses
		full_archive[\kr_busses].collect({|e,key|
			var kr_bus = key.asInteger;
			var bus = Bus.new('control', kr_bus,1,s);
			bus.set(e);
		});
	});

	true;
},
\list_presets:{|o|
},
)
)
