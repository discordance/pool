(
/*
 * Manages Four buffers, FFT Analysis for real time timestretch
 * Manage preloading next and previous buffers on selection of a buffer
 * This buffer manager isnt circular
 */
~quadTsBuffers = (
	// ### props
	// is loading
	\loading: false,
	// current song selection
	\current_song: \null,
	// songs contain all the logic of song, the four tracks buffers timestretchable
	\songs: [],
	// takes a callback, done
	\init: {|o, root, done|
		// create the songs
		// parse files
		root.pathMatch.sort.collect({|file|
			var path = PathName.new(file);
			path.fileName.postln;
		});
	}
);
)