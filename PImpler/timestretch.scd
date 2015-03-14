(
/*
* Manages Four buffers, FFT Analysis for real time timestretch
* Manage preloading next and previous buffers on selection of a buffer
* This buffer manager isnt circular
*/
~quadTsBuffers = (
	// ### props
	// root path
	\root: nil,
	// fft related
	\fftWindow: 1024,
	\fftHop: 0.25,
	// is loading
	\loading: false,
	// current song selection
	\current_song: \null,
	// songs contain all the logic of song, the four tracks buffers timestretchable
	\songs: nil,
	// takes a callback, done
	\init: {|o, root, done|
		// create the songs
		// parse files
		var songs_index = ();
		o.rootPath = root;
		root.pathMatch.sort.collect({|file|
			var path = PathName.new(file);

			if(path.folderName != "analysis", {
				var splitted = path.fileName.split($_);
				var song_name = splitted.at(0).asSymbol;
				var track_num = splitted.at(1).asSymbol;
				var part_num = splitted.at(2).asSymbol;
				var tempo = splitted.at(3);
				var tempo_int, tempo_dec;

				// create the song datastructure
				(songs_index[song_name] == nil).if({
					songs_index[song_name] = (\tracks:());
				});
				(songs_index[song_name][\tracks][track_num] == nil).if({
					songs_index[song_name][\tracks][track_num] = ();
				});
				(songs_index[song_name][\tracks][track_num][part_num] == nil).if({
					songs_index[song_name][\tracks][track_num][part_num] = file;
				});
				// find out tempo
				tempo_int = tempo.split($.).at(0).split($-).at(0);
				tempo_dec = tempo.split($.).at(0).split($-).at(1);
				// reuse
				tempo = tempo_int;
				(tempo_dec != nil).if({ tempo = tempo ++ "." ++ tempo_dec });
				songs_index[song_name][\bpm] = tempo.asFloat;
				// set songs
				o.songs = songs_index;
			});
		});
		o.analysis(root, o.songs, done);
	},
	\analysis: {|o, rootPath, songs, done|
		var totalProcessed = 0;
		var getAnafilePath = {|root,file|
			var path = PathName.new(root);
			var anafile = path.pathOnly;
			anafile = anafile ++ "analysis/" ++ PathName.new(file).fileNameWithoutExtension;
			anafile = anafile ++ ".scpv";
		};
		var countFiles = {
			var ct = 0;
			songs.keysValuesDo{|song_key, song|
				song.tracks.keysValuesDo{|track_key, track|
					track.keysValuesDo{|file_key, file|
						ct = ct + 1;
					};
				};
			};
			ct;
		};
		var counterFunc = {
			var totalfiles =countFiles.value();
			totalProcessed = totalProcessed+1;
			(totalProcessed.asString++" on "++totalfiles.asString++" processed ...").postln;
			if(totalProcessed == totalfiles,{
				"DONE".postln;
				done.value();
			});
		};

		s.bind {
			// load analysis synthdef
			SynthDef("pvrec", { arg recBuf=1, soundBufnum=2;
				var in, chain, bufnum;
				bufnum = LocalBuf.new(1024);
				Line.kr(1, 1, BufDur.kr(soundBufnum), doneAction: 2);
				in = PlayBuf.ar(1, soundBufnum, BufRateScale.kr(soundBufnum), loop: 0);
				// note the window type and overlaps... this is important for resynth parameters
				chain = FFT(bufnum, in, 0.25, 1);
				chain = PV_RecordBuf(chain, recBuf, 0, 1, 0, 0.25, 1);
			}).send(s);
			// loaded
			s.sync;
			// perform the analysis
			songs.keysValuesDo{|song_key, song|
				song.tracks.keysValuesDo{|track_key, track|
					track.keysValuesDo{|file_key, file|
						var sf, analysis_buf;

						// check if analysis file is here already
						if( File.exists(getAnafilePath.value(rootPath, file)) == true , {
							track[file_key] = getAnafilePath.value(rootPath, file);
							counterFunc.value();
						},{
								// here the file
								// get some info about the file
								sf = SoundFile.new(file);
								sf.openRead;
								sf.close;
								analysis_buf = Buffer.alloc(
									s,
									sf.duration.calcPVRecSize(o.fftWindow, o.fftHop),
									2,
									// completion fonction
									{
										var audio_buf = Buffer.read(s, file, 0, -1, {|buf|
											var recSynth = Synth("pvrec", [
												\recBuf, analysis_buf,
												\soundBufnum, audio_buf
											]);

											recSynth.onFree({
												var anafile = getAnafilePath.value(rootPath, file);
												var ctFunc = counterFunc;
												var routfork = {
													0.25.wait;
													analysis_buf.free();
													audio_buf.free();
													track[file_key] = anafile;
													ctFunc.value();
												};

												analysis_buf.write(anafile, "wav", "float32",-1,0,false,{
													routfork.fork;
												});
												//
												"ok";
											});
										});
									}
								);
						});
					}
				};
			};
		}
	}
);
)



