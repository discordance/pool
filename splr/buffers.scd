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
	~buffers = Array.fill(~pathArr.size,0);
	~pathArr.do{ |file, i|
		~buffers[i] = file.pathMatch.sort.collect{|sfile|
			Buffer.read(s,sfile);
		};
	};

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
				// analysis
				buf = Buffer.read(s,sfile,action:{|inbuf|
					if(k<1,{
						var ana_buf;
						ana_buf = Buffer.alloc(s, inbuf.numFrames / s.options.blockSize, 1, {|inanabuf|
							//inbuf.post; " ".post; inanabuf.bufnum.postln;
							~kitCorrectionsBufs.put(inbuf.bufnum, inanabuf);
							~kitCorrectionsArr.put(inbuf.bufnum, 0); // init
							{
								var snd;
								snd = PlayBuf.ar(1, inbuf, doneAction:2, loop:0);
								RecordBuf.kr(Tartini.kr(snd,k:1512).at(0), inanabuf);
							}.play;
						});
						//buf.postln;
					});
				});
				~kitBuffers[i][idx.asInt] = ~kitBuffers[i][idx.asInt] ++ buf;
			};
		};
	};

	// drumkits inited we can do the rest:
	// create a stack of drum synths
	~dr_synths = Array.fill(8,{|i|
		var bounds = ~drumIndexParse.value(~kitCurrent,i);
		Synth.head(~splr_drums,"nun_drsampler",
			[\buf_bounds, bounds,
			 \pitch_busses,~dr_bus_pitch_base+i,
			\out, ~drumBus]);
	});
};