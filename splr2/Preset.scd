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
\register:{|o, module|
	o.modules[module.id] = module;
},
\save_preset:{|o,name|
	// how many to save cause it's async shit
	var target;
	var num = o.modules.size, full_archive = (\modules:()), busses;
	o.modules.collect({|e,key|
		var id = e.id;
		full_archive[\modules][id] = e.get_preset();
	});
	// save all control busses
	full_archive[\kr_values] = Library.at(\control_store);
	// write archive to disk
	// check
	target = o.root_path ++ "/" ++ name;
	if(File.exists(target),{
		if(File.exists(target++"~") == false,{
			File.copy(target,target++"~");
		},{
				File.delete(target++"~");
			File.copy(target,target++"~");
		});

	});
	full_archive.writeArchive(o.root_path ++ "/" ++ name);
	true;
},
\load_preset:{|o,name|
	var full_archive, rpath = o.root_path ++ "/" ++ name;
	if(File.exists(rpath) == true,{
		full_archive = Object.readArchive(rpath);
		// modules presets
		full_archive[\modules].collect({|e,key|
			o.modules[key].set_preset(e);
		});

		// control busses
		full_archive[\kr_values].collect({|e,key|
			// get bus number
			var bus, path, kr_bus;
			path = key.asString.compile.value;
			if(path != nil,{
				kr_bus = o.modules[path[\device]].kr_route_map[path[\cat]][path[\control]];
				//var kr_bus = key.asInteger; // <---------------------------------------------------
				bus = Bus.new('control', kr_bus,1,s);
				bus.set(e);
				Library.put(\control_store, key, e);
			})

		});
	});

	true;
},
\list_presets:{|o|
},
)
)
