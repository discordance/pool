/**
 * NUNJA Sample Station v0.1
 * buffers.scd
        _
        [ ]
       (   )
        |>|
     __/===\__
    //| o=o |\\
  <]  | o=o |  [>
      \=====/
     / / | \ \
    <_________>

 */

/**
* INIT buffers
*/
~init_buffers =
{
	// OS buffers
	~pathArr = ~osPath.pathMatch.sort({ arg a, b; a.asInt > b.asInt }).collect{|file|
		~sampleSetsTotal = ~sampleSetsTotal + 1;
		file.insert(file.size,"*");
	};

	//~buffers = Array.fill(~pathArr.size,0);
	~pathArr.do{ |file, i|

		~buffers.put(file.dirname.basename, Dictionary.new);
		file.pathMatch.sort.collect{|sfile|
			var basenamee = sfile.basename;
			~buffers[file.dirname.basename].put(sfile.basename, []);

			sfile = sfile ++ "*";
			sfile.pathMatch.sort.collect{|kfile|
				~buffers[file.dirname.basename][basenamee] =
				~buffers[file.dirname.basename][basenamee].add(Buffer.read(s,kfile));
			};
		};
	};
	~get_os_buffers.value(0);
	// Drum Kits
	~kitPathArr = ~kitPath.pathMatch.sort.collect{|file|
		file.insert(file.size,"*");
	};

	~kitBuffers = [];
	~kitPathArr.do{ |file, i|
		~kitBuffers = ~kitBuffers.add([]);
		~kitBuffers[i] = Array.fill(8,[]);
		file.pathMatch.sort.collect{|kfile, j|
			kfile = kfile ++ "*";
			kfile.pathMatch.sort.collect{|sfile, k|
				var buf, idx = sfile.dirname.basename;
				~kitBuffers[i][idx.asInt] = ~kitBuffers[i][idx.asInt] ++ buf;
			};
		};
	};

	// drumkits inited we can do the rest:
	// create a stack of drum synths
	~dr_synths = Array.fill(8,{|i|
		var bounds = ~drumIndexParse.value(~kitCurrent,i);
		var decay_bus = 6;
		if(i > 3, { decay_bus = 7; });

		Synth.head(~splr_drums,"nun_drsampler",
			[\buf_bounds, bounds,
			 \decay_bus, decay_bus,
			 \pitch_busses,~dr_bus_pitch_base+i,
			\out, ~drumBus]);
	});
	"";
};