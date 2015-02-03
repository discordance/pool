
// Server config


(
/*
 * Circularly choose a file to play, while preloading the next and the
 * previous files in temp buffers
 * Manage preloading next and previous buffers on selection of a buffer
 */
~slidingLoopBuffer = (
	// ### props
	// # sorted array of path to the loops
	\files:[],
	// is loading
	\loading: false,
	// current file selection
	\current:0,
	// # objects that contains the three buffers used to hold current
	// # audio data and preload next and previous
	\cues: (\pre: nil, \cur: nil, \nex: nil),
	// ### methods
	// init the sliding buffer
	// takes a callback, done
	\init: {|o, root, done|
		// how many buffer are loaded
		var loaded = 0;
		var counter = {
			loaded = 1+loaded;
			if(loaded == 3,{
				o.loading = false;
				done.value(o.cues);
				o.cues.postln;
			});
		};
		// parse files
		o.files = root.pathMatch.sort.collect({|file| file});

		// init buffers
		o.loading = true;
		o.cues.pre = Buffer.read(s, o.files[-1%o.files.size], 0, -1, counter);
		o.cues.cur = Buffer.read(s, o.files[0], 0, -1, counter);
		o.cues.nex = Buffer.read(s, o.files[1], 0, -1, counter);
		true
	},
	\set_next: {|o, done|
		var return;
		if(o.loading != true,{
			var pre_ref;
			o.loading = true;
			o.current = o.current+1;
			// swap
			pre_ref = o.cues.pre;
			o.cues.pre = o.cues.cur;
			o.cues.cur = o.cues.nex;
			o.cues.nex = pre_ref;
			// load next
			o.cues.nex.read(o.files[(o.current+1)%o.files.size],0, -1, 0, false, {
				o.loading = false;
			});
			//return current buffer
			o.cues.postln;
			return = o.cues.cur;
		},{
			return = false;
		});
		return;
	}
);
)

~slidingLoopBuffer.init("/Users/nunja/Documents/AudioLib/PImpler/loops/*");

~slidingLoopBuffer.set_next();
