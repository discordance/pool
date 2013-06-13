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
	var num = o.modules.size, full_archive = ();
	o.modules.collect({|e,key|
		var id = e.id;
		e.get_preset({|archive|
			full_archive[id] = archive;
			num = num - 1;
			if(num == 0,{
				full_archive.writeArchive(o.root_path ++ "/" ++ name);
			});
		});
	});
	true;
},
\load_preset:{|o,name|
	var full_archive, path = o.root_path ++ "/" ++ name;
	if(File.exists(path) == true,{
		full_archive = Object.readArchive(path);
		full_archive.collect({|e,key|
			o.modules[key].set_preset(e);
		});
	});
	true;
},
\list_presets:{|o|
},
)
)
